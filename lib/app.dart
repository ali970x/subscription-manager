import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_themes.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/stats/screens/stats_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/firebase_sync_provider.dart';
import 'providers/subscription_provider.dart';

class SubTrackApp extends ConsumerWidget {
  const SubTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final firebaseUser = ref.watch(firebaseUserProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SubTrack',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: firebaseUser.when(
        loading: () => const _StartupScreen(),
        error: (_, _) => const LoginScreen(),
        data: (user) => user == null
            ? const LoginScreen()
            : const _CloudSyncBootstrap(child: AppShell()),
      ),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/branding/subtrack_icon.png',
              width: 88,
              height: 88,
            ),
          ),
          const SizedBox(height: 22),
          const CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class _CloudSyncBootstrap extends ConsumerStatefulWidget {
  const _CloudSyncBootstrap({required this.child});
  final Widget child;

  @override
  ConsumerState<_CloudSyncBootstrap> createState() =>
      _CloudSyncBootstrapState();
}

class _CloudSyncBootstrapState extends ConsumerState<_CloudSyncBootstrap> {
  bool syncing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  Future<void> _sync() async {
    try {
      final local = ref.read(subscriptionsProvider).valueOrNull ?? [];
      final resolved = await ref
          .read(firebaseSyncServiceProvider)
          .syncOnLogin(local);
      await ref.read(subscriptionsProvider.notifier).replaceAll(resolved);
    } catch (_) {
      // The local cache remains usable when the device is offline.
    } finally {
      if (mounted) setState(() => syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return syncing ? const _StartupScreen() : widget.child;
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [HomeScreen(), StatsScreen(), SettingsScreen()];
    final titles = [
      context.l10n.text('appName'),
      context.l10n.text('stats'),
      context.l10n.text('settings'),
    ];
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      appBar: index == 0
          ? null
          : AppBar(
              toolbarHeight: 76,
              titleSpacing: 18,
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'assets/branding/subtrack_icon.png',
                      width: 42,
                      height: 42,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[index],
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [Color(0xFF0D1020), Color(0xFF080A16)]
                : const [Color(0xFFF8F8FF), Color(0xFFF3F5FA)],
          ),
        ),
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          decoration: BoxDecoration(
            color: dark
                ? const Color(0xFF15182C).withValues(alpha: .96)
                : Colors.white.withValues(alpha: .97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: .35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? .28 : .08),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.space_dashboard_outlined),
                  selectedIcon: const Icon(Icons.space_dashboard_rounded),
                  label: context.l10n.text('home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.query_stats_rounded),
                  selectedIcon: const Icon(Icons.stacked_line_chart_rounded),
                  label: context.l10n.text('stats'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.tune_rounded),
                  selectedIcon: const Icon(Icons.tune_rounded),
                  label: context.l10n.text('settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
