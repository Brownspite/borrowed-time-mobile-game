import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class ScoreX2Loan extends Loan {
  const ScoreX2Loan()
      : super(
          id: 'score_x2',
          name: 'Score x2',
          description: 'Doubles all score gains',
          debtDescription: 'Lose 20% current HP now',
          dueInWaves: LoanTuning.scoreX2DueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.scoreMultiplier *= LoanTuning.scoreX2Multiplier;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    final lossFrac =
        (LoanTuning.scoreX2HpLossFraction * penaltyMultiplier).clamp(0.0, 0.95);
    final loss = game.playerStats.hp * lossFrac;
    game.playerStats.hp = math.max(1.0, game.playerStats.hp - loss);
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.scoreMultiplier /= LoanTuning.scoreX2Multiplier;
  }
}
