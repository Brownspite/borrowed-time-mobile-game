import 'package:flutter/material.dart';

import '../loans/loan_shark.dart';
import '../loans/loan_shark_personality.dart';
import 'loan_shark_avatar.dart';

/// A sleek cyberpunk speech bubble displaying the Loan Shark's personality,
/// mood status, and current spoken line.
class LoanSharkSpeechBubble extends StatelessWidget {
  const LoanSharkSpeechBubble({
    super.key,
    required this.loanShark,
    required this.mood,
    required this.message,
    this.avatarSize = 46.0,
  });

  final LoanShark loanShark;
  final SharkMood mood;
  final String message;
  final double avatarSize;

  Color get _accentColor {
    switch (mood) {
      case SharkMood.calm:
        return const Color(0xFF4AEADC); // Cyan
      case SharkMood.annoyed:
        return const Color(0xFFFFD166); // Amber
      case SharkMood.threatening:
        return const Color(0xFFEF476F); // Crimson
    }
  }

  Color get _bubbleBackground {
    switch (mood) {
      case SharkMood.calm:
        return const Color(0xFF101720);
      case SharkMood.annoyed:
        return const Color(0xFF1E1712);
      case SharkMood.threatening:
        return const Color(0xFF220E15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shark avatar
          LoanSharkAvatar(
            personality: loanShark.personality,
            mood: mood,
            size: avatarSize,
          ),
          const SizedBox(width: 10),

          // Speech bubble card
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _bubbleBackground,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: _accentColor.withOpacity(0.7),
                  width: mood == SharkMood.threatening ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(
                      mood == SharkMood.threatening ? 0.25 : 0.12,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speaker header row (Name + Mood badge)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          loanShark.displayName.toUpperCase(),
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _accentColor.withOpacity(0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          mood.displayName,
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Spoken line text
                  Text(
                    '“$message”',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
