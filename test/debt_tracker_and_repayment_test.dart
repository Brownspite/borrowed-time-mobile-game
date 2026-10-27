import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:borrowed_time/game/borrowed_time_game.dart';
import 'package:borrowed_time/loans/loan_registry.dart';
import 'package:borrowed_time/ui/compact_debt_hud.dart';
import 'package:borrowed_time/ui/debt_banner_widget.dart';
import 'package:borrowed_time/ui/debt_repayment_panel.dart';
import 'package:borrowed_time/ui/hud_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BorrowedTimeGame game;

  setUp(() async {
    game = BorrowedTimeGame();
    game.onGameResize(Vector2(400, 800));
    await game.onLoad();
  });

  group('CompactDebtHud & Countdown Display', () {
    testWidgets('empty state renders nothing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactDebtHud(debtManager: game.debtManager),
          ),
        ),
      );

      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('renders active debts with countdowns', (tester) async {
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      final rapidFire = LoanRegistry.getById('rapid_fire')!;
      game.debtManager.addLoan(doubleDamage); // 3 waves left
      final debt2 = game.debtManager.addLoan(rapidFire);
      debt2.remainingWaves = 2; // 2 waves left

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactDebtHud(debtManager: game.debtManager),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(doubleDamage.name), findsOneWidget);
      expect(find.text('3w left'), findsOneWidget);

      expect(find.text(rapidFire.name), findsOneWidget);
      expect(find.text('2w left'), findsOneWidget);
    });

    testWidgets('debts due next wave pulse red with warning icon', (tester) async {
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      final debt = game.debtManager.addLoan(doubleDamage);
      debt.remainingWaves = 1; // due next wave!

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactDebtHud(debtManager: game.debtManager),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1w left'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });

  group('Debt Notice Banners (DEBT COLLECTED & INTEREST ADDED)', () {
    test('onWaveCleared creates DEBT COLLECTED notice when countdown hits 0', () {
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      final debt = game.debtManager.addLoan(doubleDamage);
      debt.remainingWaves = 1;

      expect(game.debtManager.pendingNotices, isEmpty);

      // Cleared wave -> countdown hits 0 -> penalty applied
      game.debtManager.onWaveCleared();

      expect(game.debtManager.pendingNotices.length, 1);
      final notice = game.debtManager.pendingNotices.first;
      expect(notice.bannerTitle, 'DEBT COLLECTED');
      expect(notice.isOverdue, isFalse);
      expect(notice.loanName, doubleDamage.name);
      expect(notice.penaltyDescription, doubleDamage.debtDescription);
    });

    test('onWaveCleared creates INTEREST ADDED notice when already due', () {
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      final debt = game.debtManager.addLoan(doubleDamage);
      debt.remainingWaves = 0; // already due

      game.debtManager.onWaveCleared(); // now 1 wave overdue

      expect(game.debtManager.pendingNotices.length, 1);
      final notice = game.debtManager.pendingNotices.first;
      expect(notice.bannerTitle, 'INTEREST ADDED');
      expect(notice.isOverdue, isTrue);
      expect(notice.overdueWaves, 1);
      expect(notice.formattedPenalty, contains('x1.5'));
    });

    testWidgets('DebtBannerWidget renders notices with headline and details', (tester) async {
      final notice = DebtNotice(
        loanId: 'double_damage',
        loanName: 'Double Damage',
        penaltyDescription: 'lose 30% max HP',
        isOverdue: false,
        overdueWaves: 0,
        multiplier: 1.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebtBannerWidget(
              notices: [notice],
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('DEBT COLLECTED'), findsOneWidget);
      expect(find.text('Double Damage: lose 30% max HP'), findsOneWidget);
      expect(find.byIcon(Icons.gavel), findsOneWidget);
    });
  });

  group('DebtRepaymentPanel & Early Repayment', () {
    testWidgets('Edge case: empty debts panel shows friendly empty state', (tester) async {
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

      expect(find.text('NO ACTIVE DEBTS'), findsOneWidget);
      expect(find.text('ACTIVE DEBTS'), findsOneWidget);
      expect(find.text('YOUR HP'), findsOneWidget);
    });

    testWidgets('Pay early with HP deducts HP, clears debt, and keeps bonus', (tester) async {
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      game.debtManager.addLoan(doubleDamage);
      game.playerStats.hp = 100.0;
      game.playerStats.maxHp = 100.0;

      final damageWithBonus = game.playerStats.damage; // 50.0

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

      expect(find.text('Pay 25 HP'), findsOneWidget);

      // Tap Pay 25 HP
      await tester.tap(find.text('Pay 25 HP'));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('CONFIRM REPAYMENT'), findsOneWidget);
      expect(find.text('CONFIRM PAYMENT'), findsOneWidget);

      // Tap confirm
      await tester.tap(find.text('CONFIRM PAYMENT'));
      await tester.pumpAndSettle();

      // Debt is cleanly resolved
      expect(game.debtManager.activeDebts, isEmpty);
      expect(game.playerStats.hp, 75.0);
      // Double damage bonus was NOT lost!
      expect(game.playerStats.damage, damageWithBonus);
    });

    testWidgets('Pay early with Score deducts score, clears debt, and keeps bonus', (tester) async {
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      game.debtManager.addLoan(doubleDamage);
      game.gameState.score = 120;

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

      expect(find.text('Pay 50 Score'), findsOneWidget);

      // Tap Pay 50 Score
      await tester.tap(find.text('Pay 50 Score'));
      await tester.pumpAndSettle();

      // Tap confirm
      await tester.tap(find.text('CONFIRM PAYMENT'));
      await tester.pumpAndSettle();

      // Debt resolved and score deducted
      expect(game.debtManager.activeDebts, isEmpty);
      expect(game.gameState.score, 70);
      // Bonus retained
      expect(game.playerStats.damage, 50.0);
    });

    testWidgets('Sacrifice upgrade removes sacrificial upgrade and keeps paid bonus', (tester) async {
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      final rapidFire = LoanRegistry.getById('rapid_fire')!;

      game.debtManager.addLoan(doubleDamage);
      game.debtManager.addLoan(rapidFire);

      expect(game.debtManager.activeDebts.length, 2);
      final initialFireRate = game.playerStats.fireRate;

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

      // Tap Sacrifice Upgrade for Double Damage
      final sacrificeButtons = find.text('Sacrifice Upgrade');
      expect(sacrificeButtons, findsNWidgets(2));
      await tester.tap(sacrificeButtons.first);
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('CONFIRM REPAYMENT'), findsOneWidget);
      await tester.tap(find.text('CONFIRM PAYMENT'));
      await tester.pumpAndSettle();

      // Both debts are removed: doubleDamage was paid, rapidFire was sacrificed
      expect(game.debtManager.activeDebts, isEmpty);
      // doubleDamage bonus is kept!
      expect(game.playerStats.damage, 50.0);
      // rapidFire bonus is revoked!
      expect(game.playerStats.fireRate, lessThan(initialFireRate));
    });

    testWidgets('Edge cases: cannot afford HP or score disables buttons', (tester) async {
      final doubleDamage = LoanRegistry.getById('double_damage')!;
      game.debtManager.addLoan(doubleDamage);

      // Player has insufficient HP (10 HP, cost is 25 HP) and insufficient score (20, cost is 50)
      game.playerStats.hp = 10.0;
      game.playerStats.maxHp = 100.0;
      game.gameState.score = 20;

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

      // Disabled button texts
      expect(find.text('Need > 25 HP'), findsOneWidget);
      expect(find.text('Need 50 Score'), findsOneWidget);
      expect(find.text('No Upgrades to Sacrifice'), findsOneWidget);
    });
  });
}
