import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class LifestealLoan extends Loan {
  const LifestealLoan()
      : super(
          id: 'lifesteal',
          name: 'Lifesteal',
          description: 'Heal +3 HP on every enemy kill',
          debtDescription: 'Score gains reduced by 50%',
          dueInWaves: LoanTuning.lifestealDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.player.lifestealAmount += LoanTuning.lifestealHeal;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    final reduction = (LoanTuning.lifestealScorePenaltyFraction *
            penaltyMultiplier)
        .clamp(0.0, 0.9);
    game.scoreMultiplier =
        math.max(0.1, game.scoreMultiplier * (1.0 - reduction));
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.player.lifestealAmount =
        math.max(0.0, game.player.lifestealAmount - LoanTuning.lifestealHeal);
  }
}
