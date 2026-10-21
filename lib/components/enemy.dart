import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/constants.dart';
import '../game/borrowed_time_game.dart';

class EnemyComponent extends PositionComponent
    with HasGameReference<BorrowedTimeGame>, CollisionCallbacks {
  EnemyComponent({
    required this.hp,
    required this.speed,
    required this.contactDamage,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2.all(GameConstants.enemyRadius * 2),
          anchor: Anchor.center,
        );

  double hp;
  final double speed;
  final double contactDamage;

  late final Paint _bodyPaint;
  late final Paint _corePaint;
  late final Offset _centerOffset;

  // Reusable vector to avoid per-frame allocation
  final Vector2 _direction = Vector2.zero();

  @override
  Future<void> onLoad() async {
    const r = GameConstants.enemyRadius;
    _centerOffset = const Offset(r, r);

    _bodyPaint = Paint()
      ..color = const Color(0xCCFF3344)
      ..style = PaintingStyle.fill;

    _corePaint = Paint()
      ..color = const Color(0xFFFF6677)
      ..style = PaintingStyle.fill;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    final playerPos = game.player.position;
    _direction
      ..setFrom(playerPos)
      ..sub(position);

    final dist = _direction.length;
    if (dist > 1.0) {
      _direction.scale(1.0 / dist); // normalize without allocating
      position.x += _direction.x * speed * dt;
      position.y += _direction.y * speed * dt;
    }
  }

  void takeDamage(double damage) {
    hp -= damage;
    if (hp <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    const r = GameConstants.enemyRadius;
    canvas.drawCircle(_centerOffset, r, _bodyPaint);
    canvas.drawCircle(_centerOffset, r * 0.4, _corePaint);
  }
}

/// Picks a random point on the arena edge for spawning.
Vector2 randomEdgePosition(Rect arena, math.Random rng) {
  // Pick a random side: 0=top, 1=right, 2=bottom, 3=left
  final side = rng.nextInt(4);
  switch (side) {
    case 0: // top
      return Vector2(
        arena.left + rng.nextDouble() * arena.width,
        arena.top,
      );
    case 1: // right
      return Vector2(
        arena.right,
        arena.top + rng.nextDouble() * arena.height,
      );
    case 2: // bottom
      return Vector2(
        arena.left + rng.nextDouble() * arena.width,
        arena.bottom,
      );
    default: // left
      return Vector2(
        arena.left,
        arena.top + rng.nextDouble() * arena.height,
      );
  }
}
