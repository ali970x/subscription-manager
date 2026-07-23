import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class BillingCycleSelector extends StatelessWidget {
  const BillingCycleSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.text('billingCycle'),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'monthly',
              label: Text(context.l10n.text('monthly')),
              icon: const Icon(Icons.calendar_view_month_rounded),
            ),
            ButtonSegment(
              value: 'yearly',
              label: Text(context.l10n.text('yearly')),
              icon: const Icon(Icons.event_repeat_rounded),
            ),
            ButtonSegment(
              value: 'weekly',
              label: Text(context.l10n.text('weekly')),
              icon: const Icon(Icons.view_week_outlined),
            ),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
      ),
    ],
  );
}
