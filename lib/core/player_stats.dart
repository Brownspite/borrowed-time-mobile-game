class PlayerStats {
  double maxHp;
  double hp;
  double moveSpeed; // pixels per second
  double damage;
  double fireRate; // attacks per second
  double dashCooldown; // seconds

  PlayerStats({
    this.maxHp = 100.0,
    this.hp = 100.0,
    this.moveSpeed = 220.0,
    this.damage = 25.0,
    this.fireRate = 2.0,
    this.dashCooldown = 1.5,
  });

  void reset() {
    maxHp = 100.0;
    hp = 100.0;
    moveSpeed = 220.0;
    damage = 25.0;
    fireRate = 2.0;
    dashCooldown = 1.5;
  }
}
