import 'dart:ui';

import 'package:flame/components.dart';

import '../core/constants.dart';

/// Draws the arena border as a simple outlined rectangle.
class ArenaBorder extends PositionComponent with HasGameReference {
  late Rect _rect;
  late final Paint _paint;

  @override
  Future<void> onLoad() async {
    _paint = Paint()
      ..color = GameConstants.arenaBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.arenaBorderWidth;

    _updateRect();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateRect();
  }

  void _updateRect() {
    final screen = game.size;
    const p = GameConstants.arenaPadding;
    _rect = Rect.fromLTWH(p, p, screen.x - p * 2, screen.y - p * 2);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_rect, _paint);
  }
}
