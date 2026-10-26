import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class EnergyShieldLoan extends Loan {
  const EnergyShieldLoan()
      : super(
          id: 'energy_shield',
          name: 'Energy Shield',
          description: 'Absorbs the next 3 hits',
          debtDescription: '25% more enemies per wave',
          dueInWaves: LoanTuning.energyShieldDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.player.shieldHits += LoanTuning.energyShieldHits;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    game.enemyCountMultiplier +=
        LoanTuning.energyShieldEnemyIncreaseFraction * penaltyMultiplier;
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.player.shieldHits = 0;
  }
}
