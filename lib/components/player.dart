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

  // ── Loan-related upgrades & modifiers ─────────────────────────────────────
  bool dashEnabled = true;
  double dashTimer = 0.0;
  double dashCooldownTimer = 0.0;
  bool get isDashing => dashTimer > 0;

  int shieldHits = 0;
  int secondWindCharges = 0;
  bool hasSlowAura = false;
  double slowAuraRadius = 130.0;
  double slowAuraFactor = 0.50;
  double lifestealAmount = 0.0;
  double reverseControlsTimer = 0.0;

  late final Paint _outerGlowPaint;
  late final Paint _middleGlowPaint;
  late final Paint _corePaint;
  late final Paint _borderPaint;
  late final Paint _flashPaint;
  late final Paint _hpBackPaint;
  late final Paint _hpFillPaint;
  late final Paint _shieldPaint;
  late final Paint _auraPaint;
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

    _shieldPaint = Paint()
      ..color = const Color(0x884AEADC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _auraPaint = Paint()
      ..color = const Color(0x154AEADC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    add(CircleHitbox());

    position.setValues(game.size.x / 2, game.size.y / 2);
    _clampToArena();
  }

  /// Triggers a burst dash evasion if dash is enabled and cooldown ready.
  bool dash() {
    if (!dashEnabled || dashCooldownTimer > 0) return false;
    dashTimer = 0.15;
    dashCooldownTimer = stats.dashCooldown;
    return true;
  }

  void reverseControls(double seconds) {
    reverseControlsTimer = seconds;
  }

  void onEnemyKilled() {
    if (lifestealAmount > 0) {
      stats.hp = math.min(stats.maxHp, stats.hp + lifestealAmount);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (dashCooldownTimer > 0) dashCooldownTimer -= dt;
    if (dashTimer > 0) dashTimer -= dt;
    if (reverseControlsTimer > 0) reverseControlsTimer -= dt;

    // Movement
    final moveDir = game.moveDirection;
    if (!moveDir.isZero()) {
      final mult = (isDashing ? 3.0 : 1.0) *
          (reverseControlsTimer > 0 ? -1.0 : 1.0);
      position.x += moveDir.x * stats.moveSpeed * mult * dt;
      position.y += moveDir.y * stats.moveSpeed * mult * dt;
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
      other.onHitPlayer();
    }
  }

  void _takeDamage(double amount) {
    if (shieldHits > 0) {
      shieldHits--;
      _isFlashing = true;
      _flashTimer = GameConstants.flashDuration;
      return;
    }

    if (stats.hp - amount <= 0 && secondWindCharges > 0) {
      secondWindCharges--;
      stats.hp = stats.maxHp * 0.50; // revive with 50% max HP
      _isFlashing = true;
      _flashTimer = GameConstants.flashDuration * 2;
      return;
    }

    stats.hp -= amount;
    _isFlashing = true;
    _flashTimer = GameConstants.flashDuration;

    if (stats.hp <= 0) {
      stats.hp = 0;
      game.onPlayerDied();
    }
  }

  void takeExplosionDamage(double amount) {
    _takeDamage(amount);
  }

  /// Resets player position and fire timer for an instant restart.
  void resetForRestart() {
    position.setValues(game.size.x / 2, game.size.y / 2);
    _clampToArena();
    bulletConfig = const BulletConfig();
    _fireTimer = 0.0;
    _isFlashing = false;
    _flashTimer = 0.0;
    dashEnabled = true;
    dashTimer = 0.0;
    dashCooldownTimer = 0.0;
    shieldHits = 0;
    secondWindCharges = 0;
    hasSlowAura = false;
    lifestealAmount = 0.0;
    reverseControlsTimer = 0.0;
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

    if (hasSlowAura) {
      canvas.drawCircle(_centerOffset, slowAuraRadius, _auraPaint);
    }
    if (shieldHits > 0) {
      canvas.drawCircle(_centerOffset, r * 1.8, _shieldPaint);
    }

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
