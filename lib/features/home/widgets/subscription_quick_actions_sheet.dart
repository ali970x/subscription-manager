import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/subscription_provider.dart';
import '../../add_edit/screens/add_edit_screen.dart';

enum _RenewalPeriod { week, month, twoMonths }

Future<void> showSubscriptionQuickActions(
  BuildContext context,
  WidgetRef ref,
  SubscriptionModel subscription,
) async {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final dateFormat = DateFormat.yMMMd(
    Localizations.localeOf(context).languageCode,
  );

  DateTime renewedUntil(_RenewalPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      subscription.nextRenewalDate.year,
      subscription.nextRenewalDate.month,
      subscription.nextRenewalDate.day,
    );
    final base = expiry.isAfter(today) ? expiry : today;
    return switch (period) {
      _RenewalPeriod.week => base.add(const Duration(days: 7)),
      _RenewalPeriod.month => DateHelper.addMonths(base, 1),
      _RenewalPeriod.twoMonths => DateHelper.addMonths(base, 2),
    };
  }

  Future<void> renew(BuildContext sheetContext, _RenewalPeriod period) async {
    final nextDate = renewedUntil(period);
    await ref
        .read(subscriptionsProvider.notifier)
        .save(subscription.copyWith(nextRenewalDate: nextDate, isActive: true));
    if (sheetContext.mounted) Navigator.pop(sheetContext);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'تم التجديد حتى ${dateFormat.format(nextDate)}'
              : 'Renewed until ${dateFormat.format(nextDate)}',
        ),
      ),
    );
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final options = [
        (
          period: _RenewalPeriod.week,
          label: isArabic ? 'أسبوع' : '1 week',
          icon: Icons.date_range_rounded,
        ),
        (
          period: _RenewalPeriod.month,
          label: isArabic ? 'شهر' : '1 month',
          icon: Icons.calendar_view_month_rounded,
        ),
        (
          period: _RenewalPeriod.twoMonths,
          label: isArabic ? 'شهران' : '2 months',
          icon: Icons.event_repeat_rounded,
        ),
      ];

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * .82,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SubscriptionLogo(
                    name: subscription.name,
                    fallback: subscription.iconName ?? '•',
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${isArabic ? 'ينتهي في' : 'Expires'} ${dateFormat.format(subscription.nextRenewalDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: isArabic ? 'تعديل التفاصيل' : 'Edit details',
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Future<void>.delayed(Duration.zero, () async {
                        if (!context.mounted) return;
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditScreen(subscription: subscription),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                isArabic ? 'تجديد الاشتراك' : 'Renew subscription',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 16) / 3;
                  return Wrap(
                    spacing: 8,
                    children: options.map((option) {
                      final nextDate = renewedUntil(option.period);
                      return SizedBox(
                        width: itemWidth,
                        child: Material(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: .58,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => renew(sheetContext, option.period),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 15,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    option.icon,
                                    color: theme.colorScheme.primary,
                                    size: 27,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    option.label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    dateFormat.format(nextDate),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.alternate_email_rounded,
                label: isArabic ? 'نسخ البريد الإلكتروني' : 'Copy email',
                enabled: (subscription.email ?? '').isNotEmpty,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: subscription.email ?? ''),
                  );
                  if (!sheetContext.mounted) return;
                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        isArabic ? 'تم نسخ البريد' : 'Email copied',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                icon: subscription.isActive
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                label: subscription.isActive
                    ? (isArabic
                          ? 'إيقاف الاشتراك مؤقتاً'
                          : 'Pause subscription')
                    : (isArabic ? 'استئناف الاشتراك' : 'Resume subscription'),
                onPressed: () async {
                  await ref
                      .read(subscriptionsProvider.notifier)
                      .toggle(subscription);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: sheetContext,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(
                        isArabic
                            ? 'حذف هذا الاشتراك؟'
                            : 'Delete this subscription?',
                      ),
                      content: Text(
                        isArabic
                            ? 'لا يمكن التراجع عن هذا الإجراء.'
                            : 'This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(context.l10n.text('cancel')),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                          ),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(context.l10n.text('delete')),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  await ref
                      .read(subscriptionsProvider.notifier)
                      .delete(subscription.id);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(isArabic ? 'حذف الاشتراك' : 'Delete subscription'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      alignment: AlignmentDirectional.centerStart,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    onPressed: enabled ? onPressed : null,
    icon: Icon(icon),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}
