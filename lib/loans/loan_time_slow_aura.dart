import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class TimeSlowAuraLoan extends Loan {
  const TimeSlowAuraLoan()
      : super(
          id: 'time_slow_aura',
          name: 'Time Slow Aura',
          description: 'Enemies near you move 50% slower',
          debtDescription: 'All enemies permanently move 20% faster',
          dueInWaves: LoanTuning.timeSlowAuraDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.player.hasSlowAura = true;
    game.player.slowAuraRadius = LoanTuning.slowAuraRadius;
    game.player.slowAuraFactor = LoanTuning.slowAuraFactor;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    game.enemySpeedMultiplier +=
        LoanTuning.slowAuraEnemySpeedPenaltyFraction * penaltyMultiplier;
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.player.hasSlowAura = false;
  }
}
