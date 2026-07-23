import 'package:hive/hive.dart';
import '../models/subscription_model.dart';

class SubscriptionRepository {
  SubscriptionRepository(this.box);
  final Box<SubscriptionModel> box;

  List<SubscriptionModel> getAll() =>
      box.values.toList()
        ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));

  Future<void> save(SubscriptionModel subscription) async {
    final staleKeys = box
        .toMap()
        .entries
        .where(
          (entry) =>
              entry.value.id == subscription.id && entry.key != subscription.id,
        )
        .map((entry) => entry.key)
        .toList();
    if (staleKeys.isNotEmpty) await box.deleteAll(staleKeys);
    await box.put(subscription.id, subscription);
  }

  Future<void> delete(String id) async {
    final keys = box
        .toMap()
        .entries
        .where((entry) => entry.value.id == id)
        .map((entry) => entry.key)
        .toList();
    await box.deleteAll(keys);
  }

  Future<void> clear() => box.clear();

  Future<void> replaceAll(List<SubscriptionModel> subscriptions) async {
    await box.clear();
    await box.putAll({for (final item in subscriptions) item.id: item});
  }
}
