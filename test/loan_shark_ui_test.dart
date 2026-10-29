import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:borrowed_time/game/borrowed_time_game.dart';
import 'package:borrowed_time/loans/loan_double_damage.dart';
import 'package:borrowed_time/loans/loan_shark.dart';
import 'package:borrowed_time/loans/loan_shark_personality.dart';
import 'package:borrowed_time/ui/between_waves_overlay.dart';
import 'package:borrowed_time/ui/dead_overlay.dart';
import 'package:borrowed_time/ui/debt_repayment_panel.dart';
import 'package:borrowed_time/ui/loan_shark_avatar.dart';
import 'package:borrowed_time/ui/loan_shark_speech_bubble.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Loan Shark UI & Widget Tests', () {
    testWidgets('LoanSharkAvatar renders correct emoji and mood badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoanSharkAvatar(
                personality: LoanSharkPersonality.politeBanker,
                mood: SharkMood.calm,
              ),
            ),
          ),
        ),
      );

      expect(find.text('🧐'), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_satisfied_outlined), findsOneWidget);
    });

    testWidgets('LoanSharkSpeechBubble reflects speaker name, mood badge, and quote', (tester) async {
      final shark = LoanShark(initialPersonality: LoanSharkPersonality.friendlyMobster);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoanSharkSpeechBubble(
                loanShark: shark,
                mood: SharkMood.annoyed,
                message: 'Quit stalling. I got three other hits to schedule.',
              ),
            ),
          ),
        ),
      );

      expect(find.text(shark.displayName.toUpperCase()), findsOneWidget);
      expect(find.text('ANNOYED'), findsOneWidget);
      expect(find.text('“Quit stalling. I got three other hits to schedule.”'), findsOneWidget);
      expect(find.text('😎'), findsOneWidget);
    });

    testWidgets('DeadOverlay renders LoanShark speech bubble with playerDied line', (tester) async {
      final shark = LoanShark(initialPersonality: LoanSharkPersonality.boredBureaucrat);
      shark.speak(SharkDialogueCategory.playerDied, debtLevel: 10, lineIndex: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeadOverlay(
              score: 1500,
              wave: 5,
              onRestart: () {},
              loanShark: shark,
              debtLevel: 10,
            ),
          ),
        ),
      );

      expect(find.text('YOU DIED'), findsOneWidget);
      expect(find.byType(LoanSharkSpeechBubble), findsOneWidget);
      expect(find.text(shark.displayName.toUpperCase()), findsOneWidget);
      expect(find.text('THREATENING'), findsOneWidget);
      expect(find.text('😐'), findsOneWidget);
    });

    testWidgets('BetweenWavesOverlay displays shark and updates line on take / refuse', (tester) async {
      final game = BorrowedTimeGame();
      game.onGameResize(Vector2(400, 800));
      await game.onLoad();
      game.gameState.wave = 1;
      game.loanShark.personality = LoanSharkPersonality.unhingedGambler;
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

      // Loan shark bubble is visible with initial loanOffered line
      expect(find.byType(LoanSharkSpeechBubble), findsOneWidget);
      expect(find.text('LUCKY BONES'), findsOneWidget);
      expect(find.text('CALM'), findsOneWidget);
      expect(find.text('🤪'), findsOneWidget);

      // Tap TAKE LOAN button to accept first offer
      await tester.tap(find.text('TAKE LOAN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Shark should have spoken loanTaken line
      expect(game.loanShark.lastCategory, equals(SharkDialogueCategory.loanTaken));
    });

    testWidgets('DebtRepaymentPanel renders loan shark commentary', (tester) async {
      final game = BorrowedTimeGame();
      game.onGameResize(Vector2(400, 800));
      await game.onLoad();
      game.debtManager.addLoan(const DoubleDamageLoan());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtRepaymentPanel(
              game: game,
              onDebtPaid: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('DEBT REPAYMENT PANEL'), findsOneWidget);
      expect(find.byType(LoanSharkSpeechBubble), findsOneWidget);
    });
  });
}
