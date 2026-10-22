import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/bullet_config.dart';
import '../core/constants.dart';
import '../game/borrowed_time_game.dart';
import 'enemy.dart';

export '../core/bullet_config.dart';

class BulletComponent extends PositionComponent
    with HasGameReference<BorrowedTimeGame>, CollisionCallbacks {
  BulletComponent({
    required Vector2 startPosition,
    required Vector2 direction,
    this.config = const BulletConfig(),
  })  : _hitsRemaining = config.pierceCount,
        super(
          position: startPosition,
          size: Vector2.all(config.radius * 2),
          anchor: Anchor.center,
        ) {
    if (direction.isZero()) {
      _direction.setValues(0, -1);
    } else {
      _direction
        ..setFrom(direction)
        ..normalize();
    }
  }

  final BulletConfig config;
  int _hitsRemaining;
  final Set<EnemyComponent> _hitEnemies = {};

  final Vector2 _direction = Vector2.zero();
  late final Offset _centerOffset;
  late final Paint _outerGlowPaint;
  late final Paint _corePaint;

  @override
  Future<void> onLoad() async {
    _centerOffset = Offset(config.radius, config.radius);

    _outerGlowPaint = Paint()
      ..color = GameConstants.arenaBorderColor.withAlpha(140)
      ..style = PaintingStyle.fill;

    _corePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (config.isHoming) {
      _updateHoming(dt);
    }

    position.x += _direction.x * config.speed * dt;
    position.y += _direction.y * config.speed * dt;

    // Remove when leaving the arena
    final arena = game.arenaBounds;
    if (position.x < arena.left ||
        position.x > arena.right ||
        position.y < arena.top ||
        position.y > arena.bottom) {
      removeFromParent();
    }
  }

  void _updateHoming(double dt) {
    EnemyComponent? nearest;
    double minDistanceSq = double.infinity;
    final px = position.x;
    final py = position.y;

    for (final child in game.children) {
      if (child is EnemyComponent && !child.isRemoving && child.hp > 0) {
        final dx = child.position.x - px;
        final dy = child.position.y - py;
        final distSq = dx * dx + dy * dy;
        if (distSq < minDistanceSq) {
          minDistanceSq = distSq;
          nearest = child;
        }
      }
    }

    if (nearest != null && minDistanceSq > 0.001) {
      final targetDx = nearest.position.x - position.x;
      final targetDy = nearest.position.y - position.y;
      final targetDist = math.sqrt(minDistanceSq);
      final desiredX = targetDx / targetDist;
      final desiredY = targetDy / targetDist;

      final turnRate = (config.homingStrength * dt).clamp(0.0, 1.0);
      _direction.x += (desiredX - _direction.x) * turnRate;
      _direction.y += (desiredY - _direction.y) * turnRate;
      _direction.normalize();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (isRemoving) return;

    if (other is EnemyComponent && !other.isRemoving && other.hp > 0) {
      if (_hitEnemies.add(other)) {
        other.takeDamage(config.damage);
        _hitsRemaining--;
        if (_hitsRemaining <= 0) {
          removeFromParent();
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(_centerOffset, config.radius * 1.5, _outerGlowPaint);
    canvas.drawCircle(_centerOffset, config.radius * 0.7, _corePaint);
  }
}
