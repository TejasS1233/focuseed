import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _complete() {
    final name = _controller.text.trim();
    final userId = name.isEmpty ? _generateId() : name;
    ref.read(userProvider.notifier).state = userId;
  }

  String _generateId() => 'user_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(UISpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 80, color: UIColors.primary),
              const SizedBox(height: UISpacing.lg),
              Text('Welcome to Focus Garden',
                style: UITypography.heading1),
              const SizedBox(height: UISpacing.sm),
              Text(
                'Grow your focus, one session at a time.',
                style: UITypography.body.copyWith(color: UIColors.gray500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UISpacing.xl),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Your name (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UIRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: UISpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _complete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.primary,
                    foregroundColor: UIColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Start Growing',
                    style: UITypography.body.copyWith(
                      fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
