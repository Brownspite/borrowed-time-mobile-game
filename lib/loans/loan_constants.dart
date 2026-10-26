abstract class LoanTuning {
  // Early payment costs
  static const double earlyPayHpFraction = 0.25; // 25% max HP to pay debt early
  static const int earlyPayScoreCost = 50; // 50 score points to pay debt early

  // Overdue scaling
  static const double overduePenaltyGrowth = 0.5; // +50% penalty per overdue wave

  // 1. Double Damage
  static const double doubleDamageMultiplier = 2.0;
  static const double doubleDamageHpPenaltyFraction = 0.30;
  static const int doubleDamageDueInWaves = 3;

  // 2. Dash Boots
  static const double dashCooldownBonusMultiplier = 0.5; // 50% faster dash cooldown
  static const double dashEnemySpeedPenaltyFraction = 0.15; // enemies +15% speed
  static const int dashBootsDueInWaves = 3;

  // 3. Homing Bullets
  static const double homingStrength = 5.0;
  static const double homingBulletSpeedPenalty = 0.30; // bullets 30% slower
  static const int homingBulletsDueInWaves = 3;

  // 4. Rapid Fire
  static const double rapidFireMultiplier = 1.75; // +75% fire rate
  static const double rapidFirePenaltyFraction = 0.50; // fire rate cut in half
  static const int rapidFireDueInWaves = 3;

  // 5. Big Heart
  static const double bigHeartHpBonus = 50.0;
  static const double bigHeartHpPenalty = 50.0;
  static const int bigHeartDueInWaves = 3;

  // 6. Energy Shield
  static const int energyShieldHits = 3;
  static const double energyShieldEnemyIncreaseFraction = 0.25; // +25% enemies
  static const int energyShieldDueInWaves = 3;

  // 7. Triple Shot
  static const int tripleShotExtraProjectiles = 2; // +2 projectiles (3 total)
  static const int tripleShotDueInWaves = 3;

  // 8. Piercing Shots
  static const int piercingShotExtraPierce = 2; // +2 pierce count
  static const double arenaShrinkFraction = 0.20; // arena shrinks 20%
  static const int piercingShotsDueInWaves = 3;

  // 9. Time Slow Aura
  static const double slowAuraRadius = 130.0;
  static const double slowAuraFactor = 0.50; // enemies move 50% slower near player
  static const double slowAuraEnemySpeedPenaltyFraction = 0.20; // +20% enemy speed permanently
  static const int timeSlowAuraDueInWaves = 3;

  // 10. Lifesteal
  static const double lifestealHeal = 3.0;
  static const double lifestealScorePenaltyFraction = 0.50; // 50% score gain reduction
  static const int lifestealDueInWaves = 3;

  // 11. Giant Bullets
  static const double giantBulletRadiusMultiplier = 2.2;
  static const double giantBulletDamageBonus = 15.0;
  static const double giantBulletPlayerSpeedPenaltyFraction = 0.25; // player 25% slower
  static const int giantBulletsDueInWaves = 3;

  // 12. Speed Boost
  static const double speedBoostMultiplier = 1.50; // player moves 50% faster
  static const double reverseControlsDuration = 8.0; // 8 seconds reversed
  static const int speedBoostDueInWaves = 3;

  // 13. Score x2
  static const double scoreX2Multiplier = 2.0;
  static const double scoreX2HpLossFraction = 0.20; // lose 20% current HP
  static const int scoreX2DueInWaves = 3;

  // 14. Explosive Kills
  static const double explosionRadius = 65.0;
  static const double explosionDamage = 45.0;
  static const double explosionSelfDamage = 15.0;
  static const int explosiveKillsDueInWaves = 3;

  // 15. Second Wind
  static const double secondWindReviveHpFraction = 0.50;
  static const double secondWindPenaltyStartingHp = 1.0;
  static const int secondWindDueInWaves = 3;
}
