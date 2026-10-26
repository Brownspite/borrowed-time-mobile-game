import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class TripleShotLoan extends Loan {
  const TripleShotLoan()
      : super(
          id: 'triple_shot',
          name: 'Triple Shot',
          description: 'Fire 3 bullets simultaneously in a spread',
          debtDescription: 'A random other upgrade is repossessed',
          dueInWaves: LoanTuning.tripleShotDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      extraProjectiles: game.player.bulletConfig.extraProjectiles +
          LoanTuning.tripleShotExtraProjectiles,
    );
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    // Repossesses another active upgrade
    game.debtManager.repossessRandomOther(excludingId: id);
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      extraProjectiles: math.max(
        0,
        game.player.bulletConfig.extraProjectiles -
            LoanTuning.tripleShotExtraProjectiles,
      ),
    );
  }
}
