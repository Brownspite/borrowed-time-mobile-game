import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:borrowed_time/components/bullet.dart';
import 'package:borrowed_time/components/enemy.dart';
import 'package:borrowed_time/core/game_phase.dart';
import 'package:borrowed_time/game/borrowed_time_game.dart';
import 'package:borrowed_time/game/wave_manager.dart';
import 'package:borrowed_time/ui/between_waves_overlay.dart';
import 'package:borrowed_time/ui/dead_overlay.dart';
import 'package:borrowed_time/ui/hud_overlay.dart';
import 'package:borrowed_time/ui/swipable_loan_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WaveManager Config Scaling', () {
    test('wave 1 is easy: few enemies, slow spawn, weak brutes, no runners', () {
      final config = buildWaveConfig(0); // wave 1
      expect(config.totalEnemies, 4);
      expect(config.spawnInterval, 2.0);
      expect(config.bruteHp, 30.0);
      expect(config.bruteSpeed, 70.0);
      expect(config.runnerFraction, 0.0);
    });

    test('wave 3 introduces runners: faster and weaker enemy type', () {
      final config = buildWaveConfig(2); // wave 3 (index 2)
      expect(config.runnerFraction, greaterThan(0.0));
      expect(config.runnerSpeed, greaterThan(config.bruteSpeed));
      expect(config.runnerHp, lessThan(config.bruteHp));
    });

    test('wave 8 feels hard: 16 enemies, 0.6s fast spawn, 120 HP brutes, fast runners', () {
      final config = buildWaveConfig(7); // wave 8 (index 7)
      expect(config.totalEnemies, 16);
      expect(config.spawnInterval, closeTo(0.6, 0.001));
      expect(config.bruteHp, 120.0);
      expect(config.bruteSpeed, 150.0);
      expect(config.runnerSpeed, 250.0);
      expect(config.runnerHp, 40.0);
      expect(config.runnerFraction, 0.45);
    });
  });

  group('Wave System & Run Flow Integration', () {
    testWidgets('game initializes with BetweenWaves overlay and transitions to wave 1', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(
        GameWidget<BorrowedTimeGame>(
          game: game,
          overlayBuilderMap: game.buildOverlayMap(),
          initialActiveOverlays: const [BorrowedTimeGame.initialOverlay],
        ),
      );
      await tester.pump();

      // Between waves overlay should be visible at launch
      expect(find.byType(BetweenWavesOverlay), findsOneWidget);
      expect(find.text('Get ready…'), findsOneWidget);
      expect(game.gameState.phase, GamePhase.betweenWaves);
      expect(game.gameState.wave, 0);

      // Advance past the 1.5s betweenWaves delay
      await tester.pump(const Duration(milliseconds: 1600));

      // Now playing wave 1, betweenWaves overlay dismissed
      expect(find.byType(BetweenWavesOverlay), findsNothing);
      expect(game.gameState.phase, GamePhase.playing);
      expect(game.gameState.wave, 1);
    });

    testWidgets('HUD overlay reflects score, hp bar, and wave number', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(
        GameWidget<BorrowedTimeGame>(
          game: game,
          overlayBuilderMap: game.buildOverlayMap(),
          initialActiveOverlays: const [BorrowedTimeGame.initialOverlay],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600)); // enter wave 1

      expect(find.byType(HudOverlay), findsOneWidget);
      expect(find.text('SCORE'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('WAVE'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Score increase and HP change reflect in HUD
      game.gameState.score = 50;
      game.playerStats.hp = 60;
      await tester.pump(const Duration(milliseconds: 150)); // past HUD refresh interval (0.1s)

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('wave clear shows "Wave X cleared" then starts next wave', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(
        GameWidget<BorrowedTimeGame>(
          game: game,
          overlayBuilderMap: game.buildOverlayMap(),
          initialActiveOverlays: const [BorrowedTimeGame.initialOverlay],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600)); // enter wave 1
      expect(game.gameState.phase, GamePhase.playing);
      expect(game.gameState.wave, 1);

      // Wave 1: 4 enemies spawn every 2.0s. Let's spawn and kill all 4 with bullets.
      for (int i = 0; i < 90; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        for (final enemy in game.children.whereType<EnemyComponent>().toList()) {
          if (!enemy.isRemoving) {
            enemy.takeDamage(100.0);
          }
        }
      }
      await tester.pump();

      // Wave 1 cleared!
      expect(game.gameState.phase, GamePhase.betweenWaves);
      expect(find.byType(BetweenWavesOverlay), findsOneWidget);
      expect(find.text('Wave 1 cleared'), findsOneWidget);
      expect(find.text('THE LOAN SHARK OFFERS UPGRADES'), findsOneWidget);
      expect(find.byType(SwipableLoanCard), findsOneWidget);

      // Step through the 3 loan offers
      // Offer 1: TAKE loan
      await tester.tap(find.text('TAKE LOAN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(game.debtManager.activeDebts.length, 1);

      // Offer 2: REFUSE loan
      await tester.tap(find.text('REFUSE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(game.debtManager.activeDebts.length, 1);

      // Offer 3: TAKE loan
      await tester.tap(find.text('TAKE LOAN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(game.debtManager.activeDebts.length, 2);

      // All 3 cards processed -> starts wave 2!
      await tester.pump(const Duration(milliseconds: 100));
      expect(game.gameState.phase, GamePhase.playing);
      expect(game.gameState.wave, 2);
      expect(find.byType(BetweenWavesOverlay), findsNothing);
    });

    testWidgets('death freezes game, shows overlay with score & wave, and AGAIN resets everything', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(
        GameWidget<BorrowedTimeGame>(
          game: game,
          overlayBuilderMap: game.buildOverlayMap(),
          initialActiveOverlays: const [BorrowedTimeGame.initialOverlay],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600)); // enter wave 1

      // Player gets score and reaches wave 2
      game.gameState.score = 120;
      game.gameState.wave = 2;

      // Add a test bullet and enemy to the arena
      await game.add(BulletComponent(
        startPosition: Vector2(100, 100),
        direction: Vector2(0, 1),
      ));
      await game.add(EnemyComponent(
        hp: 50,
        speed: 100,
        contactDamage: 10,
        startPosition: Vector2(200, 200),
      ));
      await tester.pump(const Duration(milliseconds: 16));

      expect(game.children.whereType<BulletComponent>().isNotEmpty, true);
      expect(game.children.whereType<EnemyComponent>().isNotEmpty, true);

      // Player dies
      game.playerStats.hp = 0;
      game.onPlayerDied();
      await tester.pump();

      expect(game.gameState.phase, GamePhase.dead);
      final deadOverlayFinder = find.byType(DeadOverlay);
      expect(deadOverlayFinder, findsOneWidget);
      expect(find.descendant(of: deadOverlayFinder, matching: find.text('YOU DIED')), findsOneWidget);
      expect(find.descendant(of: deadOverlayFinder, matching: find.text('120')), findsOneWidget); // Score
      expect(find.descendant(of: deadOverlayFinder, matching: find.text('2')), findsOneWidget); // Wave reached

      // Tap AGAIN
      await tester.tap(find.text('AGAIN'));
      await tester.pump(const Duration(milliseconds: 50));

      // Everything must be reset
      expect(find.byType(DeadOverlay), findsNothing);
      expect(game.gameState.score, 0);
      expect(game.gameState.wave, 0);
      expect(game.playerStats.hp, 100.0);
      expect(game.playerStats.maxHp, 100.0);
      expect(game.children.whereType<BulletComponent>().where((b) => !b.isRemoving).isEmpty, true);
      expect(game.children.whereType<EnemyComponent>().where((e) => !e.isRemoving).isEmpty, true);
      expect(game.gameState.phase, GamePhase.betweenWaves);

      // Next wave starts wave 1
      await tester.pump(const Duration(milliseconds: 1600));
      expect(game.gameState.phase, GamePhase.playing);
      expect(game.gameState.wave, 1);
    });
  });
}
