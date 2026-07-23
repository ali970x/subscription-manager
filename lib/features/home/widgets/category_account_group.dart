import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/subscription_model.dart';
import 'service_account_group.dart';

class CategoryAccountGroup extends StatelessWidget {
  const CategoryAccountGroup({
    super.key,
    required this.category,
    required this.items,
  });

  final CategoryModel category;
  final List<SubscriptionModel> items;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final urgent = items.any((item) {
      final days = item.nextRenewalDate.difference(now).inDays;
      return days >= 0 && days <= 7;
    });
    final services = <String, List<SubscriptionModel>>{};
    for (final item in items) {
      final key = item.name
          .toLowerCase()
          .replaceAll(' account', '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      services.putIfAbsent(key, () => []).add(item);
    }
    final urgentCount = items.where((item) {
      final days = item.nextRenewalDate.difference(now).inDays;
      return days >= 0 && days <= 7;
    }).length;
    return Container(
      key: PageStorageKey(
        'category_${category.id}_${urgent ? 'urgent' : 'normal'}',
      ),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: category.color.withValues(alpha: urgent ? .34 : .18),
        ),
        boxShadow: [
          BoxShadow(
            color: category.color.withValues(alpha: .07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          maintainState: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          childrenPadding: EdgeInsets.zero,
          collapsedBackgroundColor: category.color.withValues(alpha: .025),
          backgroundColor: category.color.withValues(alpha: .035),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(17),
            ),
            alignment: Alignment.center,
            child: CategoryIcon(category: category, size: 31),
          ),
          title: Text(
            category.name(context.l10n.isArabic),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text('${items.length} accounts'),
                if (urgentCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5B66).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$urgentCount soon',
                      style: const TextStyle(
                        color: Color(0xFFE54854),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 5),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: .045),
                border: Border(
                  top: BorderSide(color: category.color.withValues(alpha: .15)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: services.length * 96.0,
                    constraints: const BoxConstraints(maxHeight: 320),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        for (final service in services.values)
                          ServiceAccountGroup(items: service),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
