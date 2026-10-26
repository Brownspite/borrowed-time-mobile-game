import '../game/borrowed_time_game.dart';
import 'loan_constants.dart';

/// Base abstract class for all upgrades/loans.
/// Each loan provides an upfront bonus and incurs a debt that comes due
/// after [dueInWaves] waves. Overdue debts escalate in severity.
abstract class Loan {
  final String id;
  final String name;
  final String description; // the bonus description
  final String debtDescription; // the penalty description
  final int dueInWaves;

  const Loan({
    required this.id,
    required this.name,
    required this.description,
    required this.debtDescription,
    required this.dueInWaves,
  });

  /// Applies the upfront bonus effect to the game/player.
  void applyBonus(BorrowedTimeGame game);

  /// Applies the debt penalty to the game/player.
  /// [penaltyMultiplier] starts at 1.0 when the debt first comes due, and
  /// increases with each wave that the debt remains overdue.
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0});

  /// Reverses the bonus effect, allowing this loan to be repossessed.
  void removeBonus(BorrowedTimeGame game);

  /// Computes a scaling factor for overdue penalties.
  /// When overdueWaves <= 0, multiplier is 1.0.
  /// Each overdue wave adds [LoanTuning.overduePenaltyGrowth] (e.g. +0.5).
  double calculatePenaltyMultiplier(int overdueWaves) {
    if (overdueWaves <= 0) return 1.0;
    return 1.0 + (overdueWaves * LoanTuning.overduePenaltyGrowth);
  }
}
