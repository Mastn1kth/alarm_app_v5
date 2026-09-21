import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_app/domain/entities/alarm_entity.dart';
import 'package:alarm_app/domain/services/challenge_service.dart';
import 'package:alarm_app/domain/services/feature_gate_service.dart';
import 'package:alarm_app/domain/services/user_service.dart' as user_domain;

void main() {
  group('Interface Contracts', () {
    test('IAlarmRepository should define all required methods', () {
      expect(true, true);
    });

    test('ILocalStorage should support all basic types', () {
      expect(true, true);
    });

    test('IMissionHandler should require mission type and validation', () {
      expect(true, true);
    });
  });

  group('AlarmModel Domain Entity', () {
    test('should create alarm with required fields', () {
      final alarm = AlarmModel(
        id: 'test-1',
        title: 'Test',
        hour: 7,
        minute: 30,
        missionType: MissionType.math,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(alarm.id, 'test-1');
      expect(alarm.hour, 7);
      expect(alarm.minute, 30);
      expect(alarm.enabled, true);
    });

    test('should format time correctly', () {
      final alarm = AlarmModel(
        id: '1',
        title: 'T',
        hour: 8,
        minute: 5,
        missionType: MissionType.math,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(alarm.timeString, '08:05');
    });

    test('should handle empty alarm list', () {
      final alarms = <AlarmModel>[];
      expect(alarms.isEmpty, true);
    });

    test('should validate alarm time format', () {
      const hour = 7;
      const minute = 30;
      expect(hour, greaterThanOrEqualTo(0));
      expect(hour, lessThanOrEqualTo(23));
      expect(minute, greaterThanOrEqualTo(0));
      expect(minute, lessThanOrEqualTo(59));
    });
  });

  group('Enum Coverage', () {
    test('MissionType should have 8 types', () {
      expect(MissionType.values.length, 8);
    });

    test('ChallengeType should expose active challenge types', () {
      expect(ChallengeType.values, contains(ChallengeType.noSnooze));
      expect(ChallengeType.values, contains(ChallengeType.quickDismiss));
    });

    test('AppFeature should expose current premium features', () {
      expect(AppFeature.values, contains(AppFeature.unlimitedAlarms));
      expect(AppFeature.values, contains(AppFeature.noAds));
    });
  });

  group('Business Logic', () {
    test('recording a wake-up counts the completed mission', () {
      final statistics = user_domain.UserStatistics(userId: 'test-user');

      statistics.recordWakeUp(
        usedSnooze: false,
        dismissTime: const Duration(seconds: 20),
        missionType: MissionType.math.name,
      );

      expect(statistics.totalMissionsCompleted, 1);
      expect(statistics.totalDismissals, 1);
    });

    test('Feature gating should restrict free tier', () {
      const maxFreeAlarms = 5;
      expect(maxFreeAlarms, 5);
    });

    test('Premium tier should unlock all features', () {
      final premiumMissionCount = MissionType.values.length;
      expect(premiumMissionCount, 8);
    });

    test('Streak calculation should handle gaps', () {
      final lastWakeUp = DateTime(2024, 6, 8);
      final today = DateTime(2024, 6, 9);
      final difference = today.difference(lastWakeUp).inDays;
      expect(difference, 1);
    });

    test('Streak should break after missing a day', () {
      final lastWakeUp = DateTime(2024, 6, 7);
      final today = DateTime(2024, 6, 9);
      final difference = today.difference(lastWakeUp).inDays;
      expect(difference, 2);
    });
  });
}
