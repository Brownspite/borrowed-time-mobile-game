import 'package:flutter/material.dart';

import '../loans/active_debt.dart';
import '../loans/debt_manager.dart';

/// Compact HUD component displaying active debts and remaining wave countdowns.
/// Debts due next wave (remainingWaves == 1) or overdue pulse red.
class CompactDebtHud extends StatefulWidget {
  const CompactDebtHud({
    super.key,
    required this.debtManager,
  });

  final DebtManager debtManager;

  @override
  State<CompactDebtHud> createState() => _CompactDebtHudState();
}

class _CompactDebtHudState extends State<CompactDebtHud>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _pulseAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debts = widget.debtManager.activeDebts;
    if (debts.isEmpty) {
      if (_pulseController.isAnimating) _pulseController.stop();
      return const SizedBox.shrink();
    }

    final hasUrgentDebt = debts.any((d) => d.remainingWaves == 1 || d.isDue);
    if (hasUrgentDebt && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!hasUrgentDebt && _pulseController.isAnimating) {
      _pulseController.stop();
    }

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: debts.map((debt) => _buildDebtChip(debt)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDebtChip(ActiveDebt debt) {
    final isDueNextWave = debt.remainingWaves == 1;
    final isAlreadyDue = debt.isDue;
    final needsPulse = isDueNextWave || isAlreadyDue;

    final pulseFactor = needsPulse ? _pulseAnim.value : 0.0;
    final borderColor = needsPulse
        ? Color.lerp(
            const Color(0xFFEF476F).withValues(alpha: 0.4),
            const Color(0xFFEF476F),
            pulseFactor,
          )!
        : const Color(0xFF4AEADC).withValues(alpha: 0.5);

    final bgColor = needsPulse
        ? Color.lerp(
            const Color(0x33EF476F),
            const Color(0x88EF476F),
            pulseFactor,
          )!
        : const Color(0xFF1B1B28);

    String statusText;
    if (debt.isDue) {
      statusText = debt.isOverdue ? 'OVERDUE (+${debt.overdueWaves})' : 'DUE NOW';
    } else {
      statusText = '${debt.remainingWaves}w left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: needsPulse ? 1.5 : 1.0),
        boxShadow: needsPulse
            ? [
                BoxShadow(
                  color: const Color(0xFFEF476F).withValues(alpha: 0.35 * pulseFactor),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (needsPulse)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 11,
                color: borderColor,
              ),
            ),
          Text(
            debt.loan.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: needsPulse
                  ? const Color(0xFFEF476F).withValues(alpha: 0.3)
                  : const Color(0x334AEADC),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: needsPulse ? const Color(0xFFFF8A9E) : const Color(0xFF4AEADC),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
