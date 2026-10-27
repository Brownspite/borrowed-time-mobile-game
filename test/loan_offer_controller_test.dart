import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:borrowed_time/loans/loan_offer_controller.dart';
import 'package:borrowed_time/loans/loan_registry.dart';

void main() {
  group('LoanOfferController', () {
    test('selects exactly 3 distinct unowned loans', () {
      final controller = LoanOfferController(
        activeLoanIds: ['double_damage'],
        count: 3,
        random: math.Random(42),
      );

      expect(controller.totalOffers, 3);
      expect(controller.currentIndex, 0);
      expect(controller.isComplete, isFalse);

      final offerIds = controller.offers.map((l) => l.id).toList();
      expect(offerIds.toSet().length, 3, reason: 'All 3 offers must be distinct');
      expect(offerIds.contains('double_damage'), isFalse, reason: 'Cannot offer active loans');
    });

    test('step through 3 cards records choices and finishes', () {
      final controller = LoanOfferController(
        activeLoanIds: [],
        count: 3,
        random: math.Random(100),
      );

      expect(controller.totalOffers, 3);

      final card1 = controller.currentLoan!;
      final res1 = controller.recordDecision(accepted: true);
      expect(res1, equals(card1));
      expect(controller.acceptedLoans, [card1]);
      expect(controller.currentIndex, 1);
      expect(controller.isComplete, isFalse);

      final card2 = controller.currentLoan!;
      final res2 = controller.recordDecision(accepted: false);
      expect(res2, equals(card2));
      expect(controller.refusedLoans, [card2]);
      expect(controller.currentIndex, 2);
      expect(controller.isComplete, isFalse);

      final card3 = controller.currentLoan!;
      final res3 = controller.recordDecision(accepted: true);
      expect(res3, equals(card3));
      expect(controller.acceptedLoans, [card1, card3]);
      expect(controller.currentIndex, 3);
      expect(controller.isComplete, isTrue);
      expect(controller.currentLoan, isNull);

      // Attempting after complete returns null
      expect(controller.recordDecision(accepted: false), isNull);
    });

    test('handles edge case when fewer than 3 loans remain in registry', () {
      final allIds = LoanRegistry.getAll().map((l) => l.id).toList();
      // Leave only 1 loan unowned
      final activeIds = allIds.sublist(1);

      final controller = LoanOfferController(
        activeLoanIds: activeIds,
        count: 3,
      );

      expect(controller.totalOffers, 1);
      expect(controller.currentLoan!.id, allIds.first);
    });
  });
}
