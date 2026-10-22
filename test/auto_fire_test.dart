import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:borrowed_time/components/bullet.dart';
import 'package:borrowed_time/components/enemy.dart';
import 'package:borrowed_time/core/constants.dart';
import 'package:borrowed_time/core/game_state.dart';
import 'package:borrowed_time/game/borrowed_time_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameState', () {
    test('initializes with score 0 and can reset', () {
      final state = GameState();
      expect(state.score, 0);

      state.score += 10;
      expect(state.score, 10);

      state.reset();
      expect(state.score, 0);
    });
  });

  group('BulletConfig', () {
    test('has proper defaults and copyWith works', () {
      const config = BulletConfig();
      expect(config.speed, GameConstants.bulletSpeed);
      expect(config.damage, 25.0);
      expect(config.radius, GameConstants.bulletRadius);
      expect(config.pierceCount, 1);
      expect(config.isHoming, false);
      expect(config.extraProjectiles, 0);

      final modified = config.copyWith(
        damage: 50.0,
        pierceCount: 3,
        isHoming: true,
        extraProjectiles: 2,
        radius: 6.0,
      );
      expect(modified.damage, 50.0);
      expect(modified.pierceCount, 3);
      expect(modified.isHoming, true);
      expect(modified.extraProjectiles, 2);
      expect(modified.radius, 6.0);
      expect(modified.speed, GameConstants.bulletSpeed);
    });
  });

  group('EnemyComponent and Score', () {
    testWidgets('takes damage and grants score on death', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();

      final enemy = EnemyComponent(
        hp: 30.0,
        speed: 50.0,
        contactDamage: 10.0,
        startPosition: Vector2(100, 100),
      );
      await game.add(enemy);
      await tester.pump(const Duration(milliseconds: 16));

      expect(game.gameState.score, 0);

      // Non-fatal hit
      enemy.takeDamage(20.0);
      expect(enemy.hp, 10.0);
      expect(game.gameState.score, 0);
      expect(enemy.isRemoving, false);

      // Fatal hit
      enemy.takeDamage(20.0);
      expect(enemy.hp, lessThanOrEqualTo(0.0));
      expect(game.gameState.score, GameConstants.scorePerKill);
      expect(enemy.isRemoving, true);
    });
  });

  group('Player Auto-fire', () {
    testWidgets('does not fire if no enemies exist', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();

      // Remove any enemy spawned by default EnemySpawner
      for (final enemy in game.children.whereType<EnemyComponent>()) {
        enemy.removeFromParent();
      }
      await tester.pump(const Duration(milliseconds: 16));

      final initialBullets = game.children.whereType<BulletComponent>().length;
      expect(initialBullets, 0);

      // Advance time beyond fire rate interval
      await tester.pump(const Duration(seconds: 1));
      final bulletsAfterUpdate = game.children.whereType<BulletComponent>().length;
      expect(bulletsAfterUpdate, 0);
    });

    testWidgets('fires at nearest enemy when enemy exists', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();

      // Clear any spawned enemies
      for (final enemy in game.children.whereType<EnemyComponent>()) {
        enemy.removeFromParent();
      }
      await tester.pump(const Duration(milliseconds: 16));

      // Player center is approx (size.x / 2, size.y / 2)
      final playerPos = game.player.position;
      final farEnemy = EnemyComponent(
        hp: 30.0,
        speed: 0.0,
        contactDamage: 10.0,
        startPosition: Vector2(playerPos.x, playerPos.y - 200),
      );
      final nearEnemy = EnemyComponent(
        hp: 30.0,
        speed: 0.0,
        contactDamage: 10.0,
        startPosition: Vector2(playerPos.x, playerPos.y - 80),
      );

      await game.add(farEnemy);
      await game.add(nearEnemy);
      await tester.pump();

      // Fire interval is 1 / 2.0 = 0.5s.
      await tester.pump(const Duration(milliseconds: 100));

      final bullets = game.children.whereType<BulletComponent>().toList();
      expect(bullets.isNotEmpty, true);

      final bullet = bullets.first;
      // Should fire upwards towards nearEnemy from playerPos
      expect(bullet.position.y, lessThan(playerPos.y));
    });
  });

  group('BulletComponent', () {
    testWidgets('is removed when leaving arena bounds', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();

      final bullet = BulletComponent(
        startPosition: Vector2(200, game.arenaBounds.top + 2),
        direction: Vector2(0, -1),
        config: const BulletConfig(speed: 100.0),
      );
      await game.add(bullet);
      await tester.pump(const Duration(milliseconds: 16));

      expect(bullet.isRemoving, false);

      // Move out of bounds (past top: -100 * 0.1 = -10, top + 2 - 10 < top)
      await tester.pump(const Duration(milliseconds: 100));
      expect(bullet.isRemoving, true);
    });

    testWidgets('deals damage to enemy on collision', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();

      final enemy = EnemyComponent(
        hp: 30.0,
        speed: 0.0,
        contactDamage: 10.0,
        startPosition: Vector2(200, 200),
      );
      await game.add(enemy);

      final bullet = BulletComponent(
        startPosition: Vector2(200, 200),
        direction: Vector2(0, -1),
        config: const BulletConfig(damage: 25.0, pierceCount: 1),
      );
      await game.add(bullet);
      await tester.pump(const Duration(milliseconds: 16));

      bullet.onCollisionStart({}, enemy);

      expect(enemy.hp, 5.0);
      expect(bullet.isRemoving, true);
    });

    testWidgets('piercing bullet can hit multiple enemies up to pierceCount', (tester) async {
      final game = BorrowedTimeGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();

      final enemy1 = EnemyComponent(
        hp: 30.0,
        speed: 0.0,
        contactDamage: 10.0,
        startPosition: Vector2(200, 200),
      );
      final enemy2 = EnemyComponent(
        hp: 30.0,
        speed: 0.0,
        contactDamage: 10.0,
        startPosition: Vector2(200, 180),
      );
      await game.add(enemy1);
      await game.add(enemy2);

      final bullet = BulletComponent(
        startPosition: Vector2(200, 200),
        direction: Vector2(0, -1),
        config: const BulletConfig(damage: 30.0, pierceCount: 2),
      );
      await game.add(bullet);
      await tester.pump(const Duration(milliseconds: 16));

      // Hit first enemy -> enemy dies, score +10, bullet stays alive
      bullet.onCollisionStart({}, enemy1);
      expect(enemy1.hp, 0.0);
      expect(enemy1.isRemoving, true);
      expect(bullet.isRemoving, false);
      expect(game.gameState.score, 10);

      // Hit second enemy -> enemy dies, score +10, bullet runs out of pierce and is removed
      bullet.onCollisionStart({}, enemy2);
      expect(enemy2.hp, 0.0);
      expect(enemy2.isRemoving, true);
      expect(bullet.isRemoving, true);
      expect(game.gameState.score, 20);
    });
  });
}
