import 'package:alarm_app/domain/entities/alarm_entity.dart';
import 'package:alarm_app/domain/services/math_problem_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Math mission difficulty', () {
    test('problem count increases with difficulty', () {
      expect(
        MathProblemGenerator.getProblemCount(MissionDifficulty.beginner),
        lessThan(
          MathProblemGenerator.getProblemCount(MissionDifficulty.extreme),
        ),
      );
    });

    test('generated tasks validate their expected answer', () {
      for (final difficulty in MissionDifficulty.values) {
        final task = MathProblemGenerator.generate(difficulty);
        expect(task.validate(task.expectedAnswer), isTrue);
      }
    });

    test('generated tasks reject a different answer', () {
      final task = MathProblemGenerator.generate(MissionDifficulty.medium);
      expect(task.validate(task.expectedAnswer + 1), isFalse);
    });
  });
}
