import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:borrowed_time/components/enemy.dart';
import 'package:borrowed_time/core/game_phase.dart';
import 'package:borrowed_time/game/borrowed_time_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('enemy colliding with player decrements alive count and allows wave to complete', (tester) async {
    final game = BorrowedTimeGame();
    await tester.pumpWidget(
      GameWidget<BorrowedTimeGame>(
        game: game,
        overlayBuilderMap: game.buildOverlayMap(),
        initialActiveOverlays: const [BorrowedTimeGame.initialOverlay],
      ),
    );
    await tester.pump();
    // Advance past initial betweenWaves pause -> wave 1 starts
    await tester.pump(const Duration(milliseconds: 1600));
    expect(game.gameState.phase, GamePhase.playing);
    expect(game.gameState.wave, 1);

    // Wave 1 spawns 4 enemies at 2.0s intervals.
    // We let all 4 spawn. For each spawned enemy, we trigger contact damage on the player.
    for (int i = 0; i < 90; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      for (final enemy in game.children.whereType<EnemyComponent>().toList()) {
        if (!enemy.isRemoving) {
          game.player.onCollisionStart({}, enemy);
        }
      }
    }

    // Pump to process all lifecycle callbacks
    await tester.pump();

    // Player survived (4 * 15 = 60 dmg, HP was 100 -> now 40)
    expect(game.playerStats.hp, 40.0);
    // All 4 enemies are removed
    expect(game.children.whereType<EnemyComponent>().isEmpty, true);
    // Wave 1 successfully ended because all 4 enemies spawned and died!
    expect(game.gameState.phase, GamePhase.betweenWaves);
  });
}
