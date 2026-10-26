import '../core/constants.dart';
import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class HomingBulletsLoan extends Loan {
  const HomingBulletsLoan()
      : super(
          id: 'homing_bullets',
          name: 'Homing Bullets',
          description: 'Bullets seek nearest enemies',
          debtDescription: 'Bullets fly 30% slower',
          dueInWaves: LoanTuning.homingBulletsDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      isHoming: true,
      homingStrength: LoanTuning.homingStrength,
    );
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    final penaltyFrac = (LoanTuning.homingBulletSpeedPenalty *
            penaltyMultiplier)
        .clamp(0.0, 0.8);
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      speed: GameConstants.bulletSpeed * (1.0 - penaltyFrac),
    );
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.player.bulletConfig = game.player.bulletConfig.copyWith(
      isHoming: false,
    );
  }
}
