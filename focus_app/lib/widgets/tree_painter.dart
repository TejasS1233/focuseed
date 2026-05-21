import 'dart:math' as math;
import 'package:flutter/material.dart';

class LivingTree extends StatelessWidget {
  final String species;
  final int growthStage;
  final bool isAlive;
  final double size;
  final double entryProgress;
  final double deathProgress;

  const LivingTree({
    super.key,
    required this.species,
    required this.growthStage,
    this.isAlive = true,
    this.size = 120,
    this.entryProgress = 1.0,
    this.deathProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TreePainter(
          species: species,
          growthStage: growthStage,
          isAlive: isAlive,
          entryProgress: entryProgress,
          deathProgress: deathProgress,
        ),
      ),
    );
  }
}

class _SpeciesColors {
  static Color foliage(String species) {
    switch (species) {
      case 'oak': return const Color(0xFF00CC6A);
      case 'pine': return const Color(0xFF3B82F6);
      case 'cherry': return const Color(0xFFFFB7C5);
      default: return const Color(0xFF00FF88);
    }
  }

  static Color foliageDark(String species) {
    switch (species) {
      case 'oak': return const Color(0xFF009944);
      case 'pine': return const Color(0xFF2563EB);
      case 'cherry': return const Color(0xFFFF8FA3);
      default: return const Color(0xFF00CC6A);
    }
  }

  static Color trunk(String species) {
    switch (species) {
      case 'oak': return const Color(0xFF8B6914);
      case 'pine': return const Color(0xFF6B4226);
      case 'cherry': return const Color(0xFFA0522D);
      default: return const Color(0xFF8B6914);
    }
  }

  static Color deadFoliage = const Color(0xFF8B7355);
  static Color deadTrunk = const Color(0xFF5C4033);
}

class _TreePainter extends CustomPainter {
  final String species;
  final int growthStage;
  final bool isAlive;
  final double entryProgress;
  final double deathProgress;

  _TreePainter({
    required this.species,
    required this.growthStage,
    this.isAlive = true,
    this.entryProgress = 1.0,
    this.deathProgress = 0.0,
  });

  double get _growthFactor {
    switch (growthStage) {
      case 0: return 0.35;
      case 1: return 0.55;
      case 2: return 0.78;
      default: return 1.0;
    }
  }

  double get _effectiveH => _growthFactor * entryProgress;

  Color _foliage() {
    final f = _SpeciesColors.foliage(species);
    final d = _SpeciesColors.deadFoliage;
    if (!isAlive || deathProgress > 0) {
      return Color.lerp(f, d, deathProgress)!;
    }
    return f;
  }

  Color _foliageDark() {
    final f = _SpeciesColors.foliageDark(species);
    final d = _SpeciesColors.deadFoliage;
    if (!isAlive || deathProgress > 0) {
      return Color.lerp(f, d, deathProgress)!;
    }
    return f;
  }

  Color _trunk() {
    final f = _SpeciesColors.trunk(species);
    final d = _SpeciesColors.deadTrunk;
    if (!isAlive || deathProgress > 0) {
      return Color.lerp(f, d, deathProgress)!;
    }
    return f;
  }

  Color _glow() {
    final c = _foliage();
    return c.withOpacity(0.15 * (1 - deathProgress));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final h = _effectiveH;
    if (h <= 0) return;

    canvas.save();
    canvas.translate(size.width / 2, size.height);

    if (deathProgress > 0) {
      final tilt = deathProgress * 0.12;
      canvas.rotate(tilt);
    }

    final glowPaint = Paint()..color = _glow()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(0, -h * 0.4), h * 0.4, glowPaint);

    switch (species) {
      case 'oak': _drawOak(canvas, h);
      case 'pine': _drawPine(canvas, h);
      case 'cherry': _drawCherry(canvas, h);
      default: _drawSprout(canvas, h);
    }

