import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/garden_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: FocusGardenApp()));
}

class FocusGardenApp extends ConsumerWidget {
  const FocusGardenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Focus Garden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with TickerProviderStateMixin {
  int _tabIndex = 0;
  late AnimationController _navAnimController;
  late Animation<double> _navAnim;

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _navAnim = CurvedAnimation(parent: _navAnimController, curve: Curves.easeOutCubic);
    _navAnimController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  void _checkOnboarding() {
    final user = ref.read(userProvider);
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  final _screens = const [
    HomeScreen(),
    GardenScreen(),
    ProfileScreen(),
  ];

  void _onTap(int i) {
    HapticFeedback.selectionClick();
    if (i == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }
    setState(() => _tabIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarContrastEnforced: false,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarContrastEnforced: false,
            ),
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: context.gradientBg,
          child: IndexedStack(
            index: _tabIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: FadeTransition(
          opacity: _navAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(_navAnim),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surface.withOpacity(0.92)
                    : AppColorsLight.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: isDark
                      ? AppColors.border.withOpacity(0.4)
                      : AppColorsLight.border,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.5 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: NavigationBar(
                  selectedIndex: _tabIndex,
                  onDestinationSelected: _onTap,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: AppColors.primary.withOpacity(isDark ? 0.12 : 0.1),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.eco_outlined),
                      selectedIcon: Icon(Icons.eco),
                      label: 'Garden',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
