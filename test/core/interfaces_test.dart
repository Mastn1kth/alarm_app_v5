import 'package:alarm_app/domain/entities/alarm_entity.dart';
import 'package:alarm_app/domain/services/challenge_service.dart';
import 'package:alarm_app/domain/services/feature_gate_service.dart';
import 'package:alarm_app/domain/services/user_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Current domain contracts', () {
    test('alarm keeps mission, sound, and repeat configuration', () {
      final alarm = AlarmModel(
        id: 'alarm-1',
        title: 'Morning',
        hour: 7,
        minute: 30,
        repeatDaily: true,
        missionType: MissionType.steps,
        missionDifficulty: MissionDifficulty.hard,
        soundPack: SoundPack.classic,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(alarm.repeatDaily, isTrue);
      expect(alarm.missionType, MissionType.steps);
      expect(alarm.missionDifficulty, MissionDifficulty.hard);
      expect(alarm.soundPack, SoundPack.classic);
    });

    test('wake-up statistics count mission completion and snooze', () {
      final statistics = UserStatistics(userId: 'user-1');

      statistics.recordWakeUp(
        usedSnooze: true,
        dismissTime: const Duration(seconds: 45),
        missionType: MissionType.math.name,
      );

      expect(statistics.totalWakeUps, 1);
      expect(statistics.totalMissionsCompleted, 1);
      expect(statistics.totalDismissals, 1);
      expect(statistics.totalSnoozes, 1);
    });

    test('current challenge and feature enums expose supported values', () {
      expect(ChallengeType.values, contains(ChallengeType.noSnooze));
      expect(ChallengeType.values, contains(ChallengeType.missionVariety));
      expect(AppFeature.values, contains(AppFeature.unlimitedAlarms));
      expect(AppFeature.values, contains(AppFeature.noAds));
    });
  });
}
