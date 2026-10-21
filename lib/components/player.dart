import 'dart:ui';

import 'package:flame/components.dart';

import '../core/constants.dart';
import '../core/player_stats.dart';
import '../game/borrowed_time_game.dart';

/// Player character drawn as a glowing circle with zero per-frame allocations.
class PlayerComponent extends PositionComponent
    with HasGameReference<BorrowedTimeGame> {
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
  late final Offset _centerOffset;

  @override
  Future<void> onLoad() async {
    const r = GameConstants.playerRadius;
    _centerOffset = const Offset(r, r);

    // Pre-allocate paints to avoid garbage collection spikes in render loop
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

    position.setValues(game.size.x / 2, game.size.y / 2);
    _clampToArena();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final moveDir = game.moveDirection;
    if (!moveDir.isZero()) {
      position.x += moveDir.x * stats.moveSpeed * dt;
      position.y += moveDir.y * stats.moveSpeed * dt;
      _clampToArena();
    }
  }

  void _clampToArena() {
    final bounds = game.arenaBounds;
    const r = GameConstants.playerRadius;

    final minX = bounds.left + r;
    final maxX = bounds.right - r;
    final minY = bounds.top + r;
    final maxY = bounds.bottom - r;

    position.x = position.x.clamp(minX, maxX);
    position.y = position.y.clamp(minY, maxY);
  }

  @override
  void render(Canvas canvas) {
    const r = GameConstants.playerRadius;

    // Glowing aura effect using concentric circles
    canvas.drawCircle(_centerOffset, r * 1.5, _outerGlowPaint);
    canvas.drawCircle(_centerOffset, r, _middleGlowPaint);
    canvas.drawCircle(_centerOffset, r, _borderPaint);
    canvas.drawCircle(_centerOffset, r * 0.45, _corePaint);
  }
}
