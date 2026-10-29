import 'package:flutter/material.dart';

import '../loans/loan_shark_personality.dart';

/// A stylized, procedural vector avatar representing the active Loan Shark personality.
/// Uses pure Flutter shapes and text (no raster image assets) adhering to low-end Android specs.
class LoanSharkAvatar extends StatelessWidget {
  const LoanSharkAvatar({
    super.key,
    required this.personality,
    required this.mood,
    this.size = 54.0,
  });

  final LoanSharkPersonality personality;
  final SharkMood mood;
  final double size;

  Color get _moodGlowColor {
    switch (mood) {
      case SharkMood.calm:
        return const Color(0xFF4AEADC); // Cyan
      case SharkMood.annoyed:
        return const Color(0xFFFFD166); // Amber
      case SharkMood.threatening:
        return const Color(0xFFEF476F); // Crimson
    }
  }

  Color get _moodBadgeBg {
    switch (mood) {
      case SharkMood.calm:
        return const Color(0xFF1E3A3A);
      case SharkMood.annoyed:
        return const Color(0xFF3D321A);
      case SharkMood.threatening:
        return const Color(0xFF3D1520);
    }
  }

  IconData get _moodIcon {
    switch (mood) {
      case SharkMood.calm:
        return Icons.sentiment_satisfied_outlined;
      case SharkMood.annoyed:
        return Icons.sentiment_dissatisfied_outlined;
      case SharkMood.threatening:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Outer stylized avatar circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF161624),
              border: Border.all(
                color: _moodGlowColor,
                width: mood == SharkMood.threatening ? 2.5 : 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: _moodGlowColor.withOpacity(
                    mood == SharkMood.threatening ? 0.6 : 0.35,
                  ),
                  blurRadius: mood == SharkMood.threatening ? 12 : 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                personality.emojiFace,
                style: TextStyle(
                  fontSize: size * 0.52,
                  shadows: [
                    Shadow(
                      color: _moodGlowColor.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Mood indicator badge at bottom-right
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _moodBadgeBg,
                border: Border.all(
                  color: _moodGlowColor,
                  width: 1.2,
                ),
              ),
              child: Icon(
                _moodIcon,
                size: size * 0.26,
                color: _moodGlowColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
