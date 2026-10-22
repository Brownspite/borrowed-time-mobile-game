import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/constants.dart';
import '../core/player_stats.dart';
import '../game/borrowed_time_game.dart';
import 'bullet.dart';
import 'enemy.dart';

class PlayerComponent extends PositionComponent
    with HasGameReference<BorrowedTimeGame>, CollisionCallbacks {
  PlayerComponent({required this.stats})
      : super(
          anchor: Anchor.center,
          size: Vector2.all(GameConstants.playerRadius * 2),
        );

  final PlayerStats stats;
  BulletConfig bulletConfig = const BulletConfig();

  late final Paint _outerGlowPaint;
  late final Paint _middleGlowPaint;
  late final Paint _corePaint;
  late final Paint _borderPaint;
  late final Paint _flashPaint;
  late final Paint _hpBackPaint;
  late final Paint _hpFillPaint;
  late final Offset _centerOffset;

  double _flashTimer = 0.0;
  bool _isFlashing = false;
  double _fireTimer = 0.0;

  @override
  Future<void> onLoad() async {
    const r = GameConstants.playerRadius;
    _centerOffset = const Offset(r, r);
    _fireTimer = stats.fireRate > 0 ? 1.0 / stats.fireRate : 0.0;

    _outerGlowPaint = Paint()
      ..color = const Color(0x334AEADC)
      ..style = PaintingStyle.fill;

    _middleGlowPaint = Paint()
      ..color = const Color(0x664AEADC)
      ..style = PaintingStyle.fill;

    _corePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = GameConstants.arenaBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _flashPaint = Paint()
      ..color = const Color(0xDDFFFFFF)
      ..style = PaintingStyle.fill;

    _hpBackPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.fill;

    _hpFillPaint = Paint()
      ..color = const Color(0xFF4AEADC)
      ..style = PaintingStyle.fill;

    add(CircleHitbox());

    position.setValues(game.size.x / 2, game.size.y / 2);
    _clampToArena();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Movement
    final moveDir = game.moveDirection;
    if (!moveDir.isZero()) {
      position.x += moveDir.x * stats.moveSpeed * dt;
      position.y += moveDir.y * stats.moveSpeed * dt;
      _clampToArena();
    }

    // Auto-fire
    _updateAutoFire(dt);

    // Flash countdown
    if (_isFlashing) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) {
        _isFlashing = false;
      }
    }
  }

  void _updateAutoFire(double dt) {
    if (stats.fireRate <= 0) return;

    _fireTimer += dt;
    final interval = 1.0 / stats.fireRate;

    if (_fireTimer >= interval) {
      final nearestEnemy = _findNearestEnemy();
      if (nearestEnemy != null) {
        fireAt(nearestEnemy);
        _fireTimer = 0.0;
      } else {
        // Keep timer ready so player fires immediately when an enemy appears
        _fireTimer = interval;
      }
    }
  }

  EnemyComponent? _findNearestEnemy() {
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
    return nearest;
  }

  void fireAt(EnemyComponent target, [BulletConfig? config]) {
    final dx = target.position.x - position.x;
    final dy = target.position.y - position.y;
    final distSq = dx * dx + dy * dy;

    final dir = distSq > 0.0001
        ? Vector2(dx / math.sqrt(distSq), dy / math.sqrt(distSq))
        : Vector2(0, -1);

    fire(direction: dir, config: config);
  }

  void fire({required Vector2 direction, BulletConfig? config}) {
    final effectiveConfig = (config ?? bulletConfig).copyWith(
      damage: config?.damage ?? stats.damage,
    );

    final totalProjectiles = 1 + effectiveConfig.extraProjectiles;
    if (totalProjectiles <= 1) {
      game.add(
        BulletComponent(
          startPosition: position.clone(),
          direction: direction,
          config: effectiveConfig,
        ),
      );
      return;
    }

    final baseAngle = math.atan2(direction.y, direction.x);
    final halfSpread = (totalProjectiles - 1) * effectiveConfig.spreadAngle / 2;

    for (int i = 0; i < totalProjectiles; i++) {
      final angle = baseAngle - halfSpread + i * effectiveConfig.spreadAngle;
      final dir = Vector2(math.cos(angle), math.sin(angle));
      game.add(
        BulletComponent(
          startPosition: position.clone(),
          direction: dir,
          config: effectiveConfig,
        ),
      );
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is EnemyComponent) {
      _takeDamage(other.contactDamage);
      other.removeFromParent();
    }
  }

  void _takeDamage(double amount) {
    stats.hp -= amount;
    _isFlashing = true;
    _flashTimer = GameConstants.flashDuration;

    if (stats.hp <= 0) {
      stats.hp = 0;
      // ignore: avoid_print
      print('player died');
    }
  }

  void _clampToArena() {
    final bounds = game.arenaBounds;
    const r = GameConstants.playerRadius;

    position.x = position.x.clamp(bounds.left + r, bounds.right - r);
    position.y = position.y.clamp(bounds.top + r, bounds.bottom - r);
  }

  @override
  void render(Canvas canvas) {
    const r = GameConstants.playerRadius;

    if (_isFlashing) {
      canvas.drawCircle(_centerOffset, r * 1.5, _flashPaint);
    } else {
      canvas.drawCircle(_centerOffset, r * 1.5, _outerGlowPaint);
      canvas.drawCircle(_centerOffset, r, _middleGlowPaint);
    }
    canvas.drawCircle(_centerOffset, r, _borderPaint);
    canvas.drawCircle(_centerOffset, r * 0.45, _corePaint);

    _renderHpBar(canvas);
  }

  void _renderHpBar(Canvas canvas) {
    const w = GameConstants.hpBarWidth;
    const h = GameConstants.hpBarHeight;
    const r = GameConstants.playerRadius;
    const yOff = GameConstants.hpBarOffsetY;

    // Center the bar above the player
    final left = r - w / 2;
    final top = r + yOff;

    canvas.drawRect(Rect.fromLTWH(left, top, w, h), _hpBackPaint);

    final fillW = w * (stats.hp / stats.maxHp).clamp(0.0, 1.0);
    if (fillW > 0) {
      canvas.drawRect(Rect.fromLTWH(left, top, fillW, h), _hpFillPaint);
    }
  }
}
