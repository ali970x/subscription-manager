# SubTrack

تطبيق Flutter محلي لإدارة الاشتراكات الشهرية والسنوية والأسبوعية. يدعم العربية والإنجليزية، RTL، الوضع الفاتح والداكن، الإشعارات المحلية، الإحصاءات، وتصدير/استيراد نسخة JSON.

## التشغيل

```bash
flutter pub get
flutter run
```

## التحقق والبناء

```bash
dart analyze
flutter test
flutter build apk --debug
```

ملف APK التجريبي الناتج يوجد في:

`build/app/outputs/flutter-apk/app-debug.apk`

## بنية البيانات

- التخزين المحلي: Hive
- الإعدادات: SharedPreferences
- الحالة: Riverpod
- الرسوم: fl_chart
- الإشعارات: flutter_local_notifications + timezone
- النسخ الاحتياطي: JSON عبر منتقي الملفات وقائمة المشاركة في النظام

أسعار التحويل المضمنة مرجعية وثابتة لأن التطبيق يعمل دون إنترنت؛ تظهر أسعار الاشتراكات بعملتها الأصلية وتُحوّل الإجماليات تقريبياً إلى عملة العرض المختارة.
