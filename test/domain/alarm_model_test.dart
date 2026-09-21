import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_app/domain/entities/alarm_entity.dart';

void main() {
  group('AlarmModel', () {
    final baseAlarm = AlarmModel(
      id: 'test-1',
      title: 'Test Alarm',
      hour: 7,
      minute: 30,
      missionType: MissionType.math,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('should format time string correctly', () {
      expect(baseAlarm.timeString, '07:30');
    });

    test('should format single-use repeat text', () {
      expect(baseAlarm.repeatText, 'Один раз');
    });

    test('should format daily repeat text', () {
      final daily = baseAlarm.copyWith(repeatDaily: true);
      expect(daily.repeatText, 'Каждый день');
    });

    test('should format weekday repeat text', () {
      final weekdays = baseAlarm.copyWith(daysOfWeek: [
        DayOfWeek.monday,
        DayOfWeek.tuesday,
        DayOfWeek.wednesday,
        DayOfWeek.thursday,
        DayOfWeek.friday,
      ]);
      expect(weekdays.repeatText, 'По будням');
    });

    test('should calculate canSnooze correctly', () {
      final canSnooze = baseAlarm.copyWith(
          snoozeEnabled: true, snoozeCount: 0, maxSnoozeCount: 3);
      expect(canSnooze.canSnooze, true);

      final maxed = baseAlarm.copyWith(
          snoozeEnabled: true, snoozeCount: 3, maxSnoozeCount: 3);
      expect(maxed.canSnooze, false);

      final disabled = baseAlarm.copyWith(snoozeEnabled: false);
      expect(disabled.canSnooze, false);
    });

    test('should serialize to JSON and back', () {
      final json = baseAlarm.toJson();
      final restored = AlarmModel.fromJson(json);

      expect(restored.id, baseAlarm.id);
      expect(restored.title, baseAlarm.title);
      expect(restored.hour, baseAlarm.hour);
      expect(restored.minute, baseAlarm.minute);
      expect(restored.missionType, baseAlarm.missionType);
      expect(restored.missionDifficulty, baseAlarm.missionDifficulty);
    });

    test('copyWith should override specific fields', () {
      final modified = baseAlarm.copyWith(title: 'Modified', hour: 8);
      expect(modified.title, 'Modified');
      expect(modified.hour, 8);
      expect(modified.minute, baseAlarm.minute);
      expect(modified.missionType, baseAlarm.missionType);
    });
  });

  group('MissionType enum', () {
    test('should have 8 mission types', () {
      expect(MissionType.values.length, 8);
    });

    test('displayName should return Russian names', () {
      expect(MissionType.math.displayName, 'Математика');
      expect(MissionType.holdButton.displayName, 'Удерживать кнопку');
    });

    test('defaultDifficulty should return expected values', () {
      expect(MissionType.math.defaultDifficulty, MissionDifficulty.medium);
      expect(MissionType.holdButton.defaultDifficulty, MissionDifficulty.easy);
      expect(MissionType.steps.defaultDifficulty, MissionDifficulty.hard);
    });
  });

  group('MissionDifficulty enum', () {
    test('should have 5 difficulty levels', () {
      expect(MissionDifficulty.values.length, 5);
    });

    test('requiredCount should increase with difficulty', () {
      expect(MissionDifficulty.beginner.requiredCount,
          lessThan(MissionDifficulty.extreme.requiredCount));
    });

    test('color should be non-null for all levels', () {
      for (final diff in MissionDifficulty.values) {
        expect(diff.color, isNotNull);
      }
    });

    test('physical mission targets increase with difficulty', () {
      expect(
        MissionDifficulty.beginner.stepTarget,
        lessThan(MissionDifficulty.extreme.stepTarget),
      );
      expect(
        MissionDifficulty.beginner.shakeTarget,
        lessThan(MissionDifficulty.extreme.shakeTarget),
      );
      expect(
        MissionDifficulty.beginner.holdDurationSeconds,
        lessThan(MissionDifficulty.extreme.holdDurationSeconds),
      );
    });
  });

  group('DayOfWeek enum', () {
    test('should have 7 days', () {
      expect(DayOfWeek.values.length, 7);
    });

    test('shortName should return Russian abbreviations', () {
      expect(DayOfWeek.monday.shortName, 'Пн');
      expect(DayOfWeek.sunday.shortName, 'Вс');
    });
  });

  group('SoundPack enum', () {
    test('should have 6 sound packs', () {
      expect(SoundPack.values.length, 6);
    });

    test('assetPath should return valid paths', () {
      for (final pack in SoundPack.values) {
        expect(pack.assetPath, startsWith('sounds/'));
        expect(pack.assetPath, endsWith('.wav'));
      }
    });
  });
}
