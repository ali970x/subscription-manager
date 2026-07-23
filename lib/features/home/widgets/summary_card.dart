import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../screens/active_accounts_screen.dart';
import '../screens/outstanding_accounts_screen.dart';
import '../screens/subscription_calendar_screen.dart';

class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final settings = ref.watch(settingsProvider);
    final allItems =
        ref.watch(subscriptionsProvider).valueOrNull ??
        const <SubscriptionModel>[];
    final pendingItems = allItems.where((item) => !item.isPaid).toList();
    final pending = pendingItems.fold<double>(
      0,
      (sum, item) =>
          sum +
          CurrencyHelper.convert(
            item.price,
            item.currency,
            settings.baseCurrency,
          ),
    );
    return stats.when(
      loading: () => const Card(
        child: SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const Card(child: ListTile(title: Text('Overview'))),
      data: (value) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF161A3D), Color(0xFF30236E)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.dashboard_customize_rounded,
                  color: Color(0xFF79E7F2),
                ),
                const SizedBox(width: 9),
                const Text(
                  'Account overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  settings.baseCurrency,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Monthly spend',
              style: TextStyle(color: Colors.white60),
            ),
            Text(
              CurrencyHelper.format(value.monthly, settings.baseCurrency),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 34,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    icon: Icons.payments_outlined,
                    label: 'Outstanding',
                    value: CurrencyHelper.format(
                      pending,
                      settings.baseCurrency,
                    ),
                    accent: const Color(0xFFFFCA68),
                    onTap: pendingItems.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OutstandingAccountsScreen(
                                accountIds: pendingItems
                                    .map((item) => item.id)
                                    .toSet(),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Metric(
                    icon: Icons.calendar_month_rounded,
                    label: 'This year',
                    value: CurrencyHelper.format(
                      value.yearly,
                      settings.baseCurrency,
                    ),
                    accent: const Color(0xFF79E7F2),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            SubscriptionCalendarScreen(items: allItems),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Metric(
                    icon: Icons.bolt_rounded,
                    label: 'Active',
                    value: '${value.activeCount}',
                    accent: const Color(0xFF9B8BFF),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ActiveAccountsScreen(items: allItems),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .08),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(height: 9),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    ),
  );
}

void showOutstandingLegacy(
  BuildContext context,
  List<SubscriptionModel> source,
) {
  final items = [...source]
    ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      maxChildSize: .92,
      builder: (context, controller) => Column(
        children: [
          const ListTile(
            leading: Icon(Icons.payments_outlined),
            title: Text(
              'Outstanding accounts',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text('Sorted by expiry date'),
          ),
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final item = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(item.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${item.email ?? item.username ?? 'No user'}\n'
                    'Expires ${item.nextRenewalDate.day}/${item.nextRenewalDate.month}/${item.nextRenewalDate.year}'
                    '${item.autoPaidOn == null ? '' : '\nAuto paid ${item.autoPaidOn!.day}/${item.autoPaidOn!.month}/${item.autoPaidOn!.year}'}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    CurrencyHelper.format(item.price, item.currency),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF9F1C),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
