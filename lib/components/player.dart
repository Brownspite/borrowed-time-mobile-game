import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/constants.dart';
import '../core/player_stats.dart';
import '../game/borrowed_time_game.dart';
import 'enemy.dart';

class PlayerComponent extends PositionComponent
    with HasGameReference<BorrowedTimeGame>, CollisionCallbacks {
  PlayerComponent({required this.stats})
      : super(
          anchor: Anchor.center,
          size: Vector2.all(GameConstants.playerRadius * 2),
        );

  final PlayerStats stats;

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

  @override
  Future<void> onLoad() async {
    const r = GameConstants.playerRadius;
    _centerOffset = const Offset(r, r);

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

    // Flash countdown
    if (_isFlashing) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) {
        _isFlashing = false;
      }
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
