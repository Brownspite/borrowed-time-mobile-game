import 'dart:ui';

abstract class GameConstants {
  static const double arenaPadding = 24.0;

  // Arena border appearance
  static const double arenaBorderWidth = 2.0;
  static const Color arenaBorderColor = Color(0xFF4AEADC); // cyan-ish accent
  static const Color backgroundColor = Color(0xFF0A0A0F);

  // Player defaults
  static const double playerRadius = 14.0;

  // Floating drag joystick parameters
  static const double joystickRadius = 55.0;
  static const double joystickDeadZone = 4.0;

  // Enemy defaults
  static const double enemyRadius = 10.0;
  static const double enemyBaseSpeed = 80.0;
  static const double enemyBaseHp = 30.0;
  static const double enemyContactDamage = 15.0;

  // Spawner
  static const double spawnInterval = 1.5; // seconds between spawns

  // Player damage flash
  static const double flashDuration = 0.12; // seconds

  // HP bar
  static const double hpBarWidth = 30.0;
  static const double hpBarHeight = 4.0;
  static const double hpBarOffsetY = -22.0; // above the player center

  // Bullet defaults
  static const double bulletRadius = 3.5;
  static const double bulletSpeed = 400.0;

  // Score
  static const int scorePerKill = 10;
}
