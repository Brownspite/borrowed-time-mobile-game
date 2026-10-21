import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../components/arena_border.dart';
import '../components/player.dart';
import '../core/constants.dart';
import '../core/player_stats.dart';
import 'enemy_spawner.dart';

class BorrowedTimeGame extends FlameGame
    with DragCallbacks, HasCollisionDetection {
  late Rect arenaBounds;
  final PlayerStats playerStats = PlayerStats();
  late final PlayerComponent player;

  final Vector2 moveDirection = Vector2.zero();
  final Vector2 _dragStart = Vector2.zero();
  bool _isDragging = false;

  @override
  Future<void> onLoad() async {
    _updateArenaBounds();

    await add(ArenaBorder());

    player = PlayerComponent(stats: playerStats);
    await add(player);

    await add(EnemySpawner());
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateArenaBounds();
  }

  void _updateArenaBounds() {
    const p = GameConstants.arenaPadding;
    arenaBounds = Rect.fromLTWH(p, p, size.x - p * 2, size.y - p * 2);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    _dragStart.setFrom(event.canvasPosition);
    moveDirection.setZero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isDragging) return;

    final current = event.canvasEndPosition;
    final dx = current.x - _dragStart.x;
    final dy = current.y - _dragStart.y;
    final distSq = dx * dx + dy * dy;

    const deadZone = GameConstants.joystickDeadZone;
    const maxRadius = GameConstants.joystickRadius;

    if (distSq > deadZone * deadZone) {
      final dist = math.sqrt(distSq);
      final normX = dx / dist;
      final normY = dy / dist;
      final factor = (dist / maxRadius).clamp(0.0, 1.0);
      moveDirection.setValues(normX * factor, normY * factor);

      // Tether drag origin when dragged beyond max radius for floating-joystick responsiveness
      if (dist > maxRadius) {
        _dragStart.setValues(
          current.x - normX * maxRadius,
          current.y - normY * maxRadius,
        );
      }
    } else {
      moveDirection.setZero();
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    moveDirection.setZero();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;
    moveDirection.setZero();
  }
}
