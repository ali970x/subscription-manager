import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../data/models/subscription_model.dart';
import '../../add_edit/screens/add_edit_screen.dart';
import '../../add_edit/widgets/json_subscription_importer.dart';
import 'upcoming_renewals_screen.dart';
import '../widgets/category_account_group.dart';
import '../widgets/summary_card.dart';
import '../widgets/upcoming_renewals_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final categories = ref.watch(categoriesProvider);
    return subscriptions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 44),
              const SizedBox(height: 12),
              Text(
                '${context.l10n.text('error')}\n$error',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (items) {
        final width = MediaQuery.sizeOf(context).width;
        final sidePadding = width > 1100 ? (width - 1100) / 2 : 16.0;
        final upcoming = items
            .where((e) => e.isActive && e.nextRenewalDate.isWithinNextWeek)
            .toList();
        final groups = <String, List<SubscriptionModel>>{};
        for (final item in items) {
          groups.putIfAbsent(item.category, () => []).add(item);
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(subscriptionsProvider),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              sidePadding,
              MediaQuery.paddingOf(context).top + 12,
              sidePadding,
              110,
            ),
            children: [
              const _HomeHeader(),
              const SizedBox(height: 22),
              const SummaryCard(),
              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: 28),
                _Header(
                  title: context.l10n.text('upcoming'),
                  trailing: context.l10n.text('within7'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UpcomingRenewalsScreen(items: upcoming),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 164,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UpcomingRenewalsScreen(items: upcoming),
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcoming.length,
                      itemBuilder: (_, i) =>
                          UpcomingRenewalCard(subscription: upcoming[i]),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              _Header(
                title: context.l10n.text('allSubscriptions'),
                trailing: '${items.length}',
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                _EmptyState(
                  onAdd: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddEditScreen()),
                  ),
                )
              else
                for (final entry in groups.entries)
                  CategoryAccountGroup(
                    category: categoryById(categories, entry.key),
                    items: entry.value,
                  ),
              const SizedBox(height: 8),
              Text(
                context.l10n.text('disableHint'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.trailing, this.onTap});
  final String title;
  final String trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 3),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/branding/subtrack_icon.png',
          width: 52,
          height: 52,
        ),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.text('appName'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -.6,
              ),
            ),
            Text(
              context.l10n.text('hello'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7D819D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Add from JSON',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const JsonSubscriptionImporter(),
        ),
        icon: const Icon(Icons.data_object_rounded),
      ),
      const SizedBox(width: 5),
      IconButton.filledTonal(
        tooltip: context.l10n.text('add'),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddEditScreen())),
        icon: const Icon(Icons.add_rounded),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 40),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.text('noSubscriptions'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.text('emptyHint'), textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(context.l10n.text('add')),
          ),
        ],
      ),
    ),
  );
}
