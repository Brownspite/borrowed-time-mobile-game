import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/player_stats.dart';

/// Minimal HUD drawn on top of the game canvas via GameWidget overlays.
/// Shows: HP bar, score, and current wave number.
class HudOverlay extends StatefulWidget {
  const HudOverlay({
    super.key,
    required this.gameState,
    required this.playerStats,
  });

  final GameState gameState;
  final PlayerStats playerStats;

  @override
  State<HudOverlay> createState() => HudOverlayState();
}

class HudOverlayState extends State<HudOverlay> {
  /// Call this from the game's update loop (or a notifier) to rebuild the HUD.
  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hpFraction =
        (widget.playerStats.hp / widget.playerStats.maxHp).clamp(0.0, 1.0);
    final hpColor = _hpColor(hpFraction);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── HP bar ──────────────────────────────────────────────────────
          Row(
            children: [
              const Text(
                'HP',
                style: TextStyle(
                  color: Color(0xFF4AEADC),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: hpFraction,
                    minHeight: 8,
                    backgroundColor: const Color(0x33FFFFFF),
                    valueColor: AlwaysStoppedAnimation<Color>(hpColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Score + Wave ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('SCORE', widget.gameState.score.toString()),
              _label(
                'WAVE',
                widget.gameState.wave > 0
                    ? widget.gameState.wave.toString()
                    : '—',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF4AEADC),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Color _hpColor(double fraction) {
    if (fraction > 0.5) return GameConstants.arenaBorderColor;
    if (fraction > 0.25) return const Color(0xFFFFD166);
    return const Color(0xFFEF476F);
  }
}
