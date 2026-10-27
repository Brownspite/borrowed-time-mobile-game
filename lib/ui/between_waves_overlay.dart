import 'package:flutter/material.dart';

import '../game/borrowed_time_game.dart';
import 'loan_action_buttons.dart';
import 'swipable_loan_card.dart';

/// Between-waves overlay.
/// When wave == 0 (before wave 1 starts), shows the intro "Get ready..." countdown.
/// When wave >= 1 (after a wave clears), pauses the game and sequentially presents
/// 3 loan offer cards with swipe or button controls.
class BetweenWavesOverlay extends StatefulWidget {
  const BetweenWavesOverlay({
    super.key,
    required this.waveNumber,
    this.game,
  });

  final int waveNumber;
  final BorrowedTimeGame? game;

  @override
  State<BetweenWavesOverlay> createState() => _BetweenWavesOverlayState();
}

class _BetweenWavesOverlayState extends State<BetweenWavesOverlay> {
  final GlobalKey<SwipableLoanCardState> _cardKey =
      GlobalKey<SwipableLoanCardState>();

  void _handleDecision({required bool accepted}) {
    final controller = widget.game?.currentOfferController;
    if (controller == null) return;

    final loan = controller.currentLoan;
    if (loan != null && accepted) {
      widget.game?.debtManager.addLoan(loan);
      widget.game?.hudKey.currentState?.refresh();
    }
    controller.recordDecision(accepted: accepted);

    if (controller.isComplete) {
      widget.game?.onLoanOffersCompleted();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.game?.currentOfferController;

    // Intro / No-offers countdown state (e.g. wave 0 before wave 1 starts)
    if (controller == null || controller.isComplete) {
      return IgnorePointer(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.waveNumber > 0
                    ? 'Wave ${widget.waveNumber} cleared'
                    : 'Get ready…',
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
                widget.waveNumber > 0
                    ? 'Wave ${widget.waveNumber + 1} incoming'
                    : 'Wave 1 incoming',
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

    final currentLoan = controller.currentLoan!;
    final offerIndex = controller.currentIndex;
    final totalOffers = controller.totalOffers;

    return Material(
      color: const Color(0xCC0A0A12),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    'Wave ${widget.waveNumber} cleared',
                    style: const TextStyle(
                      color: Color(0xFF4AEADC),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Color(0xFF4AEADC),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'THE LOAN SHARK OFFERS UPGRADES',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Swipable Card
                  SwipableLoanCard(
                    key: _cardKey,
                    loan: currentLoan,
                    offerIndex: offerIndex,
                    totalOffers: totalOffers,
                    onTake: () => _handleDecision(accepted: true),
                    onRefuse: () => _handleDecision(accepted: false),
                  ),
                  const SizedBox(height: 12),

                  // Accessibility Fallback Buttons
                  LoanActionButtons(
                    onTake: () {
                      if (_cardKey.currentState != null) {
                        _cardKey.currentState!.dismissLeft();
                      } else {
                        _handleDecision(accepted: true);
                      }
                    },
                    onRefuse: () {
                      if (_cardKey.currentState != null) {
                        _cardKey.currentState!.dismissRight();
                      } else {
                        _handleDecision(accepted: false);
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalOffers, (idx) {
                      final isCurrent = idx == offerIndex;
                      final isPast = idx < offerIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isCurrent ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF4AEADC)
                              : (isPast ? Colors.white38 : Colors.white12),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isCurrent
                              ? [
                                  const BoxShadow(
                                    color: Color(0xFF4AEADC),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
