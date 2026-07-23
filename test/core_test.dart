import 'package:flutter_test/flutter_test.dart';
import 'package:my_subscriptions/core/utils/currency_helper.dart';
import 'package:my_subscriptions/core/utils/date_helper.dart';
import 'package:my_subscriptions/data/models/subscription_model.dart';

void main() {
  group('DateHelper', () {
    test('keeps a valid day when adding a month', () {
      expect(
        DateHelper.addMonths(DateTime(2025, 1, 31), 1),
        DateTime(2025, 2, 28),
      );
      expect(
        DateHelper.addMonths(DateTime(2024, 1, 31), 1),
        DateTime(2024, 2, 29),
      );
    });

    test('finds the next renewal after today', () {
      final result = DateHelper.nextRenewal(
        DateTime(2025, 1, 15),
        'monthly',
        now: DateTime(2025, 3, 20),
      );
      expect(result, DateTime(2025, 4, 15));
    });
  });

  test('currency conversion can round-trip through USD', () {
    final eur = CurrencyHelper.convert(100, 'USD', 'EUR');
    expect(CurrencyHelper.convert(eur, 'EUR', 'USD'), closeTo(100, .001));
  });

  test('subscription JSON backup round-trip preserves fields', () {
    final item = SubscriptionModel(
      id: 'id-1',
      name: 'Example',
      category: 'dev_tools',
      price: 12.5,
      currency: 'USD',
      billingCycle: 'monthly',
      startDate: DateTime(2025, 1, 1),
      nextRenewalDate: DateTime(2025, 2, 1),
      colorHex: '#6C63FF',
    );
    final restored = SubscriptionModel.fromJson(item.toJson());
    expect(restored.name, item.name);
    expect(restored.price, item.price);
    expect(restored.nextRenewalDate, item.nextRenewalDate);
  });
}
