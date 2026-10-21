import 'dart:math' as math;

import 'package:flame/components.dart';

import '../components/enemy.dart';
import '../core/constants.dart';
import 'borrowed_time_game.dart';

class EnemySpawner extends Component with HasGameReference<BorrowedTimeGame> {
  final math.Random _rng = math.Random();
  double _timer = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    if (_timer >= GameConstants.spawnInterval) {
      _timer -= GameConstants.spawnInterval;
      _spawnEnemy();
    }
  }

  void _spawnEnemy() {
    final spawnPos = randomEdgePosition(game.arenaBounds, _rng);

    game.add(
      EnemyComponent(
        hp: GameConstants.enemyBaseHp,
        speed: GameConstants.enemyBaseSpeed,
        contactDamage: GameConstants.enemyContactDamage,
        startPosition: spawnPos,
      ),
    );
  }
}
