import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../data/models/subscription_model.dart';
import 'currency_helper.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  int notificationHour = 9;

  Future<void> init() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  int _id(String id) => id.hashCode.abs() & 0x7fffffff;

  Future<void> scheduleRenewalNotification(SubscriptionModel sub) async {
    if (kIsWeb) return;
    await cancel(sub.id);
    if (!sub.notifyBeforeRenewal || !sub.isActive) return;
    final date = sub.nextRenewalDate.subtract(
      Duration(days: sub.notifyDaysBefore),
    );
    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      notificationHour,
    );
    if (!scheduled.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      _id(sub.id),
      'تجديد قريب! 🔔',
      'اشتراك ${sub.name} سيتجدد قريبًا بـ ${CurrencyHelper.format(sub.price, sub.currency)}',
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'renewals',
          'تجديدات الاشتراكات',
          channelDescription: 'تذكيرات محلية قبل موعد تجديد الاشتراك',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(String subscriptionId) =>
      kIsWeb ? Future.value() : _plugin.cancel(_id(subscriptionId));
  Future<void> cancelAll() => kIsWeb ? Future.value() : _plugin.cancelAll();
}
