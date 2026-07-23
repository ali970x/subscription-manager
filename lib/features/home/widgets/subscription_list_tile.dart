import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/account_actions.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/category_provider.dart';
import '../../add_edit/screens/add_edit_screen.dart';
import 'renewal_progress.dart';

class SubscriptionListTile extends ConsumerWidget {
  const SubscriptionListTile({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = categoryById(
      ref.watch(categoriesProvider),
      subscription.category,
    );
    return Dismissible(
      key: ValueKey(subscription.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.text('confirmDelete')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.text('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.text('delete')),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        ref.read(subscriptionsProvider.notifier).delete(subscription.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.text('deleted'))));
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFE85757),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Opacity(
        opacity: subscription.isActive ? 1 : .52,
        child: Container(
          margin: const EdgeInsets.only(bottom: 11),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: .34),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? .16
                      : .045,
                ),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onDoubleTap: () async {
              final opened = await AccountActions.openService(subscription);
              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No app or link available')),
                );
              }
            },
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditScreen(subscription: subscription),
              ),
            ),
            onLongPress: () async {
              await AccountActions.openService(subscription);
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      SubscriptionLogo(
                        name: subscription.name,
                        fallback: subscription.iconName ?? category.emoji,
                        size: 50,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              subscription.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: subscription.isActive
                                        ? const Color(0xFF12B886)
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${context.l10n.text('renewal')} ${DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(subscription.nextRenewalDate)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            CurrencyHelper.format(
                              subscription.price,
                              subscription.currency,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            context.l10n.text(subscription.billingCycle),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: category.color,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Account actions',
                        onSelected: (action) async {
                          if (action == 'email') {
                            final email = subscription.email ?? '';
                            if (email.isNotEmpty) {
                              await Clipboard.setData(
                                ClipboardData(text: email),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email copied')),
                                );
                              }
                            }
                          } else if (action == 'copy') {
                            await AccountActions.copyAll(subscription);
                            if (context.mounted) AccountActions.copied(context);
                          } else if (action == 'code') {
                            await AccountActions.open(subscription.codeUrl);
                          } else if (action == 'open') {
                            await AccountActions.openService(subscription);
                          } else if (action == 'share') {
                            await Share.share(
                              '${subscription.name}\nEmail: ${subscription.email ?? '-'}\nUser: ${subscription.username ?? '-'}\nStart: ${DateFormat.yMMMd().format(subscription.startDate)}\nExpires: ${DateFormat.yMMMd().format(subscription.nextRenewalDate)}',
                            );
                          } else if (action == 'pause') {
                            await ref
                                .read(subscriptionsProvider.notifier)
                                .toggle(subscription);
                          } else if (action == 'paid') {
                            final method = await showDialog<String>(
                              context: context,
                              builder: (dialogContext) => SimpleDialog(
                                title: const Text('How was it paid?'),
                                children: ['Cash', 'Card', 'Transfer', 'Other']
                                    .map(
                                      (value) => SimpleDialogOption(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, value),
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                            if (method != null) {
                              await ref
                                  .read(subscriptionsProvider.notifier)
                                  .save(
                                    subscription.copyWith(
                                      isPaid: true,
                                      paymentMethod: method,
                                      paidAt: DateTime.now(),
                                    ),
                                  );
                            }
                          } else if (action == 'unpaid') {
                            await ref
                                .read(subscriptionsProvider.notifier)
                                .save(subscription.copyWith(isPaid: false));
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'email',
                            enabled: (subscription.email ?? '').isNotEmpty,
                            child: const Text('Copy email'),
                          ),
                          const PopupMenuItem(
                            value: 'copy',
                            child: Text('Copy account'),
                          ),
                          const PopupMenuItem(
                            value: 'open',
                            child: Text('Open app / website'),
                          ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Text('Share account info'),
                          ),
                          PopupMenuItem(
                            value: 'pause',
                            child: Text(
                              subscription.isActive
                                  ? 'Pause subscription'
                                  : 'Resume subscription',
                            ),
                          ),
                          PopupMenuItem(
                            value: subscription.isPaid ? 'unpaid' : 'paid',
                            child: Text(
                              subscription.isPaid
                                  ? 'Mark payment pending'
                                  : 'Mark as paid',
                            ),
                          ),
                          if ((subscription.codeUrl ?? '').isNotEmpty)
                            const PopupMenuItem(
                              value: 'code',
                              child: Text('Get sign-in code'),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  RenewalProgress(
                    subscription: subscription,
                    accent: category.color,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(
                        subscription.isPaid
                            ? Icons.check_circle
                            : Icons.schedule,
                        size: 16,
                        color: subscription.isPaid
                            ? const Color(0xFF12B886)
                            : const Color(0xFFFF9F1C),
                      ),
                      label: Text(
                        subscription.isPaid
                            ? 'Paid${subscription.paymentMethod == null ? '' : ' · ${subscription.paymentMethod}'}'
                            : 'Payment pending',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
