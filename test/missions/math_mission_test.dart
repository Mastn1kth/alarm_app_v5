import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_app/domain/entities/alarm_entity.dart';
import 'package:alarm_app/domain/services/math_problem_generator.dart';

void main() {
  group('MathProblemGenerator', () {
    test('should generate math task for beginner difficulty', () {
      final task = MathProblemGenerator.generate(MissionDifficulty.beginner);
      expect(task, isNotNull);
      expect(task.question, isNotEmpty);
      expect(task.difficulty, MissionDifficulty.beginner);
    });

    test('should generate math task for extreme difficulty', () {
      final task = MathProblemGenerator.generate(MissionDifficulty.extreme);
      expect(task, isNotNull);
      expect(task.difficulty, MissionDifficulty.extreme);
    });

    test('should generate correct problem count for each difficulty', () {
      expect(
          MathProblemGenerator.getProblemCount(MissionDifficulty.beginner), 2);
      expect(MathProblemGenerator.getProblemCount(MissionDifficulty.easy), 3);
      expect(MathProblemGenerator.getProblemCount(MissionDifficulty.medium), 4);
      expect(MathProblemGenerator.getProblemCount(MissionDifficulty.hard), 5);
      expect(
          MathProblemGenerator.getProblemCount(MissionDifficulty.extreme), 7);
    });

    test('should validate correct answers', () {
      final task = MathProblemGenerator.generate(MissionDifficulty.beginner);
      expect(task.validate(task.expectedAnswer), true);
    });

    test('should reject wrong answers', () {
      final task = MathProblemGenerator.generate(MissionDifficulty.beginner);
      expect(task.validate(task.expectedAnswer + 1), false);
      expect(task.validate(''), false);
    });

    test('should accept string-encoded correct answers', () {
      final task = MathProblemGenerator.generate(MissionDifficulty.beginner);
      expect(task.validate(task.expectedAnswer.toString()), true);
    });

    test('should generate different tasks on repeated calls', () {
      final questions = <String>{};
      for (int i = 0; i < 10; i++) {
        questions.add(
            MathProblemGenerator.generate(MissionDifficulty.medium).question);
      }
      // At least some should be different
      expect(questions.length, greaterThan(1));
    });

    test('should include all problem types at extreme difficulty', () {
      final types = <Type>{};
      for (int i = 0; i < 50; i++) {
        final task = MathProblemGenerator.generate(MissionDifficulty.extreme);
        types.add(task.runtimeType);
      }
      expect(types.length, greaterThanOrEqualTo(2));
    });
  });
}
