import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_app/domain/services/anti_cheat_service.dart';

void main() {
  group('AntiCheatService', () {
    late AntiCheatService service;

    setUp(() {
      service = AntiCheatService();
    });

    test('should start with default active rules', () {
      expect(service.isRuleActive(AntiCheatRule.preventInstantDismiss), true);
      expect(service.isRuleActive(AntiCheatRule.preventMissionSkip), true);
    });

    test('should allow enabling and disabling rules', () {
      service.disableRule(AntiCheatRule.preventInstantDismiss);
      expect(service.isRuleActive(AntiCheatRule.preventInstantDismiss), false);

      service.enableRule(AntiCheatRule.preventInstantDismiss);
      expect(service.isRuleActive(AntiCheatRule.preventInstantDismiss), true);
    });

    test('should block instant dismiss attempts', () {
      service.startAlarmSession('test-alarm');
      // Immediately try to dismiss
      final result = service.checkDismissAttempt();
      expect(result.isValid, false);
      expect(result.hasViolations, true);
    });

    test('should allow dismiss after minimum duration', () async {
      service.startAlarmSession('test-alarm');
      service.startMission('math');
      await Future.delayed(const Duration(seconds: 3));
      // Need 2 dismiss attempts for accidental dismiss prevention
      var result = service.checkDismissAttempt();
      expect(result.hasViolations,
          true); // First attempt always fails (needs double confirm)

      result = service.checkDismissAttempt();
      expect(result.isValid, true);
    });

    test('should block mission skip', () {
      service.startAlarmSession('test-alarm');
      // Trying to dismiss without starting mission
      final result = service.checkDismissAttempt();
      expect(result.hasViolations, true);
    });

    test('should detect rapid mission completion', () {
      service.startAlarmSession('test-alarm');
      service.startMission('math');
      final result = service.checkMissionCompletion('math',
          completionTime: const Duration(milliseconds: 100));
      expect(result.hasViolations, true);
    });

    test('should enforce mission timeout', () {
      service.startAlarmSession('test-alarm');
      service.startMission('math');
      // Mission timeout is 10 minutes, so normal completion should pass
      final result = service.checkMissionCompletion('math',
          completionTime: const Duration(seconds: 30));
      expect(result.isValid, true);
    });

    test('should block volume button exploit', () {
      service.startAlarmSession('test-alarm');
      final result = service.checkVolumeButton();
      expect(result.isValid, false);
    });

    test('should block back button', () {
      service.startAlarmSession('test-alarm');
      final allowed = service.onBackButtonPressed();
      expect(allowed, false);
    });

    test('should end session and reset state', () {
      service.startAlarmSession('test-alarm');
      service.startMission('math');
      service.endSession();

      // After session ends, checks should still work but have no ringing context
      final result = service.checkDismissAttempt();
      // With no ringing start time, instant dismiss check should be skipped
      expect(result.isValid, true);
    });

    test('should return statistics', () {
      service.startAlarmSession('test-alarm');
      service.startMission('math');
      service.checkDismissAttempt();

      final stats = service.getStatistics();
      expect(stats['totalDismissAttempts'], 1);
      expect(stats['missionAttempts'], containsPair('math', 1));
    });
  });
}
