import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import '../components/arena_border.dart';
import '../components/bullet.dart';
import '../components/enemy.dart';
import '../components/player.dart';
import '../core/constants.dart';
import '../core/game_phase.dart';
import '../core/game_state.dart';
import '../core/player_stats.dart';
import '../loans/loan_registry.dart';
import '../ui/between_waves_overlay.dart';
import '../ui/dead_overlay.dart';
import '../ui/hud_overlay.dart';
import 'wave_manager.dart';

/// Overlay key constants — keeps magic strings in one place.
abstract class _OverlayKeys {
  static const String hud = 'hud';
  static const String dead = 'dead';
  static const String betweenWaves = 'betweenWaves';
}

class BorrowedTimeGame extends FlameGame
    with DragCallbacks, HasCollisionDetection {
  // ── Shared state (survives restarts) ─────────────────────────────────────
  final GameState gameState = GameState();
  final PlayerStats playerStats = PlayerStats();
  late final DebtManager debtManager;
  final GlobalKey<HudOverlayState> hudKey = GlobalKey<HudOverlayState>();

  // ── Loan offer state ───────────────────────────────────────────────────────
  LoanOfferController? currentOfferController;

  // ── Loan-related modifiers & effects ─────────────────────────────────────
  double scoreMultiplier = 1.0;
  double enemySpeedMultiplier = 1.0;
  double enemyCountMultiplier = 1.0;
  double arenaShrinkFactor = 0.0;
  bool explosiveKillsEnabled = false;
  bool explosionsHurtPlayer = false;
  double explosionSelfDamage = LoanTuning.explosionSelfDamage;
  double? nextWaveStartingHp;

  // ── Arena bounds (updated on resize) ─────────────────────────────────────
  late Rect arenaBounds;

  // ── Input ─────────────────────────────────────────────────────────────────
  final Vector2 moveDirection = Vector2.zero();
  final Vector2 _dragStart = Vector2.zero();
  bool _isDragging = false;

  // ── Component references ──────────────────────────────────────────────────
  late PlayerComponent player;
  late WaveManager _waveManager;

  // ── HUD tick throttle ─────────────────────────────────────────────────────
  // Refresh the Flutter HUD ~10× per second rather than every frame.
  double _hudTimer = 0.0;
  static const double _hudRefreshInterval = 0.1;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    debtManager = DebtManager(game: this);
    _updateArenaBounds();
    await add(ArenaBorder());
    await _addPlayer();
    _waveManager = WaveManager();
    await add(_waveManager);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateArenaBounds();
  }

  void _updateArenaBounds() {
    const p = GameConstants.arenaPadding;
    final baseW = size.x - p * 2;
    final baseH = size.y - p * 2;
    final shrinkW = baseW * arenaShrinkFactor;
    final shrinkH = baseH * arenaShrinkFactor;
    arenaBounds = Rect.fromLTWH(
      p + shrinkW / 2,
      p + shrinkH / 2,
      baseW - shrinkW,
      baseH - shrinkH,
    );
  }

  void setArenaShrink(double factor) {
    arenaShrinkFactor = factor;
    _updateArenaBounds();
    if (isLoaded) {
      player.position.x = player.position.x.clamp(
        arenaBounds.left + GameConstants.playerRadius,
        arenaBounds.right - GameConstants.playerRadius,
      );
      player.position.y = player.position.y.clamp(
        arenaBounds.top + GameConstants.playerRadius,
        arenaBounds.bottom - GameConstants.playerRadius,
      );
    }
  }

  void setNextWaveStartingHp(double hp) {
    nextWaveStartingHp = hp;
  }

  void onEnemyKilled(EnemyComponent enemy) {
    final points = (GameConstants.scorePerKill * scoreMultiplier).round();
    gameState.score += points;
    player.onEnemyKilled();
    if (explosiveKillsEnabled) {
      triggerEnemyExplosion(enemy.position);
    }
  }

  void triggerEnemyExplosion(Vector2 pos) {
    final radius = LoanTuning.explosionRadius;
    final radiusSq = radius * radius;
    for (final child in children) {
      if (child is EnemyComponent && !child.isRemoving && child.hp > 0) {
        final dx = child.position.x - pos.x;
        final dy = child.position.y - pos.y;
        if (dx * dx + dy * dy <= radiusSq) {
          child.takeDamage(LoanTuning.explosionDamage);
        }
      }
    }
    if (explosionsHurtPlayer) {
      final pdx = player.position.x - pos.x;
      final pdy = player.position.y - pos.y;
      if (pdx * pdx + pdy * pdy <= radiusSq) {
        player.takeExplosionDamage(explosionSelfDamage);
      }
    }
  }

  // ── Debug helpers ────────────────────────────────────────────────────────
  void debugGiveLoan(Loan loan) {
    debtManager.addLoan(loan);
  }

  void debugForceWaveClear() {
    _waveManager.forceClearWave();
  }

  Future<void> _addPlayer() async {
    player = PlayerComponent(stats: playerStats);
    await add(player);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Game loop
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    // Freeze everything while dead
    if (gameState.phase == GamePhase.dead) return;

    super.update(dt);

    // Throttled HUD refresh
    _hudTimer += dt;
    if (_hudTimer >= _hudRefreshInterval) {
      _hudTimer = 0.0;
      _refreshHud();
    }
  }

  void _refreshHud() {
    hudKey.currentState?.refresh();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Phase transitions
  // ─────────────────────────────────────────────────────────────────────────

  /// Called by PlayerComponent when hp drops to 0.
  void onPlayerDied() {
    if (gameState.phase == GamePhase.dead) return; // guard double-trigger
    gameState.phase = GamePhase.dead;
    moveDirection.setZero();
    _isDragging = false;
    try {
      overlays.remove(_OverlayKeys.betweenWaves);
      overlays.add(_OverlayKeys.dead);
    } catch (_) {}
  }

  WaveManager get waveManager => _waveManager;

  void startLoanOffers() {
    final activeIds = debtManager.activeDebts.map((d) => d.loan.id).toList();
    final controller = LoanOfferController(activeLoanIds: activeIds);
    if (controller.offers.isNotEmpty) {
      currentOfferController = controller;
      pauseEngine();
    } else {
      currentOfferController = null;
    }
    showBetweenWavesOverlay();
  }

  void onLoanOffersCompleted() {
    currentOfferController = null;
    resumeEngine();
    _waveManager.startNextWave();
  }

  void showBetweenWavesOverlay() {
    try {
      overlays.add(_OverlayKeys.betweenWaves);
    } catch (_) {}
  }

  void hideBetweenWavesOverlay() {
    try {
      overlays.remove(_OverlayKeys.betweenWaves);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Restart
  // ─────────────────────────────────────────────────────────────────────────

  /// Wipes everything and starts wave 1. No loading — all components
  /// stay in the tree; only their state is reset.
  void restart() {
    // 1. Reset data
    gameState.reset();
    playerStats.reset();
    debtManager.reset();
    scoreMultiplier = 1.0;
    enemySpeedMultiplier = 1.0;
    enemyCountMultiplier = 1.0;
    arenaShrinkFactor = 0.0;
    explosiveKillsEnabled = false;
    explosionsHurtPlayer = false;
    explosionSelfDamage = LoanTuning.explosionSelfDamage;
    nextWaveStartingHp = null;
    _updateArenaBounds();
    if (paused) resumeEngine();
    currentOfferController = null;
    moveDirection.setZero();
    _isDragging = false;

    // Process any pending adds so they can be cleaned up
    processLifecycleEvents();

    // 2. Remove all transient components (enemies, bullets)
    children.whereType<EnemyComponent>().toList().forEach((e) {
      e.removeFromParent();
    });
    children.whereType<BulletComponent>().toList().forEach((b) {
      b.removeFromParent();
    });

    // 3. Reset player position and fire timer
    player.resetForRestart();

    // 4. Reset wave manager — it will re-enter betweenWaves and show the overlay
    _waveManager.resetForRestart();

    // 5. Swap overlays: remove dead + any stale betweenWaves first;
    //    resetForRestart already called showBetweenWavesOverlay so we just
    //    remove the dead overlay.
    try {
      overlays.remove(_OverlayKeys.dead);
    } catch (_) {}
    _refreshHud();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Input
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (gameState.phase == GamePhase.dead) return;
    _isDragging = true;
    _dragStart.setFrom(event.canvasPosition);
    moveDirection.setZero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isDragging || gameState.phase == GamePhase.dead) return;

    final current = event.canvasEndPosition;
    final dx = current.x - _dragStart.x;
    final dy = current.y - _dragStart.y;
    final distSq = dx * dx + dy * dy;

    const deadZone = GameConstants.joystickDeadZone;
    const maxRadius = GameConstants.joystickRadius;

    if (distSq > deadZone * deadZone) {
      final dist = math.sqrt(distSq);
      final normX = dx / dist;
      final normY = dy / dist;
      final factor = (dist / maxRadius).clamp(0.0, 1.0);
      moveDirection.setValues(normX * factor, normY * factor);

      if (dist > maxRadius) {
        _dragStart.setValues(
          current.x - normX * maxRadius,
          current.y - normY * maxRadius,
        );
      }
    } else {
      moveDirection.setZero();
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    moveDirection.setZero();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;
    moveDirection.setZero();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Overlay builder helpers (used by main.dart)
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the overlay map consumed by GameWidget.
  Map<String, OverlayWidgetBuilder<BorrowedTimeGame>> buildOverlayMap() {
    return {
      _OverlayKeys.hud: (context, game) => HudOverlay(
            key: game.hudKey,
            game: game,
            gameState: game.gameState,
            playerStats: game.playerStats,
          ),
      _OverlayKeys.dead: (context, game) => DeadOverlay(
            score: game.gameState.score,
            wave: game.gameState.wave,
            onRestart: game.restart,
          ),
      _OverlayKeys.betweenWaves: (context, game) => BetweenWavesOverlay(
            waveNumber: game.gameState.wave,
          ),
    };
  }

  /// The HUD should be shown from the very start.
  static const String initialOverlay = _OverlayKeys.hud;
}
