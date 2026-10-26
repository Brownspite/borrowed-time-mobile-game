import 'dart:math' as math;

import '../game/borrowed_time_game.dart';
import 'loan.dart';
import 'loan_constants.dart';

class RapidFireLoan extends Loan {
  const RapidFireLoan()
      : super(
          id: 'rapid_fire',
          name: 'Rapid Fire',
          description: '+75% fire rate',
          debtDescription: 'Fire rate cut in half',
          dueInWaves: LoanTuning.rapidFireDueInWaves,
        );

  @override
  void applyBonus(BorrowedTimeGame game) {
    game.playerStats.fireRate *= LoanTuning.rapidFireMultiplier;
  }

  @override
  void applyPenalty(BorrowedTimeGame game, {double penaltyMultiplier = 1.0}) {
    final cutFraction = (LoanTuning.rapidFirePenaltyFraction *
            penaltyMultiplier)
        .clamp(0.1, 0.9);
    game.playerStats.fireRate =
        math.max(0.2, game.playerStats.fireRate * (1.0 - cutFraction));
  }

  @override
  void removeBonus(BorrowedTimeGame game) {
    game.playerStats.fireRate /= LoanTuning.rapidFireMultiplier;
  }
}
