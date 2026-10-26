import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class SpeedBoostLoan extends Loan {
  const SpeedBoostLoan()
      : super(
          id: 'speed_boost',
          name: 'Speed Boost',
          description: '+50% player movement speed',
          debtDescription: 'Controls reverse for 8 seconds',
          dueInWaves: LoanTuning.speedBoostDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.playerStats.moveSpeed *= LoanTuning.speedBoostMultiplier;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    game.player.reverseControls(
      LoanTuning.reverseControlsDuration * penaltyMultiplier,
    );
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.playerStats.moveSpeed /= LoanTuning.speedBoostMultiplier;
  }
}
