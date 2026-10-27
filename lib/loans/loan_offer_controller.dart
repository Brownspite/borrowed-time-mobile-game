import 'dart:math' as math;

import 'loan.dart';
import 'loan_registry.dart';

/// Manages the selection and sequential progression of 3 between-wave loan offer cards.
class LoanOfferController {
  LoanOfferController({
    required List<String> activeLoanIds,
    int count = 3,
    math.Random? random,
  }) {
    _offers = _pickRandomOffers(activeLoanIds, count, random ?? math.Random());
  }

  late final List<Loan> _offers;
  int _currentIndex = 0;
  final List<Loan> _acceptedLoans = [];
  final List<Loan> _refusedLoans = [];

  List<Loan> get offers => List.unmodifiable(_offers);
  int get totalOffers => _offers.length;
  int get currentIndex => _currentIndex;
  List<Loan> get acceptedLoans => List.unmodifiable(_acceptedLoans);
  List<Loan> get refusedLoans => List.unmodifiable(_refusedLoans);

  /// True if there are no more cards to offer in this wave break.
  bool get isComplete => _currentIndex >= _offers.length;

  /// The current loan card to display, or null if all offers are done.
  Loan? get currentLoan => isComplete ? null : _offers[_currentIndex];

  /// Records the decision for [currentLoan] (true = TAKE, false = REFUSE).
  /// Advances [currentIndex] to the next card.
  Loan? recordDecision({required bool accepted}) {
    if (isComplete) return null;
    final loan = _offers[_currentIndex];
    if (accepted) {
      _acceptedLoans.add(loan);
    } else {
      _refusedLoans.add(loan);
    }
    _currentIndex++;
    return loan;
  }

  /// Selects [count] unique, unowned loans randomly from the catalog.
  static List<Loan> _pickRandomOffers(
    List<String> activeLoanIds,
    int count,
    math.Random rng,
  ) {
    final available = LoanRegistry.getAvailable(activeLoanIds);
    if (available.isEmpty) return const [];

    final pool = List<Loan>.from(available)..shuffle(rng);
    return pool.take(count).toList();
  }
}
