import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppRadius.md,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: [
                isDark ? const Color(0xFF151528) : const Color(0xFFEEECE8),
                isDark ? const Color(0xFF1A1A30) : const Color(0xFFF5F3F0),
                isDark ? const Color(0xFF151528) : const Color(0xFFEEECE8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(context.isDark ? 0.25 : 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(height: 16, width: 120),
          const SizedBox(height: 12),
          ShimmerLoading(height: 14),
          const SizedBox(height: 8),
          ShimmerLoading(height: 14, width: 180),
        ],
      ),
    );
  }
}
