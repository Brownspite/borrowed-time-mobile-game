import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class DoubleDamageLoan extends Loan {
  const DoubleDamageLoan()
      : super(
          id: 'double_damage',
          name: 'Double Damage',
          description: '+100% damage to all shots',
          debtDescription: 'Lose 30% max HP',
          dueInWaves: LoanTuning.doubleDamageDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.playerStats.damage *= LoanTuning.doubleDamageMultiplier;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    final lossFraction = (LoanTuning.doubleDamageHpPenaltyFraction *
            penaltyMultiplier)
        .clamp(0.0, 0.95);
    game.playerStats.maxHp =
        math.max(1.0, game.playerStats.maxHp * (1.0 - lossFraction));
    if (game.playerStats.hp > game.playerStats.maxHp) {
      game.playerStats.hp = game.playerStats.maxHp;
    }
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.playerStats.damage /= LoanTuning.doubleDamageMultiplier;
  }
}
