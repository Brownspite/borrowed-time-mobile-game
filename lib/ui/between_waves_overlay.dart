import 'package:flutter/material.dart';

/// Shown for 1.5 s between waves with the "Wave X cleared" message.
class BetweenWavesOverlay extends StatelessWidget {
  const BetweenWavesOverlay({super.key, required this.waveNumber});

  final int waveNumber;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              waveNumber > 0 ? 'Wave $waveNumber cleared' : 'Get ready…',
              style: const TextStyle(
                color: Color(0xFF4AEADC),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Color(0xFF4AEADC),
                    blurRadius: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              waveNumber > 0 ? 'Wave ${waveNumber + 1} incoming' : '',
              style: const TextStyle(
                color: Color(0x994AEADC),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
