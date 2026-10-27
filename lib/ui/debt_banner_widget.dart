import 'package:flutter/material.dart';

import '../loans/debt_notice.dart';

/// Dramatic banner alert shown when debts are collected or interest is added.
class DebtBannerWidget extends StatelessWidget {
  const DebtBannerWidget({
    super.key,
    required this.notices,
    this.onDismiss,
  });

  final List<DebtNotice> notices;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (notices.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: notices.map((notice) => _buildNoticeCard(context, notice)).toList(),
    );
  }

  Widget _buildNoticeCard(BuildContext context, DebtNotice notice) {
    final isInterest = notice.isOverdue;
    final primaryColor = isInterest ? const Color(0xFFFF9F1C) : const Color(0xFFEF476F);
    final bgColor = isInterest ? const Color(0xFF38220A) : const Color(0xFF381018);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isInterest ? Icons.trending_up : Icons.gavel,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notice.bannerTitle,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${notice.loanName}: ${notice.formattedPenalty}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.white70),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
