import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:borrowed_time/game/borrowed_time_game.dart';
import 'package:borrowed_time/loans/loan_registry.dart';
import 'package:borrowed_time/ui/between_waves_overlay.dart';
import 'package:borrowed_time/ui/loan_action_buttons.dart';
import 'package:borrowed_time/ui/swipable_loan_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BorrowedTimeGame game;

  setUp(() async {
    game = BorrowedTimeGame();
    game.onGameResize(Vector2(400, 800));
    await game.onLoad();
  });

  group('BetweenWavesOverlay UI & Swipe Interactions', () {
    testWidgets('renders intro banner when wave == 0 and no offers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BetweenWavesOverlay(
              waveNumber: 0,
              game: game,
            ),
          ),
        ),
      );

      expect(find.text('Get ready…'), findsOneWidget);
      expect(find.text('Wave 1 incoming'), findsOneWidget);
      expect(find.byType(SwipableLoanCard), findsNothing);
    });

    testWidgets('renders loan card and action buttons after wave clear', (tester) async {
      game.gameState.wave = 1;
      game.startLoanOffers();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BetweenWavesOverlay(
              waveNumber: 1,
              game: game,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Wave 1 cleared'), findsOneWidget);
      expect(find.text('THE LOAN SHARK OFFERS UPGRADES'), findsOneWidget);
      expect(find.byType(SwipableLoanCard), findsOneWidget);
      expect(find.byType(LoanActionButtons), findsOneWidget);
      expect(find.text('OFFER 1 OF 3'), findsOneWidget);

      final currentLoan = game.currentOfferController!.currentLoan!;
      expect(find.text(currentLoan.name), findsOneWidget);
      expect(find.text(currentLoan.description), findsOneWidget);
      expect(find.text(currentLoan.debtDescription), findsOneWidget);
    });

    Future<void> pumpAnimation(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
    }

    testWidgets('swiping card LEFT takes loan, applies bonus immediately, and advances card', (tester) async {
      game.gameState.wave = 1;
      game.startLoanOffers();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BetweenWavesOverlay(
              waveNumber: 1,
              game: game,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstLoan = game.currentOfferController!.currentLoan!;
      expect(game.debtManager.activeDebts.isEmpty, isTrue);

      // Drag card to the LEFT (swipe left = TAKE)
      final cardFinder = find.byType(SwipableLoanCard);
      await tester.drag(cardFinder, const Offset(-150, 0));
      await pumpAnimation(tester);

      // First loan was taken immediately
      expect(game.debtManager.activeDebts.length, 1);
      expect(game.debtManager.activeDebts.first.loan.id, firstLoan.id);

      // Advanced to offer 2
      expect(find.text('OFFER 2 OF 3'), findsOneWidget);
    });

    testWidgets('swiping card RIGHT refuses loan and advances to next card without applying', (tester) async {
      game.gameState.wave = 1;
      game.startLoanOffers();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BetweenWavesOverlay(
              waveNumber: 1,
              game: game,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstLoan = game.currentOfferController!.currentLoan!;

      // Drag card to the RIGHT (swipe right = REFUSE)
      final cardFinder = find.byType(SwipableLoanCard);
      await tester.drag(cardFinder, const Offset(150, 0));
      await pumpAnimation(tester);

      // First loan was NOT taken
      expect(game.debtManager.activeDebts.isEmpty, isTrue);
      expect(game.currentOfferController!.refusedLoans.contains(firstLoan), isTrue);

      // Advanced to offer 2
      expect(find.text('OFFER 2 OF 3'), findsOneWidget);
    });

    testWidgets('fallback buttons take and refuse loans and complete 3-offer sequence', (tester) async {
      game.gameState.wave = 1;
      game.startLoanOffers();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BetweenWavesOverlay(
              waveNumber: 1,
              game: game,
            ),
          ),
        ),
      );
      await tester.pump();

      // Card 1: Tap TAKE button
      final card1 = game.currentOfferController!.currentLoan!;
      await tester.tap(find.text('TAKE LOAN'));
      await pumpAnimation(tester);

      expect(game.debtManager.activeDebts.length, 1);
      expect(game.debtManager.activeDebts.first.loan.id, card1.id);
      expect(find.text('OFFER 2 OF 3'), findsOneWidget);

      // Card 2: Tap REFUSE button
      await tester.tap(find.text('REFUSE'));
      await pumpAnimation(tester);

      expect(game.debtManager.activeDebts.length, 1); // still only 1 active
      expect(find.text('OFFER 3 OF 3'), findsOneWidget);

      // Card 3: Tap TAKE button
      final card3 = game.currentOfferController!.currentLoan!;
      await tester.tap(find.text('TAKE LOAN'));
      await pumpAnimation(tester);

      // All 3 cards completed!
      expect(game.currentOfferController, isNull);
      expect(game.debtManager.activeDebts.length, 2);
      expect(game.debtManager.activeDebts.any((d) => d.loan.id == card3.id), isTrue);
    });

    testWidgets('never offers loans that player already possesses', (tester) async {
      // Give player double_damage beforehand
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      game.debtManager.addLoan(doubleDamage);

      game.gameState.wave = 1;
      game.startLoanOffers();

      final offers = game.currentOfferController!.offers;
      expect(offers.any((l) => l.id == 'double_damage'), isFalse);
    });
  });
}
