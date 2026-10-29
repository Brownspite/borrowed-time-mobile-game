import 'package:flutter/material.dart';

import '../game/borrowed_time_game.dart';
import '../loans/active_debt.dart';
import '../loans/debt_manager.dart';
import '../loans/loan_shark_personality.dart';
import 'loan_shark_speech_bubble.dart';

/// Panel allowing players to view active debts and pay them early via HP, score,
/// or sacrificing another active upgrade.
class DebtRepaymentPanel extends StatefulWidget {
  const DebtRepaymentPanel({
    super.key,
    required this.game,
    required this.onDebtPaid,
  });

  final BorrowedTimeGame game;
  final VoidCallback onDebtPaid;

  static void show(BuildContext context, {
    required BorrowedTimeGame game,
    required VoidCallback onDebtPaid,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF141420),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DebtRepaymentPanel(
        game: game,
        onDebtPaid: onDebtPaid,
      ),
    );
  }

  @override
  State<DebtRepaymentPanel> createState() => _DebtRepaymentPanelState();
}

class _DebtRepaymentPanelState extends State<DebtRepaymentPanel> {
  DebtManager get _debtManager => widget.game.debtManager;

  void _confirmAndPay({
    required ActiveDebt debt,
    required PaymentType type,
    ActiveDebt? sacrificeTarget,
    required String costDescription,
  }) {
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        String detail;
        switch (type) {
          case PaymentType.hp:
            detail =
                'Pay $costDescription to clear ${debt.loan.name} debt?\n\nYou will KEEP the bonus effect and avoid the penalty.';
            break;
          case PaymentType.score:
            detail =
                'Pay $costDescription to clear ${debt.loan.name} debt?\n\nYou will KEEP the bonus effect and avoid the penalty.';
            break;
          case PaymentType.sacrificeUpgrade:
            detail =
                'Sacrifice ${sacrificeTarget?.loan.name} to clear ${debt.loan.name} debt?\n\n${sacrificeTarget?.loan.name} bonus will be repossessed, but ${debt.loan.name} bonus will be kept and its debt penalty cleared.';
            break;
        }

        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF4AEADC), width: 1.5),
          ),
          title: const Text(
            'CONFIRM REPAYMENT',
            style: TextStyle(
              color: Color(0xFF4AEADC),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          content: Text(
            detail,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003822),
                foregroundColor: const Color(0xFF00FF9D),
                side: const BorderSide(color: Color(0xFF00FF9D)),
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('CONFIRM PAYMENT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        final success = _debtManager.payEarly(
          debt,
          type,
          sacrificeTarget: sacrificeTarget,
        );
        if (success) {
          widget.onDebtPaid();
          widget.game.hudKey.currentState?.refresh();
          setState(() {});
        }
      }
    });
  }

  void _showSacrificeSelectionDialog(ActiveDebt debt, List<ActiveDebt> candidates) {
    if (candidates.length == 1) {
      _confirmAndPay(
        debt: debt,
        type: PaymentType.sacrificeUpgrade,
        sacrificeTarget: candidates.first,
        costDescription: 'Sacrifice ${candidates.first.loan.name}',
      );
      return;
    }

    showDialog<ActiveDebt>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEF476F), width: 1.5),
          ),
          title: const Text(
            'CHOOSE UPGRADE TO SACRIFICE',
            style: TextStyle(
              color: Color(0xFFEF476F),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: candidates.map((candidate) {
              return ListTile(
                title: Text(
                  candidate.loan.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  candidate.loan.description,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFEF476F)),
                onTap: () => Navigator.pop(dialogCtx, candidate),
              );
            }).toList(),
          ),
        );
      },
    ).then((selected) {
      if (selected != null && mounted) {
        _confirmAndPay(
          debt: debt,
          type: PaymentType.sacrificeUpgrade,
          sacrificeTarget: selected,
          costDescription: 'Sacrifice ${selected.loan.name}',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeDebts = _debtManager.activeDebts;
    final hpCost = _debtManager.hpCost.round();
    final scoreCost = _debtManager.scoreCost;
    final currentHp = widget.game.playerStats.hp.round();
    final currentScore = widget.game.gameState.score;

    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.35,
      maxChildSize: 0.90,
      expand: false,
      builder: (_, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(18),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEBT REPAYMENT PANEL',
                      style: TextStyle(
                        color: Color(0xFF4AEADC),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pay early to keep bonuses and avoid penalties',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 16),

            // Loan Shark Reaction
            LoanSharkSpeechBubble(
              loanShark: widget.game.loanShark,
              mood: widget.game.loanShark.currentMood(_debtManager),
              message: widget.game.loanShark.lastSpokenLine.isNotEmpty
                  ? widget.game.loanShark.lastSpokenLine
                  : widget.game.loanShark.speak(
                      SharkDialogueCategory.debtPaidEarly,
                      debtLevel: _debtManager.totalDebtLevel,
                    ),
            ),
            const SizedBox(height: 8),

            // Player Balances bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _resourceChip(
                    label: 'YOUR HP',
                    value: '$currentHp',
                    color: const Color(0xFF4AEADC),
                  ),
                  Container(width: 1, height: 24, color: Colors.white12),
                  _resourceChip(
                    label: 'SCORE',
                    value: '$currentScore',
                    color: const Color(0xFFFFD166),
                  ),
                  Container(width: 1, height: 24, color: Colors.white12),
                  _resourceChip(
                    label: 'ACTIVE DEBTS',
                    value: '${activeDebts.length}',
                    color: const Color(0xFFEF476F),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Edge case: No active debts
            if (activeDebts.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4AEADC).withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 36, color: Color(0xFF4AEADC)),
                    SizedBox(height: 10),
                    Text(
                      'NO ACTIVE DEBTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You are currently debt-free. Accept loan upgrades between waves to boost your run!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...activeDebts.map((debt) => _buildDebtItemCard(debt, hpCost, scoreCost)),
          ],
        );
      },
    );
  }

  Widget _resourceChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildDebtItemCard(ActiveDebt debt, int hpCost, int scoreCost) {
    final canPayHp = _debtManager.canAffordHp;
    final canPayScore = _debtManager.canAffordScore;
    final sacrificeCandidates =
        _debtManager.activeDebts.where((d) => d != debt).toList();
    final canSacrifice = sacrificeCandidates.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: debt.remainingWaves <= 1
              ? const Color(0xFFEF476F)
              : const Color(0xFF4AEADC).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                debt.loan.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: debt.isDue
                      ? const Color(0xFFEF476F)
                      : (debt.remainingWaves == 1
                          ? const Color(0x33EF476F)
                          : const Color(0x33FFD166)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  debt.isDue
                      ? 'DUE NOW'
                      : (debt.remainingWaves == 1
                          ? 'DUE NEXT WAVE'
                          : '${debt.remainingWaves} waves left'),
                  style: TextStyle(
                    color: debt.isDue
                        ? Colors.white
                        : (debt.remainingWaves == 1
                            ? const Color(0xFFEF476F)
                            : const Color(0xFFFFD166)),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bonus: ${debt.loan.description}',
            style: const TextStyle(color: Color(0xFF00FF9D), fontSize: 12),
          ),
          Text(
            'Penalty: ${debt.loan.debtDescription}',
            style: const TextStyle(color: Color(0xFFEF476F), fontSize: 11),
          ),
          const SizedBox(height: 10),

          const Text(
            'REPAY EARLY (KEEP BONUS EFFECT):',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),

          // 3 Action Buttons with exact costs
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              // Pay HP
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canPayHp ? const Color(0xFF003822) : Colors.white10,
                  foregroundColor: canPayHp ? const Color(0xFF00FF9D) : Colors.white38,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: canPayHp
                    ? () => _confirmAndPay(
                          debt: debt,
                          type: PaymentType.hp,
                          costDescription: '$hpCost HP',
                        )
                    : null,
                child: Text(
                  canPayHp ? 'Pay $hpCost HP' : 'Need > $hpCost HP',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),

              // Pay Score
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canPayScore ? const Color(0xFF2E2205) : Colors.white10,
                  foregroundColor: canPayScore ? const Color(0xFFFFD166) : Colors.white38,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: canPayScore
                    ? () => _confirmAndPay(
                          debt: debt,
                          type: PaymentType.score,
                          costDescription: '$scoreCost Score',
                        )
                    : null,
                child: Text(
                  canPayScore ? 'Pay $scoreCost Score' : 'Need $scoreCost Score',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),

              // Sacrifice Upgrade
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSacrifice ? const Color(0xFF381018) : Colors.white10,
                  foregroundColor: canSacrifice ? const Color(0xFFEF476F) : Colors.white38,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: canSacrifice
                    ? () => _showSacrificeSelectionDialog(debt, sacrificeCandidates)
                    : null,
                child: Text(
                  canSacrifice ? 'Sacrifice Upgrade' : 'No Upgrades to Sacrifice',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
