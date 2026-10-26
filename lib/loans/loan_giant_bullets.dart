import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class GiantBulletsLoan extends Loan {
  const GiantBulletsLoan()
      : super(
          id: 'giant_bullets',
          name: 'Giant Bullets',
          description: '+120% bullet radius & +15 damage',
          debtDescription: 'Player moves 25% slower',
          dueInWaves: LoanTuning.giantBulletsDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      radius: game.player.bulletConfig.radius *
          LoanTuning.giantBulletRadiusMultiplier,
      damage:
          game.player.bulletConfig.damage + LoanTuning.giantBulletDamageBonus,
    );
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    final reduction = (LoanTuning.giantBulletPlayerSpeedPenaltyFraction *
            penaltyMultiplier)
        .clamp(0.0, 0.8);
    game.playerStats.moveSpeed =
        math.max(50.0, game.playerStats.moveSpeed * (1.0 - reduction));
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      radius: game.player.bulletConfig.radius /
          LoanTuning.giantBulletRadiusMultiplier,
      damage:
          game.player.bulletConfig.damage - LoanTuning.giantBulletDamageBonus,
    );
  }
}
