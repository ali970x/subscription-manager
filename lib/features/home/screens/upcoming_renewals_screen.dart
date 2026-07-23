import 'package:flutter/material.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../data/models/subscription_model.dart';
import '../widgets/subscription_list_tile.dart';

class UpcomingRenewalsScreen extends StatelessWidget {
  const UpcomingRenewalsScreen({super.key, required this.items});
  final List<SubscriptionModel> items;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]
      ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
    final urgent = sorted.where(
      (item) => item.nextRenewalDate.daysFromNow <= 2,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Renewals')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A4DF5), Color(0xFF8A5AF5)],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6857F5).withValues(alpha: .25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sorted.length} renewals in the next 7 days',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        urgent.isEmpty
                            ? 'Everything is under control'
                            : '${urgent.length} need attention within 48 hours',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sorted by expiry date',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final item in sorted) SubscriptionListTile(subscription: item),
        ],
      ),
    );
  }
}
