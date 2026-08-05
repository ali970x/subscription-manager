import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/account_actions.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/category_provider.dart';
import 'renewal_progress.dart';
import 'subscription_quick_actions_sheet.dart';

class SubscriptionListTile extends ConsumerWidget {
  const SubscriptionListTile({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = categoryById(
      ref.watch(categoriesProvider),
      subscription.category,
    );
    return Opacity(
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
          onTap: () => showSubscriptionQuickActions(context, ref, subscription),
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
                                  style: Theme.of(context).textTheme.bodySmall,
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
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.outline,
                      ),
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
                      subscription.isPaid ? Icons.check_circle : Icons.schedule,
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
    );
  }
}
