import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants.dart';
import 'game/borrowed_time_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait + immersive fullscreen
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final game = BorrowedTimeGame();

  runApp(
    GameWidget<BorrowedTimeGame>(
      game: game,
      backgroundBuilder: (_) => Container(
        color: GameConstants.backgroundColor,
      ),
      overlayBuilderMap: game.buildOverlayMap(),
      initialActiveOverlays: const [BorrowedTimeGame.initialOverlay],
    ),
  );
}
