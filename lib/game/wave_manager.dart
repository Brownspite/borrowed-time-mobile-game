import 'dart:math' as math;

import 'package:flame/components.dart';

import '../components/enemy.dart';
import '../core/constants.dart';
import '../core/game_phase.dart';
import 'borrowed_time_game.dart';

/// Describes how a single wave is configured.
class WaveConfig {
  const WaveConfig({
    required this.totalEnemies,
    required this.spawnInterval,
    required this.bruteHp,
    required this.bruteSpeed,
    required this.runnerHp,
    required this.runnerSpeed,
    // runners (fast/weaker) as fraction of total enemies [0..1]
    required this.runnerFraction,
  });

  final int totalEnemies;
  final double spawnInterval; // seconds between spawns
  final double bruteHp;
  final double bruteSpeed;
  final double runnerHp;
  final double runnerSpeed;
  final double runnerFraction; // 0 means all brutes
}

/// Builds per-wave configs. Wave index is 0-based internally.
///
/// Difficulty curve:
///   – Wave 1 (index 0): slow, few, easy.
///   – Wave 8 (index 7): dense, fast, tough.
///
/// Linear lerp across 8 checkpoints keeps the maths simple and allocation-free.
WaveConfig buildWaveConfig(int waveIndex) {
  // Clamp so we don't need to worry about extremely high wave numbers breaking
  // the curve — just keep getting harder after wave 8.
  final t = (waveIndex / 7.0).clamp(0.0, 1.0); // 0 = wave 1, 1 = wave 8+

  // Enemy count: 4 → 16, then +2 per extra wave after wave 8
  final baseCount = (4 + t * 12).round();
  final extra = waveIndex > 7 ? (waveIndex - 7) * 2 : 0;
  final total = baseCount + extra;

  // Spawn interval: 2.0s → 0.6s
  final spawnInterval = 2.0 - t * 1.4;

  // Brute (standard) stats
  final bruteHp = 30.0 + t * 90.0; // 30 → 120
  final bruteSpeed = 70.0 + t * 80.0; // 70 → 150

  // Runner stats (faster, weaker) — present from wave 3 (index 2)
  final runnerHp = 12.0 + t * 28.0; // 12 → 40
  final runnerSpeed = 130.0 + t * 120.0; // 130 → 250
  final runnerFraction = waveIndex >= 2 ? (0.2 + t * 0.25).clamp(0.0, 0.45) : 0.0;

  return WaveConfig(
    totalEnemies: total,
    spawnInterval: spawnInterval,
    bruteHp: bruteHp,
    bruteSpeed: bruteSpeed,
    runnerHp: runnerHp,
    runnerSpeed: runnerSpeed,
    runnerFraction: runnerFraction,
  );
}

/// Manages the wave lifecycle:
///   playing  → (all spawned + all dead) → betweenWaves → (timer) → playing
///
/// It adds EnemyComponents to the game directly and tracks in-flight enemies
/// via a counter so it knows when a wave is truly cleared.
class WaveManager extends Component with HasGameReference<BorrowedTimeGame> {
  final math.Random _rng = math.Random();

  // Wave state
  int _enemiesLeftToSpawn = 0;
  int _enemiesAlive = 0;
  int _totalSpawned = 0; // enemies spawned this wave; guards the wave-clear check
  double _spawnTimer = 0.0;
  late WaveConfig _config;

  // Between-waves countdown
  static const double _betweenWavesDuration = 1.5; // seconds
  double _betweenTimer = 0.0;

  @override
  void onMount() {
    super.onMount();
    // Start the very first between-waves pause so the player sees "Wave 1
    // starting" on first launch as well as on restart.
    _startBetweenWaves();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final phase = game.gameState.phase;

    if (phase == GamePhase.playing) {
      _tickPlaying(dt);
    } else if (phase == GamePhase.betweenWaves) {
      _tickBetweenWaves(dt);
    }
    // dead → do nothing (game is frozen)
  }

  // ── Playing ──────────────────────────────────────────────────────────────

