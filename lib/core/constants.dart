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
}
