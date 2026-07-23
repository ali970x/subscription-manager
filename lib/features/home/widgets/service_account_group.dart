import 'package:flutter/material.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';
import 'subscription_list_tile.dart';

class ServiceAccountGroup extends StatelessWidget {
  const ServiceAccountGroup({super.key, required this.items});
  final List<SubscriptionModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.length == 1) {
      return SubscriptionListTile(subscription: items.first);
    }
    final now = DateTime.now();
    final urgent = items.any((item) {
      final days = item.nextRenewalDate.difference(now).inDays;
      return days >= 0 && days <= 7;
    });
    return Card(
      key: PageStorageKey(
        'service_${items.first.name.toLowerCase()}_${urgent ? 'urgent' : 'normal'}',
      ),
      margin: const EdgeInsets.only(bottom: 11),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        maintainState: true,
        leading: SubscriptionLogo(name: items.first.name, size: 44),
        title: Text(
          items.first.name.replaceAll(
            RegExp(r'\s+Account$', caseSensitive: false),
            '',
          ),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          items.length == 1
              ? (items.first.username ?? items.first.email ?? '1 account')
              : '${items.length} accounts',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
        children: [
          for (final item in items) SubscriptionListTile(subscription: item),
        ],
      ),
    );
  }
}