  void _tickPlaying(double dt) {
    // Spawn remaining enemies for this wave
    if (_enemiesLeftToSpawn > 0) {
      _spawnTimer += dt;
      if (_spawnTimer >= _config.spawnInterval) {
        _spawnTimer -= _config.spawnInterval;
        _spawnOne();
      }
    }

    // Wave is clear once ALL enemies have been spawned AND killed
    if (_totalSpawned > 0 && _enemiesLeftToSpawn == 0 && _enemiesAlive == 0) {
      _startBetweenWaves(isWaveClear: true);
    }
  }

  void _spawnOne() {
    final spawnPos = randomEdgePosition(game.arenaBounds, _rng);
    final useRunner =
        _config.runnerFraction > 0 && _rng.nextDouble() < _config.runnerFraction;

    final enemy = EnemyComponent(
      hp: useRunner ? _config.runnerHp : _config.bruteHp,
      speed: useRunner ? _config.runnerSpeed : _config.bruteSpeed,
      contactDamage: GameConstants.enemyContactDamage,
      startPosition: spawnPos,
      type: useRunner ? EnemyType.runner : EnemyType.brute,
      onDeath: _onEnemyDied,
    );

    _enemiesLeftToSpawn--;
    _enemiesAlive++;
    _totalSpawned++;
    game.add(enemy);
  }

  void _onEnemyDied() {
    _enemiesAlive = math.max(0, _enemiesAlive - 1);
  }

  // ── Between waves ─────────────────────────────────────────────────────────

  void _startBetweenWaves({bool isWaveClear = false}) {
    game.gameState.phase = GamePhase.betweenWaves;
    _betweenTimer = 0.0;
    if (isWaveClear) {
      game.debtManager.onWaveCleared();
    }
    game.showBetweenWavesOverlay();
  }

  void _tickBetweenWaves(double dt) {
    _betweenTimer += dt;
    if (_betweenTimer >= _betweenWavesDuration) {
      _startNextWave();
    }
  }

  void _startNextWave() {
    game.gameState.wave++;
    final baseConfig = buildWaveConfig(game.gameState.wave - 1); // wave is 1-based
    final totalCount =
        (baseConfig.totalEnemies * game.enemyCountMultiplier).round();
    _config = WaveConfig(
      totalEnemies: totalCount,
      spawnInterval: baseConfig.spawnInterval,
      bruteHp: baseConfig.bruteHp,
      bruteSpeed: baseConfig.bruteSpeed * game.enemySpeedMultiplier,
      runnerHp: baseConfig.runnerHp,
      runnerSpeed: baseConfig.runnerSpeed * game.enemySpeedMultiplier,
      runnerFraction: baseConfig.runnerFraction,
    );
    _enemiesLeftToSpawn = _config.totalEnemies;
    _enemiesAlive = 0;
    _totalSpawned = 0;
    _spawnTimer = 0.0;

    // Apply any debt penalty starting HP (e.g. Second Wind debt)
    if (game.nextWaveStartingHp != null) {
      game.playerStats.hp = game.nextWaveStartingHp!;
      game.nextWaveStartingHp = null;
    }

    game.gameState.phase = GamePhase.playing;
    game.hideBetweenWavesOverlay();
  }

  /// Instantly finishes the current wave for testing/debugging.
  void forceClearWave() {
    for (final enemy in game.children.whereType<EnemyComponent>().toList()) {
      enemy.removeFromParent();
    }
    _enemiesLeftToSpawn = 0;
    _enemiesAlive = 0;
    _totalSpawned = 1;
    _startBetweenWaves(isWaveClear: true);
  }

  // ── Restart ───────────────────────────────────────────────────────────────

  /// Called by the game when the player taps AGAIN.
  /// Resets all wave state and kicks off the pre-wave-1 pause.
  void resetForRestart() {
    _enemiesLeftToSpawn = 0;
    _enemiesAlive = 0;
    _totalSpawned = 0;
    _spawnTimer = 0.0;
    _betweenTimer = 0.0;
    _startBetweenWaves();
  }
}
