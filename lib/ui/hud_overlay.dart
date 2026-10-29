import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/player_stats.dart';
import '../game/borrowed_time_game.dart';
import '../loans/loan_registry.dart';
import '../loans/loan_shark_personality.dart';
import 'compact_debt_hud.dart';

/// Minimal HUD drawn on top of the game canvas via GameWidget overlays.
/// Shows HP bar, score, current wave number, plus temporary debug tools to force-give loans.
class HudOverlay extends StatefulWidget {
  const HudOverlay({
    super.key,
    required this.game,
    required this.gameState,
    required this.playerStats,
  });

  final BorrowedTimeGame game;
  final GameState gameState;
  final PlayerStats playerStats;

  @override
  State<HudOverlay> createState() => HudOverlayState();
}

class HudOverlayState extends State<HudOverlay> {
  bool _lowHpAlerted = false;

  void refresh() {
    if (!mounted) return;
    final hpFraction = widget.playerStats.maxHp > 0
        ? widget.playerStats.hp / widget.playerStats.maxHp
        : 1.0;
    if (hpFraction <= 0.3 && hpFraction > 0 && !_lowHpAlerted) {
      _lowHpAlerted = true;
      widget.game.loanShark.speak(
        SharkDialogueCategory.playerLowHp,
        debtLevel: widget.game.debtManager.totalDebtLevel,
      );
    } else if (hpFraction > 0.35) {
      _lowHpAlerted = false;
    }
    setState(() {});
  }

  void _openDebugModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF14141E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeDebts = widget.game.debtManager.activeDebts;
            final debtLevel = widget.game.debtManager.totalDebtLevel;

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DEBUG LOAN CONTROLS',
                          style: TextStyle(
                            color: Color(0xFF4AEADC),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),

                    // Quick Actions
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.fast_forward, size: 16),
                          label: const Text('Force Clear Wave'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A3C),
                            foregroundColor: const Color(0xFF4AEADC),
                          ),
                          onPressed: () {
                            widget.game.debugForceWaveClear();
                            setModalState(() {});
                            refresh();
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.bolt, size: 16),
                          label: const Text('Test Dash'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A3C),
                            foregroundColor: Colors.amberAccent,
                          ),
                          onPressed: () {
                            widget.game.player.dash();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Debt Status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL DEBT PRESSURE:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$debtLevel',
                                style: const TextStyle(
                                  color: Color(0xFFEF476F),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Active Debts: ${activeDebts.length}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          if (activeDebts.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ...activeDebts.map((d) => _buildActiveDebtTile(d, setModalState)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'FORCE-GIVE ANY LOAN (TAP TO APPLY):',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // All 15 loans
                    ...LoanRegistry.getAll().map((loan) {
                      final isCurrentlyActive =
                          activeDebts.any((d) => d.loan.id == loan.id);
                      return Card(
                        color: isCurrentlyActive
                            ? const Color(0xFF233038)
                            : const Color(0xFF1B1B26),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            loan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonus: ${loan.description}',
                                style: const TextStyle(
                                  color: Color(0xFF4AEADC),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Debt: ${loan.debtDescription} (Due: ${loan.dueInWaves} waves)',
                                style: const TextStyle(
                                  color: Color(0xFFFF8C00),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4AEADC),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () {
                              widget.game.debugGiveLoan(loan);
                              setModalState(() {});
                              refresh();
                            },
                            child: const Text('Give'),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActiveDebtTile(
    ActiveDebt debt,
    void Function(void Function()) setModalState,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF282838),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                debt.loan.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                debt.isDue
                    ? (debt.isOverdue
                        ? 'OVERDUE (+${debt.overdueWaves}) x${debt.currentPenaltyMultiplier.toStringAsFixed(1)}'
                        : 'DUE NOW')
                    : '${debt.remainingWaves} waves left',
                style: TextStyle(
                  color: debt.isDue ? const Color(0xFFEF476F) : const Color(0xFFFFD166),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Pay early: ',
                style: TextStyle(color: Colors.white60, fontSize: 10),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  widget.game.debtManager.payEarly(debt, PaymentType.hp);
                  setModalState(() {});
                  refresh();
                },
                child: const Text('HP', style: TextStyle(fontSize: 11, color: Color(0xFF4AEADC))),
              ),
              const SizedBox(width: 4),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  widget.game.debtManager.payEarly(debt, PaymentType.score);
                  setModalState(() {});
                  refresh();
                },
                child: const Text('Score', style: TextStyle(fontSize: 11, color: Color(0xFF4AEADC))),
              ),
              const SizedBox(width: 4),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  widget.game.debtManager.payEarly(debt, PaymentType.sacrificeUpgrade);
                  setModalState(() {});
                  refresh();
                },
                child: const Text('Sacrifice', style: TextStyle(fontSize: 11, color: Color(0xFFEF476F))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hpFraction =
        (widget.playerStats.hp / widget.playerStats.maxHp).clamp(0.0, 1.0);
    final hpColor = _hpColor(hpFraction);

    return Material(
      type: MaterialType.transparency,
      child: Padding(
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
              const SizedBox(width: 8),
              // Dash button for one-thumb / quick testing
              InkWell(
                onTap: () => widget.game.player.dash(),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.game.player.dashEnabled
                        ? const Color(0x334AEADC)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: widget.game.player.dashEnabled
                          ? const Color(0xFF4AEADC)
                          : Colors.white24,
                    ),
                  ),
                  child: Text(
                    'DASH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.game.player.dashEnabled
                          ? const Color(0xFF4AEADC)
                          : Colors.white38,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Score + Wave + Debug trigger ─────────────────────────────────
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
              // Debug Loans Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x334AEADC),
                  foregroundColor: const Color(0xFF4AEADC),
                  side: const BorderSide(color: Color(0xFF4AEADC)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _openDebugModal,
                child: const Text(
                  'DEBUG LOANS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          CompactDebtHud(debtManager: widget.game.debtManager),
        ],
      ),
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
