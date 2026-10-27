import 'package:flutter/material.dart';

/// Accessible fallback buttons allowing players to accept or decline loan offers
/// with a single tap rather than swiping.
class LoanActionButtons extends StatelessWidget {
  const LoanActionButtons({
    super.key,
    required this.onTake,
    required this.onRefuse,
    this.takeLabel = 'TAKE LOAN',
    this.refuseLabel = 'REFUSE',
  });

  final VoidCallback onTake;
  final VoidCallback onRefuse;
  final String takeLabel;
  final String refuseLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── TAKE BUTTON (Left side / Swipe Left) ──────────────────────
          Expanded(
            child: Semantics(
              button: true,
              label: 'Accept and take loan',
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003822),
                    foregroundColor: const Color(0xFF00FF9D),
                    elevation: 4,
                    shadowColor: const Color(0x6600FF9D),
                    side: const BorderSide(
                      color: Color(0xFF00FF9D),
                      width: 1.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: onTake,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back, size: 18, color: Color(0xFF00FF9D)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          takeLabel,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── REFUSE BUTTON (Right side / Swipe Right) ───────────────────
          Expanded(
            child: Semantics(
              button: true,
              label: 'Refuse loan',
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF381018),
                    foregroundColor: const Color(0xFFEF476F),
                    elevation: 4,
                    shadowColor: const Color(0x66EF476F),
                    side: const BorderSide(
                      color: Color(0xFFEF476F),
                      width: 1.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: onRefuse,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          refuseLabel,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 18, color: Color(0xFFEF476F)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
