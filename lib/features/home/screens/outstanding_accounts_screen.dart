import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../add_edit/screens/add_edit_screen.dart';

class OutstandingAccountsScreen extends ConsumerStatefulWidget {
  const OutstandingAccountsScreen({super.key, required this.accountIds});
  final Set<String> accountIds;

  @override
  ConsumerState<OutstandingAccountsScreen> createState() =>
      _OutstandingAccountsScreenState();
}

class _OutstandingAccountsScreenState
    extends ConsumerState<OutstandingAccountsScreen> {
  bool markingAll = false;

  List<SubscriptionModel> outstandingItems() {
    final all = ref.watch(subscriptionsProvider).valueOrNull ?? [];
    return all
        .where((item) => widget.accountIds.contains(item.id) && !item.isPaid)
        .toList()
      ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
  }

  String report(List<SubscriptionModel> items, String currency) {
    final total = items.fold<double>(
      0,
      (sum, item) =>
          sum + CurrencyHelper.convert(item.price, item.currency, currency),
    );
    final buffer = StringBuffer()
      ..writeln('OUTSTANDING ACCOUNTS')
      ..writeln('Accounts: ${items.length}')
      ..writeln('Total: ${CurrencyHelper.format(total, currency)}')
      ..writeln(
        'Generated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
      )
      ..writeln();
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      buffer
        ..writeln('${i + 1}. ${item.name}')
        ..writeln('Email: ${item.email ?? '-'}')
        ..writeln('Username: ${item.username ?? '-'}')
        ..writeln('Password: ${item.password ?? '-'}')
        ..writeln('PIN: ${item.pin ?? '-'}')
        ..writeln('Price: ${CurrencyHelper.format(item.price, item.currency)}')
        ..writeln('Started: ${DateFormat.yMMMd().format(item.startDate)}')
        ..writeln(
          'Expires: ${DateFormat.yMMMd().format(item.nextRenewalDate)}',
        );
      if ((item.loginUrl ?? '').isNotEmpty) {
        buffer.writeln('Login: ${item.loginUrl}');
      }
      if ((item.codeUrl ?? '').isNotEmpty) {
        buffer.writeln('Code: ${item.codeUrl}');
      }
      if ((item.notes ?? '').isNotEmpty) {
        buffer.writeln('Notes: ${item.notes}');
      }
      buffer.writeln();
    }
    return buffer.toString().trim();
  }

  Future<void> shareReport(List<SubscriptionModel> items, String currency) =>
      Share.share(
        report(items, currency),
        subject: 'Outstanding accounts report',
      );

  Future<void> markPaid(SubscriptionModel item) async {
    await ref
        .read(subscriptionsProvider.notifier)
        .save(
          item.copyWith(
            isPaid: true,
            paymentMethod: 'Marked paid',
            paidAt: DateTime.now(),
          ),
        );
  }

  Future<void> markAllPaid(List<SubscriptionModel> outstanding) async {
    if (outstanding.isEmpty || markingAll) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark all as paid?'),
        content: Text(
          'This will mark all ${outstanding.length} outstanding accounts as paid.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.done_all_rounded),
            label: const Text('Mark all paid'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => markingAll = true);
    try {
      final ids = outstanding.map((item) => item.id).toSet();
      final all = ref.read(subscriptionsProvider).valueOrNull ?? [];
      final now = DateTime.now();
      final updated = all
          .map(
            (item) => ids.contains(item.id)
                ? item.copyWith(
                    isPaid: true,
                    paymentMethod: 'Bulk marked paid',
                    paidAt: now,
                  )
                : item,
          )
          .toList();
      await ref.read(subscriptionsProvider.notifier).replaceAll(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All accounts are now marked as paid.')),
        );
      }
    } finally {
      if (mounted) setState(() => markingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = outstandingItems();
    final currency = ref.watch(settingsProvider).baseCurrency;
    final total = items.fold<double>(
      0,
      (sum, item) =>
          sum + CurrencyHelper.convert(item.price, item.currency, currency),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outstanding accounts'),
        actions: [
          IconButton(
            tooltip: 'Share full report',
            onPressed: items.isEmpty
                ? null
                : () => shareReport(items, currency),
            icon: const Icon(Icons.share_rounded),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: IconButton.filledTonal(
              tooltip: 'Mark all paid',
              onPressed: items.isEmpty || markingAll
                  ? null
                  : () => markAllPaid(items),
              icon: markingAll
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.done_all_rounded),
            ),
          ),
        ],
      ),
      body: items.isEmpty
          ? const _AllPaid()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFEF6C4D)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyHelper.format(total, currency),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 26,
                              ),
                            ),
                            Text(
                              '${items.length} unpaid account${items.length == 1 ? '' : 's'}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFDE633F),
                        ),
                        onPressed: () => shareReport(items, currency),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (final item in items)
                  _OutstandingCard(
                    item: item,
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditScreen(subscription: item),
                      ),
                    ),
                    onPaid: () => markPaid(item),
                  ),
              ],
            ),
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  const _OutstandingCard({
    required this.item,
    required this.onEdit,
    required this.onPaid,
  });
  final SubscriptionModel item;
  final VoidCallback onEdit;
  final VoidCallback onPaid;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                SubscriptionLogo(name: item.name, size: 50),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.email ?? item.username ?? 'No user',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyHelper.format(item.price, item.currency),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE8753D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _DateLabel(
                    label: 'Started',
                    value: DateFormat.MMMd().format(item.startDate),
                  ),
                ),
                Expanded(
                  child: _DateLabel(
                    label: 'Expires',
                    value: DateFormat.MMMd().format(item.nextRenewalDate),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: onPaid,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Paid'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
}

class _AllPaid extends StatelessWidget {
  const _AllPaid();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F8EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.done_all_rounded,
              color: Color(0xFF12A774),
              size: 44,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Everything is paid',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 6),
          const Text(
            'There are no outstanding accounts.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
