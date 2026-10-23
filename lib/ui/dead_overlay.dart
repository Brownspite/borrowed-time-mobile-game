import 'package:flutter/material.dart';

/// Death screen — shown when the player's HP reaches zero.
/// Freezes the game behind it and provides a single tap to restart.
class DeadOverlay extends StatelessWidget {
  const DeadOverlay({
    super.key,
    required this.score,
    required this.wave,
    required this.onRestart,
  });

  final int score;
  final int wave;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Absorb all taps so the game's drag handler doesn't fire
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // capture tap without triggering restart on background
      child: Container(
        color: const Color(0xCC000000),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── DEAD title ──────────────────────────────────────────────
              const Text(
                'YOU DIED',
                style: TextStyle(
                  color: Color(0xFFEF476F),
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(color: Color(0xFFEF476F), blurRadius: 30),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ── Stats ────────────────────────────────────────────────────
              _statRow('SCORE', score.toString()),
              const SizedBox(height: 6),
              _statRow('WAVE REACHED', wave.toString()),
              const SizedBox(height: 40),
              // ── AGAIN button ─────────────────────────────────────────────
              GestureDetector(
                onTap: onRestart,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4AEADC),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x884AEADC),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text(
                    'AGAIN',
                    style: TextStyle(
                      color: Color(0xFF0A0A0F),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label  ',
          style: const TextStyle(
            color: Color(0xFF4AEADC),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
