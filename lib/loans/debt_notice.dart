/// Notification payload generated when a debt comes due or accumulates overdue interest.
class DebtNotice {
  const DebtNotice({
    required this.loanId,
    required this.loanName,
    required this.penaltyDescription,
    required this.isOverdue,
    required this.overdueWaves,
    required this.multiplier,
  });

  final String loanId;
  final String loanName;
  final String penaltyDescription;
  final bool isOverdue;
  final int overdueWaves;
  final double multiplier;

  /// Header title for the dramatic collection banner.
  String get bannerTitle => isOverdue ? 'INTEREST ADDED' : 'DEBT COLLECTED';

  /// Formatted description of the penalty applied.
  String get formattedPenalty {
    if (isOverdue) {
      return '$penaltyDescription (x${multiplier.toStringAsFixed(1)} penalty)';
    }
    return penaltyDescription;
  }
}
