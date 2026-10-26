import 'loan.dart';

/// Represents an accepted loan currently tracked by the DebtManager.
class ActiveDebt {
  final Loan loan;
  int remainingWaves;
  int overdueWaves;
  bool penaltyApplied;
  double currentPenaltyMultiplier;

  ActiveDebt({
    required this.loan,
    required this.remainingWaves,
    this.overdueWaves = 0,
    this.penaltyApplied = false,
    this.currentPenaltyMultiplier = 1.0,
  });

  bool get isDue => remainingWaves <= 0;
  bool get isOverdue => overdueWaves > 0;
}
