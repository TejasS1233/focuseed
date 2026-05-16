import 'package:flutter_test/flutter_test.dart';
import 'package:focus_app/core/services/session_service.dart';

void main() {
  group('SessionService', () {
    late SessionService service;

    setUp(() {
      service = SessionService();
    });

    test('calculateGrowthStages returns correct stage by duration', () {
      expect(service.calculateGrowthStage(0), 0);
      expect(service.calculateGrowthStage(900), 1);
      expect(service.calculateGrowthStage(1800), 2);
      expect(service.calculateGrowthStage(3600), 3);
      expect(service.calculateGrowthStage(7200), 4);
      expect(service.calculateGrowthStage(14400), 5);
    });

    test('hardlock completion applies 1.5x bonus', () {
      final stage = service.calculateGrowthStage(2400, mode: 'hard');
      expect(stage, 3);
    });

    test('soft focus early exit under 50% stunts tree', () {
      final result = service.evaluateSoftFocusOutcome(
        setDuration: 3600,
        actualDuration: 1500,
      );
      expect(result, SoftFocusOutcome.stunted);
    });

    test('soft focus early exit 50-99% gives reduced growth', () {
      final result = service.evaluateSoftFocusOutcome(
        setDuration: 3600,
        actualDuration: 2500,
      );
      expect(result, SoftFocusOutcome.reducedGrowth);
    });

    test('soft focus full completion gives full growth', () {
      final result = service.evaluateSoftFocusOutcome(
        setDuration: 3600,
        actualDuration: 3600,
      );
      expect(result, SoftFocusOutcome.fullGrowth);
    });
  });
}
