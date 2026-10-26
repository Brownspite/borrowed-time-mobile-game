import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class DashBootsLoan extends Loan {
  const DashBootsLoan()
      : super(
          id: 'dash_boots',
          name: 'Dash Boots',
          description: 'Dash cooldown reduced by 50%',
          debtDescription: 'Dash disabled, enemies +15% speed',
          dueInWaves: LoanTuning.dashBootsDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.playerStats.dashCooldown *= LoanTuning.dashCooldownBonusMultiplier;
    game.player.dashEnabled = true;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    game.player.dashEnabled = false;
    game.enemySpeedMultiplier +=
        LoanTuning.dashEnemySpeedPenaltyFraction * penaltyMultiplier;
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.playerStats.dashCooldown /= LoanTuning.dashCooldownBonusMultiplier;
  }
}
