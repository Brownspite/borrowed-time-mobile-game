import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class ExplosiveKillsLoan extends Loan {
  const ExplosiveKillsLoan()
      : super(
          id: 'explosive_kills',
          name: 'Explosive Kills',
          description: 'Enemies explode on death, damaging nearby enemies',
          debtDescription: 'Your own explosions can hurt you',
          dueInWaves: LoanTuning.explosiveKillsDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.explosiveKillsEnabled = true;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    game.explosionsHurtPlayer = true;
    game.explosionSelfDamage =
        LoanTuning.explosionSelfDamage * penaltyMultiplier;
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.explosiveKillsEnabled = false;
  }
}
