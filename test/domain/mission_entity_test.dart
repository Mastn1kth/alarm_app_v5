import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_app/domain/entities/mission_entity.dart';
import 'package:alarm_app/domain/entities/alarm_entity.dart';

void main() {
  group('MissionFactory', () {
    test('should create all mission types', () {
      for (final type in MissionType.values) {
        final mission = MissionFactory.createMission(type);
        expect(mission, isNotNull);
        expect(mission.type, type);
      }
    });

    test('should create mission with specified difficulty', () {
      final mission = MissionFactory.createMission(MissionType.math,
          difficulty: MissionDifficulty.hard);
      expect(mission.difficulty, MissionDifficulty.hard);
    });
  });

  group('MathMission', () {
    test('should generate correct number of tasks', () {
      final mission = MathMission(difficulty: MissionDifficulty.medium);
      final tasks = mission.createTasks();
      expect(tasks.length, MissionDifficulty.medium.requiredCount);
    });

    test('should validate correct answer', () {
      final mission = MathMission(difficulty: MissionDifficulty.beginner);
      final tasks = mission.createTasks();
      for (final task in tasks) {
        if (task is MathTask) {
          expect(task.validate(task.expectedAnswer), true);
          expect(task.validate(-1), false);
        }
      }
    });
  });

  group('HoldButtonMission', () {
    test('should create single task', () {
      final mission = HoldButtonMission();
      final tasks = mission.createTasks();
      expect(tasks.length, 1);
      expect(tasks.first, isA<HoldButtonTask>());
    });

    test('hold duration should increase with difficulty', () {
      final easy = HoldButtonMission(difficulty: MissionDifficulty.easy);
      final hard = HoldButtonMission(difficulty: MissionDifficulty.hard);
      expect(hard.holdDurationSeconds, greaterThan(easy.holdDurationSeconds));
    });
  });

  group('MemoryMission', () {
    test('should generate tasks with correct sequence length', () {
      final mission = MemoryMission(difficulty: MissionDifficulty.medium);
      final tasks = mission.createTasks();
      expect(tasks.length, 1);
      final task = tasks.first as MemoryTask;
      expect(task.sequence.length, 5);
    });

    test('should validate correct sequence', () {
      final mission = MemoryMission(difficulty: MissionDifficulty.beginner);
      final tasks = mission.createTasks();
      final task = tasks.first as MemoryTask;
      expect(task.validate(task.sequence), true);
      expect(task.validate(<String>[]), false);
    });
  });

  group('TypingMission', () {
    test('should validate exact text match', () {
      final mission = TypingMission();
      final tasks = mission.createTasks();
      final task = tasks.first as TypingTask;
      expect(task.validate(task.text), true);
      expect(task.validate('wrong text'), false);
    });
  });

  group('SequenceMission', () {
    test('should generate sequence of correct length', () {
      final mission = SequenceMission(difficulty: MissionDifficulty.beginner);
      final tasks = mission.createTasks();
      final task = tasks.first as SequenceTask;
      expect(task.sequence.length, 3);
    });

    test('should validate correct order', () {
      final mission = SequenceMission(difficulty: MissionDifficulty.beginner);
      final tasks = mission.createTasks();
      final task = tasks.first as SequenceTask;
      expect(task.validate(task.sequence), true);
      expect(task.validate(<int>[999]), false);
    });
  });

  group('CaptchaMission', () {
    test('should generate grid with correct size', () {
      final mission = CaptchaMission(difficulty: MissionDifficulty.easy);
      final tasks = mission.createTasks();
      final task = tasks.first as CaptchaTask;
      expect(task.grid.length, 6);
    });

    test('should validate target emoji', () {
      final mission = CaptchaMission(difficulty: MissionDifficulty.easy);
      final tasks = mission.createTasks();
      final task = tasks.first as CaptchaTask;
      expect(task.validate(task.targetEmoji), true);
      expect(task.validate('wrong'), false);
    });
  });

  group('Mission recommendations', () {
    test('all missions should have recommendations', () {
      for (final type in MissionType.values) {
        final recommendations = type.recommendations;
        expect(recommendations, isNotEmpty);
      }
    });
  });
}
