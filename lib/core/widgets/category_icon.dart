import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import 'local_logo_image.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 42});
  final CategoryModel category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logoPath = category.logoPath;
    final logo = logoPath == null ? null : localLogoImage(logoPath, size);
    if (logo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * .3),
        child: logo,
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Text(category.emoji, style: TextStyle(fontSize: size * .48)),
    );
  }
}
