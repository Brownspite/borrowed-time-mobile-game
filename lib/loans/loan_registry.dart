import 'loan.dart';
import 'loan_big_heart.dart';
import 'loan_dash_boots.dart';
import 'loan_double_damage.dart';
import 'loan_energy_shield.dart';
import 'loan_explosive_kills.dart';
import 'loan_giant_bullets.dart';
import 'loan_homing_bullets.dart';
import 'loan_lifesteal.dart';
import 'loan_piercing_shots.dart';
import 'loan_rapid_fire.dart';
import 'loan_score_x2.dart';
import 'loan_second_wind.dart';
import 'loan_speed_boost.dart';
import 'loan_time_slow_aura.dart';
import 'loan_triple_shot.dart';

export 'active_debt.dart';
export 'debt_manager.dart';
export 'loan.dart';
export 'loan_big_heart.dart';
export 'loan_constants.dart';
export 'loan_dash_boots.dart';
export 'loan_double_damage.dart';
export 'loan_energy_shield.dart';
export 'loan_explosive_kills.dart';
export 'loan_giant_bullets.dart';
export 'loan_homing_bullets.dart';
export 'loan_lifesteal.dart';
export 'loan_piercing_shots.dart';
export 'loan_rapid_fire.dart';
export 'loan_score_x2.dart';
export 'loan_second_wind.dart';
export 'loan_speed_boost.dart';
export 'loan_time_slow_aura.dart';
export 'loan_triple_shot.dart';

/// Central registry housing all 15 loan definitions.
abstract class LoanRegistry {
  static const List<Loan> _loans = [
    DoubleDamageLoan(),
    DashBootsLoan(),
    HomingBulletsLoan(),
    RapidFireLoan(),
    BigHeartLoan(),
    EnergyShieldLoan(),
    TripleShotLoan(),
    PiercingShotsLoan(),
    TimeSlowAuraLoan(),
    LifestealLoan(),
    GiantBulletsLoan(),
    SpeedBoostLoan(),
    ScoreX2Loan(),
    ExplosiveKillsLoan(),
    SecondWindLoan(),
  ];

  /// Returns an unmodifiable list of all registered loans.
  static List<Loan> getAll() => List.unmodifiable(_loans);

  /// Looks up a loan by its unique identifier.
  static Loan? getById(String id) {
    for (final loan in _loans) {
      if (loan.id == id) return loan;
    }
    return null;
  }

  /// Returns loans that are not already active in [activeLoanIds].
  static List<Loan> getAvailable(Iterable<String> activeLoanIds) {
    final activeSet = activeLoanIds.toSet();
    return _loans.where((loan) => !activeSet.contains(loan.id)).toList();
  }
}
