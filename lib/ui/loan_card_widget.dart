import 'package:flutter/material.dart';

import '../loans/loan.dart';

/// Renders a single loan offer card.
/// Designed for portrait mobile screens: high contrast, large typography,
/// distinct green bonus and red debt text.
class LoanCardWidget extends StatelessWidget {
  const LoanCardWidget({
    super.key,
    required this.loan,
    this.offerIndex = 0,
    this.totalOffers = 3,
  });

  final Loan loan;
  final int offerIndex;
  final int totalOffers;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.90).clamp(300.0, 380.0);

    return Container(
      width: cardWidth,
      constraints: const BoxConstraints(minHeight: 360),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4AEADC).withValues(alpha: 0.6),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4AEADC).withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Offer counter & Due badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF222234),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  'OFFER ${offerIndex + 1} OF $totalOffers',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x33FFD166),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD166)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFFFD166)),
                    const SizedBox(width: 4),
                    Text(
                      'DUE IN ${loan.dueInWaves} WAVES',
                      style: const TextStyle(
                        color: Color(0xFFFFD166),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Loan Title
          Text(
            loan.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Color(0xFF4AEADC),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── UPFRONT BONUS (GREEN) ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF003822),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00FF9D).withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, size: 16, color: Color(0xFF00FF9D)),
                    SizedBox(width: 6),
                    Text(
                      'BONUS NOW',
                      style: TextStyle(
                        color: Color(0xFF00FF9D),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  loan.description,
                  style: const TextStyle(
                    color: Color(0xFF00FF9D),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── ATTACHED DEBT (RED) ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF381018),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF476F).withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEF476F)),
                    SizedBox(width: 6),
                    Text(
                      'DEBT PENALTY',
                      style: TextStyle(
                        color: Color(0xFFEF476F),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  loan.debtDescription,
                  style: const TextStyle(
                    color: Color(0xFFEF476F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Subtle hint
          const Text(
            '← Swipe Left: TAKE  |  Swipe Right: REFUSE →',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
