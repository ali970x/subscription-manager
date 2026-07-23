import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/category_provider.dart';

class UpcomingRenewalCard extends ConsumerWidget {
  const UpcomingRenewalCard({super.key, required this.subscription});
  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = categoryById(
      ref.watch(categoriesProvider),
      subscription.category,
    );
    final days = subscription.nextRenewalDate.daysFromNow;
    final urgent = days <= 2;
    final label = days == 0
        ? context.l10n.text('today')
        : days == 1
        ? context.l10n.text('tomorrow')
        : '$days ${context.l10n.text('days')}';
    return Container(
      width: 224,
      margin: const EdgeInsetsDirectional.only(end: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color.withValues(alpha: .18),
            Theme.of(context).cardColor,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: (urgent ? const Color(0xFFE85757) : category.color).withValues(
            alpha: .28,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SubscriptionLogo(
                name: subscription.name,
                fallback: subscription.iconName ?? category.emoji,
                size: 43,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: urgent ? const Color(0xFFE85757) : category.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            subscription.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(subscription.nextRenewalDate)} • ${CurrencyHelper.format(subscription.price, subscription.currency)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
