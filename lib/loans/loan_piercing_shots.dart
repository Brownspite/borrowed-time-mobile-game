import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class PiercingShotsLoan extends Loan {
  const PiercingShotsLoan()
      : super(
          id: 'piercing_shots',
          name: 'Piercing Shots',
          description: 'Bullets pierce through 2 additional enemies',
          debtDescription: 'Arena shrinks 20%',
          dueInWaves: LoanTuning.piercingShotsDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      pierceCount: game.player.bulletConfig.pierceCount +
          LoanTuning.piercingShotExtraPierce,
    );
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    final shrink =
        (LoanTuning.arenaShrinkFraction * penaltyMultiplier).clamp(0.0, 0.60);
    game.setArenaShrink(shrink);
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      pierceCount: math.max(
        1,
        game.player.bulletConfig.pierceCount -
            LoanTuning.piercingShotExtraPierce,
      ),
    );
  }
}
