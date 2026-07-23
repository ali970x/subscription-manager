import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/subscription_model.dart';

class RenewalProgress extends StatelessWidget {
  const RenewalProgress({
    super.key,
    required this.subscription,
    required this.accent,
  });

  final SubscriptionModel subscription;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      subscription.startDate.year,
      subscription.startDate.month,
      subscription.startDate.day,
    );
    final renewal = DateTime(
      subscription.nextRenewalDate.year,
      subscription.nextRenewalDate.month,
      subscription.nextRenewalDate.day,
    );
    final totalDays = renewal.difference(start).inDays.clamp(1, 100000);
    final elapsedDays = today.difference(start).inDays.clamp(0, totalDays);
    final remainingDays = renewal.difference(today).inDays;
    final progress = elapsedDays / totalDays;
    final color = remainingDays <= 3
        ? const Color(0xFFEF5B6C)
        : remainingDays <= 7
        ? const Color(0xFFFFA726)
        : accent;

    final String label;
    if (remainingDays < 0) {
      label = context.l10n.isArabic ? 'منتهي' : 'Expired';
    } else if (remainingDays < 45) {
      label = context.l10n.isArabic
          ? 'متبقي $remainingDays يوم'
          : '$remainingDays days remaining';
    } else {
      final months = (remainingDays / 30).ceil();
      label = context.l10n.isArabic
          ? 'متبقي $months أشهر'
          : '$months months remaining';
    }

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: .13),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
