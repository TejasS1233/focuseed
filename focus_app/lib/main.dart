import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/garden_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

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
      theme: isDark ? AppTheme.dark : AppTheme.light,
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  void _checkOnboarding() {
    final user = ref.read(userProvider);
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    }
  }

  final _screens = const [
    HomeScreen(),
    GardenScreen(),
    ProfileScreen(),
  ];

  void _onTap(int i) {
    if (i == 2) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ));
      return;
    }
    setState(() => _tabIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.park), label: 'Garden'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
