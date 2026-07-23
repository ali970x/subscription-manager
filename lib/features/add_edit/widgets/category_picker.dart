import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../providers/category_provider.dart';

class CategoryPicker extends ConsumerWidget {
  const CategoryPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.text('category'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final selected = value == category.id;
            return ChoiceChip(
              selected: selected,
              onSelected: (_) => onChanged(category.id),
              avatar: CategoryIcon(category: category, size: 26),
              label: Text(category.name(context.l10n.isArabic)),
              selectedColor: category.color.withValues(alpha: .22),
              side: BorderSide(
                color: selected ? category.color : Colors.transparent,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
