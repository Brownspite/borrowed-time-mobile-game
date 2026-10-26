import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class BigHeartLoan extends Loan {
  const BigHeartLoan()
      : super(
          id: 'big_heart',
          name: 'Big Heart',
          description: '+50 max HP and instant heal',
          debtDescription: 'Lose 50 max HP',
          dueInWaves: LoanTuning.bigHeartDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.playerStats.maxHp += LoanTuning.bigHeartHpBonus;
    game.playerStats.hp += LoanTuning.bigHeartHpBonus;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    final loss = LoanTuning.bigHeartHpPenalty * penaltyMultiplier;
    game.playerStats.maxHp = math.max(1.0, game.playerStats.maxHp - loss);
    if (game.playerStats.hp > game.playerStats.maxHp) {
      game.playerStats.hp = game.playerStats.maxHp;
    }
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.playerStats.maxHp =
        math.max(1.0, game.playerStats.maxHp - LoanTuning.bigHeartHpBonus);
    if (game.playerStats.hp > game.playerStats.maxHp) {
      game.playerStats.hp = game.playerStats.maxHp;
    }
  }
}
