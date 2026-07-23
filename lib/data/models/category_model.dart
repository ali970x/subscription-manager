import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel(
    this.id,
    this.arName,
    this.enName,
    this.emoji,
    this.color, {
    this.logoPath,
    this.isBuiltIn = true,
  });

  final String id;
  final String arName;
  final String enName;
  final String emoji;
  final Color color;
  final String? logoPath;
  final bool isBuiltIn;

  String name(bool isArabic) => isArabic ? arName : enName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': enName,
    'emoji': emoji,
    'color': color.toARGB32(),
    'logoPath': logoPath,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    json['id'] as String,
    json['name'] as String,
    json['name'] as String,
    json['emoji'] as String? ?? '📁',
    Color(json['color'] as int? ?? 0xFF6C63FF),
    logoPath: json['logoPath'] as String?,
    isBuiltIn: false,
  );

  static const builtIns = [
    CategoryModel(
      'ai_tools',
      'أدوات الذكاء الاصطناعي',
      'AI Tools',
      '✦',
      Color(0xFF10A37F),
    ),
    CategoryModel(
      'design_editing',
      'التصميم والمونتاج',
      'Design & Editing',
      '🎨',
      Color(0xFF6C63FF),
    ),
    CategoryModel(
      'entertainment',
      'ترفيه',
      'Entertainment',
      '🎬',
      Color(0xFFFF4D67),
    ),
    CategoryModel('others', 'أخرى', 'Others', '◈', Color(0xFF22A6B3)),
  ];

  static CategoryModel byId(String id) {
    final mapped = switch (id) {
      'dev_tools' => 'ai_tools',
      'internet' => 'entertainment',
      'productivity' || 'cloud' || 'security' || 'apps' => 'others',
      _ => id,
    };
    return builtIns.firstWhere(
      (item) => item.id == mapped,
      orElse: () => builtIns.last,
    );
  }
}
