import 'dart:ui';

import 'package:flame/components.dart';

import '../core/constants.dart';
import '../game/borrowed_time_game.dart';

/// Draws the arena border as a simple outlined rectangle using cached bounds.
class ArenaBorder extends PositionComponent
    with HasGameReference<BorrowedTimeGame> {
  late final Paint _paint;

  @override
  Future<void> onLoad() async {
    _paint = Paint()
      ..color = GameConstants.arenaBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.arenaBorderWidth;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(game.arenaBounds, _paint);
  }
}
