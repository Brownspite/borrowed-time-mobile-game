import 'constants.dart';

class BulletConfig {
  final double speed;
  final double damage;
  final double radius;
  final int pierceCount;
  final bool isHoming;
  final double homingStrength;
  final int extraProjectiles;
  final double spreadAngle;

  const BulletConfig({
    this.speed = GameConstants.bulletSpeed,
    this.damage = 25.0,
    this.radius = GameConstants.bulletRadius,
    this.pierceCount = 1,
    this.isHoming = false,
    this.homingStrength = 5.0,
    this.extraProjectiles = 0,
    this.spreadAngle = 0.25,
  });

  BulletConfig copyWith({
    double? speed,
    double? damage,
    double? radius,
    int? pierceCount,
    bool? isHoming,
    double? homingStrength,
    int? extraProjectiles,
    double? spreadAngle,
  }) {
    return BulletConfig(
      speed: speed ?? this.speed,
      damage: damage ?? this.damage,
      radius: radius ?? this.radius,
      pierceCount: pierceCount ?? this.pierceCount,
      isHoming: isHoming ?? this.isHoming,
      homingStrength: homingStrength ?? this.homingStrength,
      extraProjectiles: extraProjectiles ?? this.extraProjectiles,
      spreadAngle: spreadAngle ?? this.spreadAngle,
    );
  }
}
