import 'package:flutter_test/flutter_test.dart';
import 'package:borrowed_time/core/constants.dart';
import 'package:borrowed_time/core/player_stats.dart';

void main() {
  test('PlayerStats has sensible initial values', () {
    final stats = PlayerStats();
    expect(stats.maxHp, 100.0);
    expect(stats.hp, 100.0);
    expect(stats.moveSpeed, greaterThan(0.0));
    expect(stats.damage, greaterThan(0.0));
    expect(stats.fireRate, greaterThan(0.0));
    expect(stats.dashCooldown, greaterThan(0.0));
  });

  test('GameConstants has valid arena and player bounds', () {
    expect(GameConstants.arenaPadding, 24.0);
    expect(GameConstants.playerRadius, 14.0);
    expect(GameConstants.joystickRadius, greaterThan(GameConstants.joystickDeadZone));
  });
}
