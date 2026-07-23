import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';

class SubscriptionCalendarScreen extends StatefulWidget {
  const SubscriptionCalendarScreen({super.key, required this.items});
  final List<SubscriptionModel> items;

  @override
  State<SubscriptionCalendarScreen> createState() =>
      _SubscriptionCalendarScreenState();
}

class _SubscriptionCalendarScreenState
    extends State<SubscriptionCalendarScreen> {
  late DateTime displayedMonth;
  DateTime? selectedDay;

  int get year => DateTime.now().year;

  @override
  void initState() {
    super.initState();
    displayedMonth = DateTime(year, DateTime.now().month);
    final thisMonth =
        widget.items
            .where(
              (item) =>
                  item.startDate.year == displayedMonth.year &&
                  item.startDate.month == displayedMonth.month,
            )
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (thisMonth.isNotEmpty) {
      selectedDay = _dateOnly(thisMonth.first.startDate);
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Map<DateTime, List<SubscriptionModel>> get grouped {
    final result = <DateTime, List<SubscriptionModel>>{};
    for (final item in widget.items.where(
      (item) => item.startDate.year == year,
    )) {
      result.putIfAbsent(_dateOnly(item.startDate), () => []).add(item);
    }
    return result;
  }

  Color colorFor(SubscriptionModel item) {
    final clean = item.colorHex.replaceAll('#', '');
    final value = int.tryParse(clean, radix: 16);
    if (value == null) return const Color(0xFF6C63FF);
    return Color(clean.length == 6 ? 0xFF000000 | value : value);
  }

  void changeMonth(int delta) {
    final next = DateTime(displayedMonth.year, displayedMonth.month + delta);
    if (next.year != year) return;
    setState(() {
      displayedMonth = next;
      selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(displayedMonth.year, displayedMonth.month);
    final leadingEmpty = first.weekday - 1;
    final days = DateUtils.getDaysInMonth(
      displayedMonth.year,
      displayedMonth.month,
    );
    final cells = ((leadingEmpty + days) / 7).ceil() * 7;
    final selectedItems = selectedDay == null
        ? const <SubscriptionModel>[]
        : grouped[selectedDay] ?? const <SubscriptionModel>[];

    return Scaffold(
      appBar: AppBar(title: Text('Subscription calendar · $year')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: .4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: displayedMonth.month == 1
                          ? null
                          : () => changeMonth(-1),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat.yMMMM(
                          Localizations.localeOf(context).languageCode,
                        ).format(displayedMonth),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: displayedMonth.month == 12
                          ? null
                          : () => changeMonth(1),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final day in [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ])
                      Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: .82,
                  ),
                  itemCount: cells,
                  itemBuilder: (context, index) {
                    final day = index - leadingEmpty + 1;
                    if (day < 1 || day > days) return const SizedBox.shrink();
                    final date = DateTime(
                      displayedMonth.year,
                      displayedMonth.month,
                      day,
                    );
                    final subscriptions =
                        grouped[date] ?? const <SubscriptionModel>[];
                    final selected = selectedDay == date;
                    return Padding(
                      padding: const EdgeInsets.all(2),
                      child: Material(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(13),
                          onTap: () => setState(() => selectedDay = date),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$day',
                                style: TextStyle(
                                  fontWeight: subscriptions.isNotEmpty
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                height: 6,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (final item in subscriptions.take(
                                      3,
                                    )) ...[
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: colorFor(item),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (selectedDay == null)
            _Hint(
              icon: Icons.touch_app_outlined,
              text: 'Tap a day with dots to view its subscriptions.',
            )
          else if (selectedItems.isEmpty)
            _Hint(
              icon: Icons.event_available_outlined,
              text:
                  'No subscriptions started on '
                  '${DateFormat.MMMMd().format(selectedDay!)}.',
            )
          else ...[
            Text(
              '${selectedItems.length} subscription${selectedItems.length == 1 ? '' : 's'} · '
              '${DateFormat.yMMMMd().format(selectedDay!)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 11),
            for (final item in selectedItems)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: SubscriptionLogo(name: item.name, size: 48),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(item.email ?? item.username ?? 'No user'),
                  trailing: Text(
                    CurrencyHelper.format(item.price, item.currency),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .35),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
