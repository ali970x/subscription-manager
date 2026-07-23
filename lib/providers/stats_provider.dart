import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/currency_helper.dart';
import '../data/models/subscription_model.dart';
import 'settings_provider.dart';
import 'subscription_provider.dart';

class SubscriptionStats {
  const SubscriptionStats({
    required this.monthly,
    required this.yearly,
    required this.activeCount,
    required this.byCategory,
    required this.mostExpensive,
  });
  final double monthly;
  final double yearly;
  final int activeCount;
  final Map<String, double> byCategory;
  final List<SubscriptionModel> mostExpensive;
}

final statsProvider = Provider<AsyncValue<SubscriptionStats>>((ref) {
  final currency = ref.watch(settingsProvider).baseCurrency;
  return ref.watch(subscriptionsProvider).whenData((items) {
    final active = items.where((e) => e.isActive).toList();
    double monthlyValue(SubscriptionModel item) {
      final normalized = switch (item.billingCycle) {
        'yearly' => item.price / 12,
        'weekly' => item.price * 52 / 12,
        _ => item.price,
      };
      return CurrencyHelper.convert(normalized, item.currency, currency);
    }

    final monthly = active.fold<double>(
      0,
      (sum, item) => sum + monthlyValue(item),
    );
    final currentYear = DateTime.now().year;
    final yearly = items
        .where(
          (item) =>
              item.isPaid &&
              (item.paidAt ?? item.startDate).year == currentYear,
        )
        .fold<double>(
          0,
          (sum, item) =>
              sum + CurrencyHelper.convert(item.price, item.currency, currency),
        );
    final categories = <String, double>{};
    for (final item in active) {
      categories[item.category] =
          (categories[item.category] ?? 0) + monthlyValue(item);
    }
    final sorted = [...active]
      ..sort((a, b) => monthlyValue(b).compareTo(monthlyValue(a)));
    return SubscriptionStats(
      monthly: monthly,
      yearly: yearly,
      activeCount: active.length,
      byCategory: categories,
      mostExpensive: sorted,
    );
  });
});
