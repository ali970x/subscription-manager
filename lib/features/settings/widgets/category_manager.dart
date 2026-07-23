import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/category_logo_storage.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../add_edit/screens/add_edit_screen.dart';

class CategoryManager extends ConsumerWidget {
  const CategoryManager({super.key});

  Future<void> _addCategory(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    const emojis = ['📁', '💼', '🧠', '🎓', '💻', '🏠', '🎮', '📱', '☁️', '⭐'];
    const colors = [
      0xFF6C63FF,
      0xFF00BFA6,
      0xFF4D96FF,
      0xFFFF6584,
      0xFFFFB74D,
      0xFF22A6B3,
    ];
    var emoji = emojis.first;
    var colorValue = colors.first;
    PlatformFile? pickedFile;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.text('addCategory')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.text('categoryName'),
                    prefixIcon: const Icon(Icons.folder_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.l10n.text('chooseIcon'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: emojis
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item),
                          selected: emoji == item,
                          onSelected: (_) => setDialogState(() => emoji = item),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: colors
                      .map(
                        (item) => InkWell(
                          onTap: () => setDialogState(() => colorValue = item),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(item),
                              shape: BoxShape.circle,
                              border: colorValue == item
                                  ? Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: colorValue == item
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      withData: true,
                    );
                    if (result == null) return;
                    final file = result.files.single;
                    setDialogState(() {
                      pickedFile = file;
                    });
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    pickedFile != null
                        ? context.l10n.text('logoSelected')
                        : context.l10n.text('chooseLogo'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.text('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                String? logoPath;
                if (pickedFile != null) {
                  logoPath = await persistCategoryLogo(pickedFile!);
                }
                await ref
                    .read(categoriesProvider.notifier)
                    .add(
                      name: name,
                      emoji: emoji,
                      colorValue: colorValue,
                      logoPath: logoPath,
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(context.l10n.text('save')),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.text('deleteCategory')),
        content: Text(context.l10n.text('deleteCategoryConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.text('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.text('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final subscriptions = ref.read(subscriptionsProvider).valueOrNull ?? [];
    for (final item in subscriptions.where(
      (item) => item.category == category.id,
    )) {
      await ref
          .read(subscriptionsProvider.notifier)
          .save(item.copyWith(category: 'others'));
    }
    await ref.read(categoriesProvider.notifier).delete(category.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final subscriptions = ref.watch(subscriptionsProvider).valueOrNull ?? [];
    return Column(
      children: [
        for (var index = 0; index < categories.length; index++) ...[
          ListTile(
            leading: CategoryIcon(category: categories[index], size: 44),
            title: Text(
              categories[index].name(context.l10n.isArabic),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${subscriptions.where((item) => item.category == categories[index].id).length} ${context.l10n.text('items')}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: context.l10n.text('addItem'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditScreen(initialCategory: categories[index].id),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
                if (!categories[index].isBuiltIn)
                  IconButton(
                    tooltip: context.l10n.text('delete'),
                    onPressed: () =>
                        _deleteCategory(context, ref, categories[index]),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          if (index != categories.length - 1) const Divider(height: 1),
        ],
        Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _addCategory(context, ref),
              icon: const Icon(Icons.create_new_folder_outlined),
              label: Text(context.l10n.text('addCategory')),
            ),
          ),
        ),
      ],
    );
  }
}
