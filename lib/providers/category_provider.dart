import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/models/category_model.dart';
import 'settings_provider.dart';

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  CategoryNotifier(this._preferences)
    : super([...CategoryModel.builtIns, ..._readCustom(_preferences)]);

  static const _storageKey = 'custom_categories';
  final SharedPreferences _preferences;

  static List<CategoryModel> _readCustom(SharedPreferences preferences) {
    try {
      final raw = preferences.getString(_storageKey);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map(
            (item) =>
                CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<CategoryModel> add({
    required String name,
    required String emoji,
    required int colorValue,
    String? logoPath,
  }) async {
    final category = CategoryModel(
      'custom_${const Uuid().v4()}',
      name,
      name,
      emoji,
      Color(colorValue),
      logoPath: logoPath,
      isBuiltIn: false,
    );
    state = [...state, category];
    await _save();
    return category;
  }

  Future<void> delete(String id) async {
    state = state
        .where((category) => category.id != id || category.isBuiltIn)
        .toList();
    await _save();
  }

  Future<void> _save() => _preferences.setString(
    _storageKey,
    jsonEncode(
      state
          .where((category) => !category.isBuiltIn)
          .map((category) => category.toJson())
          .toList(),
    ),
  );
}

final categoriesProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>(
      (ref) => CategoryNotifier(ref.watch(sharedPreferencesProvider)),
    );

CategoryModel categoryById(List<CategoryModel> categories, String id) =>
    categories.firstWhere(
      (category) => category.id == id,
      orElse: () => CategoryModel.byId(id),
    );
