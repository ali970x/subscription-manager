import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/utils/notification_service.dart';
import 'data/models/subscription_model.dart';
import 'data/migrations/data_migrations.dart';
import 'data/repositories/subscription_repository.dart';
import 'providers/settings_provider.dart';
import 'providers/subscription_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SubscriptionModelAdapter());
  }
  final box = await Hive.openBox<SubscriptionModel>('subscriptions');
  final preferences = await SharedPreferences.getInstance();
  final subscriptionsMigrated = await migrateSubscriptionTaxonomyV2(
    box,
    preferences,
  );
  final categoriesMigrated = await migrateSubscriptionTaxonomyV3(
    box,
    preferences,
  );
  final aiToolsMigrated = await migrateSubscriptionTaxonomyV4(box, preferences);
  final idsMigrated = await migrateUniqueSubscriptionIdsV5(box, preferences);
  final now = DateTime.now();
  for (final item in box.values.toList()) {
    final due = item.autoPaidOn;
    if (!item.isPaid && due != null && !due.isAfter(now)) {
      await box.put(
        item.id,
        item.copyWith(isPaid: true, paymentMethod: 'Auto paid', paidAt: now),
      );
    }
  }
  NotificationService.instance.notificationHour =
      preferences.getInt('notificationHour') ?? 9;
  try {
    await NotificationService.instance.init();
    if (subscriptionsMigrated ||
        categoriesMigrated ||
        aiToolsMigrated ||
        idsMigrated) {
      for (final subscription in box.values) {
        await NotificationService.instance.scheduleRenewalNotification(
          subscription,
        );
      }
    }
  } catch (_) {
    // Notifications are optional on unsupported desktop/test environments.
  }
  runApp(
    ProviderScope(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(
          SubscriptionRepository(box),
        ),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const SubTrackApp(),
    ),
  );
}
