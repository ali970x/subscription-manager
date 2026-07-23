import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/notification_service.dart';
import '../data/models/subscription_model.dart';
import '../data/repositories/subscription_repository.dart';
import '../core/utils/firebase_sync_service.dart';
import 'firebase_sync_provider.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => throw UnimplementedError('Repository must be overridden'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

class SubscriptionNotifier
    extends StateNotifier<AsyncValue<List<SubscriptionModel>>> {
  SubscriptionNotifier(this._repository, this._notifications, this._cloud)
    : super(AsyncData(_repository.getAll()));

  final SubscriptionRepository _repository;
  final NotificationService _notifications;
  final FirebaseSyncService _cloud;

  void _reload() => state = AsyncData(_repository.getAll());

  Future<void> _backupQuietly() async {
    if (_cloud.currentUser == null) return;
    try {
      await _cloud.backup(_repository.getAll());
    } catch (_) {
      // Local operations remain available while the device is offline.
    }
  }

  Future<void> save(SubscriptionModel item) async {
    try {
      await _repository.save(item);
      try {
        await _notifications.scheduleRenewalNotification(item);
      } catch (_) {
        // Saving the subscription must still succeed when Android blocks or
        // cannot schedule a notification.
      }
      _reload();
      await _backupQuietly();
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      try {
        await _notifications.cancel(id);
      } catch (_) {
        // A notification platform failure must not hide local data.
      }
      _reload();
      await _backupQuietly();
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> toggle(SubscriptionModel item) =>
      save(item.copyWith(isActive: !item.isActive));

  Future<void> replaceAll(List<SubscriptionModel> items) async {
    try {
      try {
        await _notifications.cancelAll();
      } catch (_) {
        // Restoring data must not depend on notification permissions.
      }
      await _repository.replaceAll(items);
      for (final item in items) {
        try {
          await _notifications.scheduleRenewalNotification(item);
        } catch (_) {
          // Restoring data must succeed even if Android blocks notifications.
        }
      }
      _reload();
      await _backupQuietly();
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> clear() async {
    try {
      try {
        await _notifications.cancelAll();
      } catch (_) {
        // Clearing local data must not depend on notification permissions.
      }
      await _repository.clear();
      _reload();
      await _backupQuietly();
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }
}

final subscriptionsProvider =
    StateNotifierProvider<
      SubscriptionNotifier,
      AsyncValue<List<SubscriptionModel>>
    >((ref) {
      return SubscriptionNotifier(
        ref.watch(subscriptionRepositoryProvider),
        ref.watch(notificationServiceProvider),
        ref.watch(firebaseSyncServiceProvider),
      );
    });
