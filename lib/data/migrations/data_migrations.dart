import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription_model.dart';

Future<bool> migrateSubscriptionTaxonomyV2(
  Box<SubscriptionModel> box,
  SharedPreferences preferences,
) async {
  const migrationKey = 'subscription_taxonomy_v2';
  if (preferences.getBool(migrationKey) ?? false) return false;

  for (final item in box.values.toList()) {
    final name = item.name.toLowerCase();
    final category = switch (name) {
      final value
          when value.contains('chatgpt') ||
              value.contains('gemini') ||
              value.contains('canva') ||
              value.contains('capcut') =>
        'ai_tools',
      final value
          when value.contains('netflix') ||
              value.contains('shahid') ||
              value.contains('youtube') =>
        'internet',
      _ => 'productivity',
    };

    final isChatGpt = name.contains('chatgpt');
    final updatedNotes = isChatGpt
        ? (item.notes ?? '').replaceAll(
            RegExp(r'Expired:.*'),
            'Active · Valid until August 22, 2026',
          )
        : item.notes;
    final updated = item.copyWith(
      category: category,
      isActive: true,
      startDate: isChatGpt ? DateTime(2026, 7, 22) : item.startDate,
      nextRenewalDate: isChatGpt ? DateTime(2026, 8, 22) : item.nextRenewalDate,
      notes: updatedNotes,
      notifyBeforeRenewal: isChatGpt ? true : item.notifyBeforeRenewal,
      notifyDaysBefore: isChatGpt ? 3 : item.notifyDaysBefore,
    );
    await box.put(updated.id, updated);
  }

  await preferences.setBool(migrationKey, true);
  return true;
}

Future<bool> migrateSubscriptionTaxonomyV3(
  Box<SubscriptionModel> box,
  SharedPreferences preferences,
) async {
  const migrationKey = 'subscription_taxonomy_v3';
  if (preferences.getBool(migrationKey) ?? false) return false;

  for (final item in box.values.toList()) {
    final name = item.name.toLowerCase();
    final category = switch (name) {
      final value when value.contains('canva') || value.contains('capcut') =>
        'design_editing',
      final value when value.contains('netflix') || value.contains('shahid') =>
        'entertainment',
      _ => 'others',
    };
    await box.put(item.id, item.copyWith(category: category, isActive: true));
  }

  await preferences.setBool(migrationKey, true);
  return true;
}

Future<bool> migrateSubscriptionTaxonomyV4(
  Box<SubscriptionModel> box,
  SharedPreferences preferences,
) async {
  const migrationKey = 'subscription_taxonomy_v4';
  if (preferences.getBool(migrationKey) ?? false) return false;

  const aiServiceNames = [
    'chatgpt',
    'gemini',
    'claude',
    'openai',
    'copilot',
    'perplexity',
    'deepseek',
    'midjourney',
  ];
  for (final item in box.values.toList()) {
    final name = item.name.toLowerCase();
    if (aiServiceNames.any(name.contains)) {
      await box.put(item.id, item.copyWith(category: 'ai_tools'));
    }
  }

  await preferences.setBool(migrationKey, true);
  return true;
}

/// Repairs older seeded accounts that shared an id. Duplicate ids made two
/// cards behave as one and caused duplicate widget-key errors while editing.
Future<bool> migrateUniqueSubscriptionIdsV5(
  Box<SubscriptionModel> box,
  SharedPreferences preferences,
) async {
  const migrationKey = 'unique_subscription_ids_v5';
  if (preferences.getBool(migrationKey) ?? false) return false;

  const uuid = Uuid();
  final usedIds = <String>{};
  final repaired = <SubscriptionModel>[];
  for (final item in box.values.toList()) {
    var uniqueId = item.id.trim();
    if (uniqueId.isEmpty || usedIds.contains(uniqueId)) {
      uniqueId = uuid.v4();
    }
    usedIds.add(uniqueId);
    repaired.add(item.id == uniqueId ? item : item.copyWith(id: uniqueId));
  }

  await box.clear();
  await box.putAll({for (final item in repaired) item.id: item});
  await preferences.setBool(migrationKey, true);
  return true;
}
