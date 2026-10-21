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

  runApp(
    GameWidget(
      game: BorrowedTimeGame(),
      backgroundBuilder: (_) => Container(
        color: GameConstants.backgroundColor,
      ),
    ),
  );
}