    canvas.restore();
  }

  void _drawOak(Canvas canvas, double h) {
    final trunkPaint = Paint()..color = _trunk()..style = PaintingStyle.fill;
    final trunkH = h * 0.55;
    final trunkTop = -trunkH;

    final trunkPath = Path()
      ..moveTo(-8, 0)
      ..quadraticBezierTo(-5, trunkTop * 0.5, -3, trunkTop)
      ..quadraticBezierTo(0, trunkTop - 5, 3, trunkTop)
      ..quadraticBezierTo(5, trunkTop * 0.5, 8, 0)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final d = Paint()..style = PaintingStyle.fill;
    final foliage = _foliage();
    final dark = _foliageDark();

    final canopyCenter = Offset(0, trunkTop - h * 0.18);
    final r = h * 0.38;

    final offsets = [
      Offset(0, 0),
      Offset(-r * 0.6, r * 0.25),
      Offset(r * 0.6, r * 0.25),
      Offset(-r * 0.45, -r * 0.4),
      Offset(r * 0.45, -r * 0.4),
      Offset(0, -r * 0.45),
      Offset(-r * 0.3, r * 0.05),
      Offset(r * 0.3, r * 0.05),
    ];

    for (final o in offsets) {
      d.color = foliage;
      canvas.drawCircle(canopyCenter + o + const Offset(0, 2), r * 0.45, d);
    }
    for (final o in offsets) {
      d.color = dark;
      canvas.drawCircle(canopyCenter + o, r * 0.4, d);
    }
    for (final o in offsets) {
      d.color = foliage.withOpacity(0.3);
      canvas.drawCircle(canopyCenter + o + Offset(2, 0), r * 0.25, d);
    }

    final bark = Paint()
      ..color = _trunk().withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(-2, 0), Offset(-2, trunkTop * 0.55), bark);
    canvas.drawLine(Offset(2, 0), Offset(2, trunkTop * 0.55), bark);

    _drawGround(canvas, h);
  }

  void _drawPine(Canvas canvas, double h) {
    final trunkPaint = Paint()..color = _trunk()..style = PaintingStyle.fill;
    final trunkH = h * 0.45;

    final trunkPath = Path()
      ..moveTo(-5, 0)
      ..lineTo(-3, -trunkH)
      ..lineTo(3, -trunkH)
      ..lineTo(5, 0)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final d = Paint()..style = PaintingStyle.fill;
    final tiers = 4;
    final tierH = h * 0.35 / tiers;
    final baseY = -trunkH;

    for (int i = 0; i < tiers; i++) {
      final t = i / tiers;
      final y = baseY - (i * tierH * 1.15);
      final w = (h * 0.45) * (1 - t * 0.3);
      final branchH = tierH * 1.3 + (1 - t) * 4;

      final c = Color.lerp(_foliageDark(), _foliage(), t * 0.5)!;
      d.color = c;

      final path = Path()
        ..moveTo(0, y - branchH)
        ..lineTo(-w, y + branchH * 0.25)
        ..lineTo(-w * 0.6, y + branchH * 0.15)
        ..lineTo(0, y + branchH * 0.1)
        ..lineTo(w * 0.6, y + branchH * 0.15)
        ..lineTo(w, y + branchH * 0.25)
        ..close();
      canvas.drawPath(path, d);

      d.color = c.withOpacity(0.2);
      final glowPath = Path()
        ..moveTo(0, y - branchH - 2)
        ..lineTo(-w - 4, y + branchH * 0.3)
        ..lineTo(w + 4, y + branchH * 0.3)
        ..close();
      canvas.drawPath(glowPath, d);
    }

    _drawGround(canvas, h);
  }

  void _drawCherry(Canvas canvas, double h) {
    final trunkPaint = Paint()..color = _trunk()..style = PaintingStyle.fill;
    final trunkH = h * 0.6;

    final trunkPath = Path()
      ..moveTo(-6, 0)
      ..cubicTo(-4, -trunkH * 0.3, -5, -trunkH * 0.65, -3, -trunkH * 0.85)
      ..cubicTo(-1, -trunkH * 0.95, 1, -trunkH * 0.95, 3, -trunkH * 0.85)
      ..cubicTo(5, -trunkH * 0.65, 4, -trunkH * 0.3, 6, 0)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final topY = -trunkH * 0.9;
    final canopyW = h * 0.5;

    final canopyPaint = Paint()
      ..color = _foliage().withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final umbrella = Path()
      ..moveTo(0, topY - canopyW * 0.25)
      ..cubicTo(canopyW * 0.6, topY - canopyW * 0.1, canopyW * 1.15, topY + canopyW * 0.1, canopyW * 1.2, topY + canopyW * 0.35)
      ..cubicTo(canopyW * 0.6, topY + canopyW * 0.3, 0, topY + canopyW * 0.25, -canopyW * 0.6, topY + canopyW * 0.3)
      ..cubicTo(-canopyW * 1.15, topY + canopyW * 0.1, -canopyW * 0.6, topY - canopyW * 0.1, 0, topY - canopyW * 0.25)
      ..close();
    canvas.drawPath(umbrella, canopyPaint);

    final darkCanopy = Paint()
      ..color = _foliageDark().withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final darkUmbrella = Path()
      ..moveTo(0, topY - canopyW * 0.2)
      ..cubicTo(canopyW * 0.4, topY - canopyW * 0.05, canopyW * 0.8, topY + canopyW * 0.05, canopyW * 0.85, topY + canopyW * 0.2)
      ..cubicTo(canopyW * 0.4, topY + canopyW * 0.15, 0, topY + canopyW * 0.12, -canopyW * 0.4, topY + canopyW * 0.15)
      ..cubicTo(-canopyW * 0.8, topY + canopyW * 0.05, -canopyW * 0.4, topY - canopyW * 0.05, 0, topY - canopyW * 0.2)
      ..close();
    canvas.drawPath(darkUmbrella, darkCanopy);

    final blossomColor = isAlive
        ? const Color(0xFFFFB7C5)
        : Color.lerp(const Color(0xFFFFB7C5), _SpeciesColors.deadFoliage, deathProgress)!;
    final blossomPaint = Paint()..color = blossomColor..style = PaintingStyle.fill;
    final blossomDark = Paint()
      ..color = (isAlive ? const Color(0xFFFF8FA3) : Color.lerp(const Color(0xFFFF8FA3), _SpeciesColors.deadFoliage, deathProgress)!)
      ..style = PaintingStyle.fill;

    final rng = math.Random(42);
    for (int i = 0; i < 16; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final dist = rng.nextDouble() * canopyW * 0.75;
      final cx = math.cos(angle) * dist;
      final cy = topY - canopyW * 0.05 + math.sin(angle) * dist * 0.4;
      final r2 = 2.5 + rng.nextDouble() * 2.5;
      canvas.drawCircle(Offset(cx, cy), r2, blossomPaint);
      if (rng.nextBool()) {
        canvas.drawCircle(Offset(cx - 1, cy - 1), r2 * 0.6, blossomDark);
      }
    }

    final branchPaint = Paint()
      ..color = _trunk()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(3, -trunkH * 0.55), Offset(canopyW * 0.5, -trunkH * 0.7), branchPaint);
    canvas.drawLine(Offset(-3, -trunkH * 0.55), Offset(-canopyW * 0.5, -trunkH * 0.7), branchPaint);

    _drawGround(canvas, h);
  }

  void _drawSprout(Canvas canvas, double h) {
    final stemPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final stem = Path()
      ..moveTo(0, 0)
      ..cubicTo(1, -h * 0.3, 3, -h * 0.6, 0, -h * 0.8);
    canvas.drawPath(stem, stemPaint);

    final leafPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..style = PaintingStyle.fill;

    final left = Path()
      ..moveTo(0, -h * 0.7)
      ..cubicTo(-8, -h * 0.85, -14, -h * 0.72, -12, -h * 0.6)
      ..cubicTo(-8, -h * 0.55, -2, -h * 0.6, 0, -h * 0.7);
    canvas.drawPath(left, leafPaint);

    final right = Path()
      ..moveTo(0, -h * 0.8)
      ..cubicTo(8, -h * 0.9, 14, -h * 0.77, 12, -h * 0.65)
      ..cubicTo(8, -h * 0.6, 2, -h * 0.65, 0, -h * 0.8);
    canvas.drawPath(right, leafPaint);

    final glowPaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(0, -h * 0.7), h * 0.35, glowPaint);
  }

  void _drawGround(Canvas canvas, double h) {
    final ground = Paint()
      ..color = _trunk().withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final g = Path()
      ..moveTo(-14, 0)
      ..quadraticBezierTo(-8, 3, 0, 2)
      ..quadraticBezierTo(8, 3, 14, 0)
      ..cubicTo(10, 4, -10, 4, -14, 0)
      ..close();
    canvas.drawPath(g, ground);
  }

  @override
  bool shouldRepaint(_TreePainter old) =>
      old.species != species ||
      old.growthStage != growthStage ||
      old.isAlive != isAlive ||
      old.entryProgress != entryProgress ||
      old.deathProgress != deathProgress;
}
