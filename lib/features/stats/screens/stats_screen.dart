import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/category_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_chart.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  String period = 'thisMonth';

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final currency = ref.watch(settingsProvider).baseCurrency;
    return stats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(context.l10n.text('error'))),
      data: (value) {
        final width = MediaQuery.sizeOf(context).width;
        final sidePadding = width > 1000 ? (width - 1000) / 2 : 16.0;
        if (value.activeCount == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.donut_large_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.text('noStats'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }
        final yearlySaving = value.mostExpensive.isEmpty
            ? 0.0
            : _monthly(value.mostExpensive.first, currency) * 12;
        return ListView(
          padding: EdgeInsets.fromLTRB(sidePadding, 8, sidePadding, 100),
          children: [
            SegmentedButton<String>(
              segments: ['thisMonth', 'thisYear', 'allTime']
                  .map(
                    (key) => ButtonSegment(
                      value: key,
                      label: Text(context.l10n.text(key)),
                    ),
                  )
                  .toList(),
              selected: {period},
              onSelectionChanged: (value) =>
                  setState(() => period = value.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.payments_outlined,
                    title: context.l10n.text('monthlySpend'),
                    value: CurrencyHelper.format(value.monthly, currency),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.trending_flat_rounded,
                    title: context.l10n.text('comparison'),
                    value: context.l10n.text('stable'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: context.l10n.text('last6Months'),
              child: MonthlyChart(
                monthlyValue: value.monthly,
                currency: currency,
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: context.l10n.text('byCategory'),
              child: CategoryPieChart(data: value.byCategory),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: context.l10n.text('expensive'),
              child: Column(
                children: value.mostExpensive.take(4).map((item) {
                  final category = categoryById(
                    ref.watch(categoriesProvider),
                    item.category,
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: SubscriptionLogo(
                      name: item.name,
                      fallback: item.iconName ?? category.emoji,
                      size: 42,
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(category.name(context.l10n.isArabic)),
                    trailing: Text(
                      CurrencyHelper.format(_monthly(item, currency), currency),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA6).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF00BFA6),
                    child: Icon(Icons.savings_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.text('savingTip'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyHelper.format(yearlySaving, currency),
                          style: const TextStyle(
                            color: Color(0xFF008F7C),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  double _monthly(SubscriptionModel item, String currency) {
    final normalized = item.billingCycle == 'yearly'
        ? item.price / 12
        : item.billingCycle == 'weekly'
        ? item.price * 52 / 12
        : item.price;
    return CurrencyHelper.convert(normalized, item.currency, currency);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
  );
}
