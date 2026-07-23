import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/notification_service.dart';
import '../../../providers/firebase_sync_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../widgets/category_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final width = MediaQuery.sizeOf(context).width;
    final sidePadding = width > 900 ? (width - 900) / 2 : 16.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(sidePadding, 8, sidePadding, 110),
      children: [
        const _AccountSection(),
        const SizedBox(height: 18),
        _Section(
          title: context.l10n.text('categories'),
          icon: Icons.folder_copy_outlined,
          children: const [CategoryManager()],
        ),
        const SizedBox(height: 18),
        _Section(
          title: context.l10n.text('settings'),
          icon: Icons.tune_rounded,
          children: [
            ListTile(
              leading: const _SettingIcon(
                icon: Icons.currency_exchange_rounded,
                color: Color(0xFF5D55E8),
              ),
              title: const Text('Display currency'),
              subtitle: const Text('Currency used in totals and insights'),
              trailing: DropdownButton<String>(
                value: settings.baseCurrency,
                underline: const SizedBox.shrink(),
                items: CurrencyHelper.currencies
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) notifier.setCurrency(value);
                },
              ),
            ),
            const Divider(height: 1, indent: 72),
            ListTile(
              leading: const _SettingIcon(
                icon: Icons.notifications_active_outlined,
                color: Color(0xFFFF9F43),
              ),
              title: const Text('Daily reminder'),
              subtitle: Text(
                'Renewal alerts at '
                '${settings.notificationHour.toString().padLeft(2, '0')}:00',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.notificationHour,
                    minute: 0,
                  ),
                );
                if (time == null) return;
                await notifier.setNotificationHour(time.hour);
                NotificationService.instance.notificationHour = time.hour;
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        _Section(
          title: context.l10n.text('appearance'),
          icon: Icons.palette_outlined,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(context.l10n.text('light')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(context.l10n.text('dark')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_outlined),
                      label: Text(context.l10n.text('system')),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (value) => notifier.setTheme(value.first),
                  showSelectedIcon: false,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const _SettingIcon(
                icon: Icons.translate_rounded,
                color: Color(0xFF22A6B3),
              ),
              title: Text(context.l10n.text('language')),
              subtitle: Text(
                settings.locale.languageCode == 'ar' ? 'العربية' : 'English',
              ),
              trailing: DropdownButton<String>(
                value: settings.locale.languageCode,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(
                    value: 'ar',
                    child: Text(context.l10n.text('arabic')),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(context.l10n.text('english')),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) notifier.setLocale(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _Section(
          title: context.l10n.text('about'),
          icon: Icons.info_outline_rounded,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/branding/subtrack_icon.png',
                  width: 52,
                  height: 52,
                ),
              ),
              title: Text(
                context.l10n.text('appName'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text('Version 1.1.1 · Secure cloud sync'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountSection extends ConsumerStatefulWidget {
  const _AccountSection();

  @override
  ConsumerState<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<_AccountSection> {
  bool busy = false;

  Future<void> signOut() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final items = ref.read(subscriptionsProvider).valueOrNull ?? [];
      final subscriptions = ref.read(subscriptionsProvider.notifier);
      await ref.read(firebaseSyncServiceProvider).signOutWithBackup(items);
      await subscriptions.clear();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign out failed: $error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseUserProvider).valueOrNull;
    return _Section(
      title: 'Account',
      icon: Icons.person_outline_rounded,
      children: [
        if (user != null) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  backgroundImage: user.photoURL == null
                      ? null
                      : NetworkImage(user.photoURL!),
                  child: user.photoURL == null
                      ? Text(
                          (user.displayName ?? user.email ?? 'A')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Signed-in account',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.cloud_done_rounded, color: Color(0xFF12B886)),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: busy
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
            title: Text(
              'Sign out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: const Text('Your changes are synced automatically'),
            onTap: busy ? null : signOut,
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 5, bottom: 9),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .38),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? .16
                    : .045,
              ),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    ],
  );
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(icon, color: color),
  );
}
