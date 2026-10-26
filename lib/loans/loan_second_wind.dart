import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class SecondWindLoan extends Loan {
  const SecondWindLoan()
      : super(
          id: 'second_wind',
          name: 'Second Wind',
          description: 'Cheat death once: revive with 50% HP',
          debtDescription: 'Starting HP next wave is 1',
          dueInWaves: LoanTuning.secondWindDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.player.secondWindCharges += 1;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    game.setNextWaveStartingHp(LoanTuning.secondWindPenaltyStartingHp);
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.player.secondWindCharges =
        math.max(0, game.player.secondWindCharges - 1);
  }
}
