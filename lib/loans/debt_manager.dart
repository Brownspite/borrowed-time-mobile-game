import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'active_debt.dart';
import 'debt_notice.dart';
import 'loan.dart';
import 'loan_constants.dart';

enum PaymentType {
  hp,
  score,
  sacrificeUpgrade,
}

/// Tracks active loans, countdowns, penalty escalations, and debt settlement.
class DebtManager {
  DebtManager({required this.game});

  final BorrowedTimeGame game;
  final List<ActiveDebt> activeDebts = [];
  final List<DebtNotice> pendingNotices = [];

  /// Exact HP cost to settle a debt early.
  double get hpCost => game.playerStats.maxHp * LoanTuning.earlyPayHpFraction;

  /// Exact score cost to settle a debt early.
  int get scoreCost => LoanTuning.earlyPayScoreCost;

  /// Whether player has enough HP to pay early without dying (must have > hpCost and > 1.0).
  bool get canAffordHp =>
      game.playerStats.hp > hpCost && game.playerStats.hp > 1.0;

  /// Whether player has enough score to pay early.
  bool get canAffordScore => game.gameState.score >= scoreCost;

  /// Whether there are other upgrades available to sacrifice.
  bool canSacrifice(ActiveDebt debt) => activeDebts.any((d) => d != debt);

  /// Quantifies the player's total debt pressure for the loan shark mood.
  /// Standard active loans add 1. Due/overdue loans add 2 + (overdueWaves * 2).
  int get totalDebtLevel {
    return activeDebts.fold<int>(0, (sum, debt) {
      if (debt.isDue) {
        return sum + 2 + (debt.overdueWaves * 2);
      }
      return sum + 1;
    });
  }

  /// Accepts a new loan, granting its bonus immediately.
  ActiveDebt addLoan(Loan loan) {
    loan.applyBonus(game);
    final activeDebt = ActiveDebt(
      loan: loan,
      remainingWaves: loan.dueInWaves,
    );
    activeDebts.add(activeDebt);
    return activeDebt;
  }

  /// Invoked every time the player clears a wave.
  /// Decrements countdowns; applies penalties upon reaching 0;
  /// escalates penalties with each subsequent overdue wave.
  /// Generates [DebtNotice] banners for collection and overdue interest alerts.
  void onWaveCleared() {
    pendingNotices.clear();

    for (final debt in List<ActiveDebt>.from(activeDebts)) {
      if (debt.remainingWaves > 0) {
        debt.remainingWaves--;
        if (debt.remainingWaves == 0) {
          // Debt is now due
          debt.penaltyApplied = true;
          debt.currentPenaltyMultiplier = 1.0;
          debt.loan.applyPenalty(game, penaltyMultiplier: 1.0);
          pendingNotices.add(DebtNotice(
            loanId: debt.loan.id,
            loanName: debt.loan.name,
            penaltyDescription: debt.loan.debtDescription,
            isOverdue: false,
            overdueWaves: 0,
            multiplier: 1.0,
          ));
        }
      } else {
        // Debt was already due and remains unpaid -> overdue escalation
        debt.overdueWaves++;
        debt.currentPenaltyMultiplier =
            debt.loan.calculatePenaltyMultiplier(debt.overdueWaves);
        debt.loan.applyPenalty(
          game,
          penaltyMultiplier: debt.currentPenaltyMultiplier,
        );
        pendingNotices.add(DebtNotice(
          loanId: debt.loan.id,
          loanName: debt.loan.name,
          penaltyDescription: debt.loan.debtDescription,
          isOverdue: true,
          overdueWaves: debt.overdueWaves,
          multiplier: debt.currentPenaltyMultiplier,
        ));
      }
    }
  }

  /// Clears any pending debt collection banners.
  void clearPendingNotices() {
    pendingNotices.clear();
  }

  /// Pays off a debt early or before further overdue penalties accumulate.
  /// If successfully paid, the debt is resolved and removed from [activeDebts].
  /// Bonus of the paid [debt] is retained.
  /// Returns true if payment succeeded, false otherwise.
  bool payEarly(
    ActiveDebt debt,
    PaymentType paymentType, {
    ActiveDebt? sacrificeTarget,
  }) {
    if (!activeDebts.contains(debt)) return false;

    switch (paymentType) {
      case PaymentType.hp:
        if (!canAffordHp) return false;
        game.playerStats.hp -= hpCost;
        break;

      case PaymentType.score:
        if (!canAffordScore) return false;
        game.gameState.score -= scoreCost;
        break;

      case PaymentType.sacrificeUpgrade:
        final candidates = activeDebts.where((d) => d != debt).toList();
        if (candidates.isEmpty) return false;
        final sacrificed = (sacrificeTarget != null && candidates.contains(sacrificeTarget))
            ? sacrificeTarget
            : candidates.first;
        // Sacrifice another active loan to clear this one
        sacrificed.loan.removeBonus(game);
        activeDebts.remove(sacrificed);
        break;
    }

    activeDebts.remove(debt);
    return true;
  }

  /// Repossesses a specific loan, stripping its bonus and removing it from debts.
  void repossess(ActiveDebt debt) {
    debt.loan.removeBonus(game);
    activeDebts.remove(debt);
  }

  /// Repossesses a random other loan (used e.g. by Triple Shot debt).
  ActiveDebt? repossessRandomOther({required String excludingId}) {
    final candidates =
        activeDebts.where((d) => d.loan.id != excludingId).toList();
    if (candidates.isEmpty) return null;
    candidates.shuffle();
    final toRemove = candidates.first;
    repossess(toRemove);
    return toRemove;
  }

  /// Wipes all active debts and their bonuses on restart.
  void reset() {
    activeDebts.clear();
    pendingNotices.clear();
  }
}
