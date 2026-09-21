import 'dart:math';
import 'package:flutter/material.dart';
import 'alarm_entity.dart';

/// ==================== MISSION INTERFACE ====================

/// Базовый интерфейс для всех миссий
abstract class Mission {
  final String id;
  final MissionType type;
  final MissionDifficulty difficulty;
  final String title;
  final String description;
  final int requiredSuccessCount;
  final Duration? timeLimit;

  Mission({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.title,
    required this.description,
    this.requiredSuccessCount = 1,
    this.timeLimit,
  });

  /// Создать задачу(и) для миссии
  List<MissionTask> createTasks();

  /// Валидировать ответ пользователя
  bool validate(dynamic userAnswer, MissionTask task);

  /// Получить подсказку для миссии
  String get hint;

  /// Проверить, доступна ли миссия на устройстве
  bool get isAvailable => true;

  /// Получить иконку миссии
  String get icon => type.icon;

  /// Получить рекомендации по использованию
  List<String> get recommendations;
}

/// ==================== MISSION TASK ====================

/// Абстрактная задача миссии
abstract class MissionTask {
  final String id;
  final MissionType type;
  final MissionDifficulty difficulty;
  final String question;
  final dynamic expectedAnswer;
  bool isCompleted;
  final DateTime? createdAt;
  DateTime? completedAt;

  MissionTask({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.expectedAnswer,
    this.isCompleted = false,
    this.createdAt,
    this.completedAt,
  });

  /// Проверить ответ пользователя
  bool validate(dynamic userAnswer);

  /// Время выполнения задачи
  Duration? get completionDuration {
    if (completedAt == null || createdAt == null) return null;
    return completedAt!.difference(createdAt!);
  }

  Map<String, dynamic> toJson();
}

/// ==================== CONCRETE MISSIONS ====================

/// Миссия: Математика
class MathMission extends Mission {
  MathMission({
    String? id,
    MissionDifficulty difficulty = MissionDifficulty.medium,
  }) : super(
          id: id ?? 'math_${DateTime.now().millisecondsSinceEpoch}',
          type: MissionType.math,
          difficulty: difficulty,
          title: 'Математика',
          description:
              'Решите математические примеры для отключения будильника',
          requiredSuccessCount: difficulty.requiredCount,
        );

  @override
  List<MissionTask> createTasks() {
    return List.generate(
      requiredSuccessCount,
      (_) => MathTask.generate(difficulty: difficulty),
    );
  }

  @override
  bool validate(dynamic userAnswer, MissionTask task) {
    if (task is MathTask) {
      return task.validate(userAnswer);
    }
    return false;
  }

  @override
  String get hint => 'Внимательно считайте, отрицательные числа тоже возможны';

  @override
  List<String> get recommendations => type.recommendations;
}

/// Миссия: Удерживать кнопку
class HoldButtonMission extends Mission {
  final int holdDurationSeconds;

  HoldButtonMission({
    String? id,
    MissionDifficulty difficulty = MissionDifficulty.easy,
  })  : holdDurationSeconds = _getDuration(difficulty),
        super(
          id: id ?? 'hold_${DateTime.now().millisecondsSinceEpoch}',
          type: MissionType.holdButton,
          difficulty: difficulty,
          title: 'Удерживать кнопку',
          description: 'Удерживайте кнопку ${_getDuration(difficulty)} секунд',
          requiredSuccessCount: 1,
        );

  static int _getDuration(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.beginner:
        return 3;
      case MissionDifficulty.easy:
        return 5;
      case MissionDifficulty.medium:
        return 10;
      case MissionDifficulty.hard:
        return 15;
      case MissionDifficulty.extreme:
        return 30;
    }
  }

  @override
  List<MissionTask> createTasks() {
    return [
      HoldButtonTask(
        id: 'hold_${DateTime.now().millisecondsSinceEpoch}',
        difficulty: difficulty,
        holdDurationSeconds: holdDurationSeconds,
      ),
    ];
  }

  @override
  bool validate(dynamic userAnswer, MissionTask task) {
    if (task is HoldButtonTask) {
      return task.validate(userAnswer);
    }
    return false;
  }

  @override
  String get hint => 'Не отпускайте кнопку до конца!';

  @override
  List<String> get recommendations => type.recommendations;
}

/// Миссия: Шаги (архитектура)
class StepsMission extends Mission {
  final int targetSteps;

  StepsMission({
    String? id,
    MissionDifficulty difficulty = MissionDifficulty.hard,
  })  : targetSteps = _getTargetSteps(difficulty),
        super(
          id: id ?? 'steps_${DateTime.now().millisecondsSinceEpoch}',
          type: MissionType.steps,
          difficulty: difficulty,
          title: 'Шаги',
          description: 'Сделайте ${_getTargetSteps(difficulty)} шагов',
          requiredSuccessCount: 1,
        );

  static int _getTargetSteps(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.beginner:
        return 5;
      case MissionDifficulty.easy:
        return 10;
      case MissionDifficulty.medium:
        return 20;
      case MissionDifficulty.hard:
        return 50;
      case MissionDifficulty.extreme:
        return 100;
    }
  }

  @override
  List<MissionTask> createTasks() {
    // TODO: Реализовать StepsTask с использованием sensors_plus
    return [
      StepsTask(
        id: 'steps_${DateTime.now().millisecondsSinceEpoch}',
        difficulty: difficulty,
        targetSteps: targetSteps,
      ),
    ];
  }

  @override
  bool validate(dynamic userAnswer, MissionTask task) {
    if (task is StepsTask) {
      return task.validate(userAnswer);
    }
    return false;
  }

  @override
  String get hint => 'Держите телефон в руке и ходите';

  @override
  List<String> get recommendations => type.recommendations;

  @override
  bool get isAvailable => true; // Работает с ручным подсчётом шагов
}

/// Миссия: Память (архитектура)
class MemoryMission extends Mission {
  final int sequenceLength;

  MemoryMission({
    String? id,
    MissionDifficulty difficulty = MissionDifficulty.medium,
  })  : sequenceLength = _getSequenceLength(difficulty),
        super(
          id: id ?? 'memory_${DateTime.now().millisecondsSinceEpoch}',
          type: MissionType.memory,
          difficulty: difficulty,
          title: 'Память',
          description:
              'Запомните последовательность из ${_getSequenceLength(difficulty)} элементов',
          requiredSuccessCount: 1,
        );

  static int _getSequenceLength(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.beginner:
        return 3;
      case MissionDifficulty.easy:
        return 4;
      case MissionDifficulty.medium:
        return 5;
      case MissionDifficulty.hard:
        return 7;
      case MissionDifficulty.extreme:
        return 10;
    }
  }

  @override
  List<MissionTask> createTasks() {
    final symbols = ['🔴', '🟢', '🔵', '🟡', '🟣', '🟠'];
    final random = Random();
    final seq = List.generate(
        sequenceLength, (_) => symbols[random.nextInt(symbols.length)]);
    return [
      MemoryTask(
        id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
        difficulty: difficulty,
        sequence: seq,
      ),
    ];
  }

  @override
  bool validate(dynamic userAnswer, MissionTask task) {
    if (task is MemoryTask) return task.validate(userAnswer);
    return false;
  }

  @override
  String get hint => 'Внимательно смотрите на последовательность';

  @override
  List<String> get recommendations => type.recommendations;
}

/// Миссия: Набор текста (архитектура)
class TypingMission extends Mission {
  TypingMission({
    String? id,
    MissionDifficulty difficulty = MissionDifficulty.easy,
  }) : super(
          id: id ?? 'typing_${DateTime.now().millisecondsSinceEpoch}',
          type: MissionType.typing,
          difficulty: difficulty,
          title: 'Набор текста',
          description: 'Наберите предложение без ошибок',
          requiredSuccessCount: 1,
        );

  static final List<String> _phrases = [
    'Будильник помогает проснуться',
    'Утро начинается с зарядки',
    'Солнце светит ярко и тепло',
    'Новый день приносит удачу',
    'Каждый день требует сил',
    'Пора вставать и действовать',
    'Свежий воздух бодрит',
    'Вода источник жизни',
  ];

  static List<String> getPhrasesForDifficulty(MissionDifficulty diff) {
    if (diff == MissionDifficulty.beginner || diff == MissionDifficulty.easy) {
      return _phrases.take(3).toList();
    } else if (diff == MissionDifficulty.medium) {
      return _phrases.take(5).toList();
    }
    return _phrases;
  }

  @override
  List<MissionTask> createTasks() {
    final phrases = getPhrasesForDifficulty(difficulty);
    final random = Random();
    final text = phrases[random.nextInt(phrases.length)];
    return [
      TypingTask(
        id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
        difficulty: difficulty,
        text: text,
      ),
    ];
  }

  @override
  bool validate(dynamic userAnswer, MissionTask task) {
    if (task is TypingTask) return task.validate(userAnswer);
    return false;
  }

  @override
  String get hint => 'Набирайте точно, без ошибок';

  @override
  List<String> get recommendations => type.recommendations;
}

/// Миссия: Встряхнуть телефон (архитектура)
class ShakePhoneMission extends Mission {
  final int shakeCount;

  ShakePhoneMission({
    String? id,
    MissionDifficulty difficulty = MissionDifficulty.hard,
  })  : shakeCount = _getShakeCount(difficulty),
        super(
          id: id ?? 'shake_${DateTime.now().millisecondsSinceEpoch}',
          type: MissionType.shakePhone,
          difficulty: difficulty,
          title: 'Встряхнуть телефон',
          description: 'Встряхните телефон ${_getShakeCount(difficulty)} раз',
          requiredSuccessCount: 1,
        );

  static int _getShakeCount(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.beginner:
        return 3;
      case MissionDifficulty.easy:
        return 5;
      case MissionDifficulty.medium:
        return 10;
      case MissionDifficulty.hard:
        return 20;
      case MissionDifficulty.extreme:
        return 50;
    }
  }

  @override
  List<MissionTask> createTasks() {
    return [
      ShakePhoneTask(
        id: 'shake_${DateTime.now().millisecondsSinceEpoch}',
        difficulty: difficulty,
        targetShakes: shakeCount,
      ),
    ];
  }

  @override
  bool validate(dynamic userAnswer, MissionTask task) {
    if (task is ShakePhoneTask) return task.validate(userAnswer);
    return false;
  }

  @override
  String get hint => 'Энергично встряхивайте телефон';

  @override
  List<String> get recommendations => type.recommendations;
}

/// Миссия: Последовательность (архитектура)
class SequenceMission extends Mission {
  final int sequenceLength;

  SequenceMission({
    String? id,
    MissionDifficulty difficulty = MissionDifficulty.medium,
  })  : sequenceLength = _getSequenceLength(difficulty),
        super(
          id: id ?? 'sequence_${DateTime.now().millisecondsSinceEpoch}',
          type: MissionType.sequence,
          difficulty: difficulty,
          title: 'Последовательность',
          description: 'Нажмите кнопки в правильном порядке',
          requiredSuccessCount: 1,
        );

  static int _getSequenceLength(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.beginner:
        return 3;
      case MissionDifficulty.easy:
        return 4;
      case MissionDifficulty.medium:
        return 5;
      case MissionDifficulty.hard:
        return 7;
      case MissionDifficulty.extreme:
        return 10;
    }
  }

  @override
  List<MissionTask> createTasks() {
    final random = Random();
    final seq = List.generate(sequenceLength, (_) => random.nextInt(9) + 1);
    return [
      SequenceTask(
        id: 'seq_${DateTime.now().millisecondsSinceEpoch}',
        difficulty: difficulty,
        sequence: seq,
      ),
    ];
  }

  @override
  bool validate(dynamic userAnswer, MissionTask task) {
    if (task is SequenceTask) return task.validate(userAnswer);
    return false;
  }

  @override
  String get hint => 'Запомните порядок и повторите';

  @override
  List<String> get recommendations => type.recommendations;
}

/// Миссия: CAPTCHA (архитектура)
class CaptchaMission extends Mission {
  CaptchaMission({
    String? id,
    MissionDifficulty difficulty = MissionDifficulty.easy,
  }) : super(
          id: id ?? 'captcha_${DateTime.now().millisecondsSinceEpoch}',
          type: MissionType.captcha,
          difficulty: difficulty,
          title: 'CAPTCHA',
          description: 'Решите визуальную задачу',
          requiredSuccessCount: 1,
        );

  @override
  List<MissionTask> createTasks() {
    final random = Random();
    final emojis = ['🍎', '🍊', '🍋', '🍇', '🍓', '🍑', '🍒', '🥝', '🍌', '🍉'];
    final target = emojis[random.nextInt(emojis.length)];
    final gridSize = difficulty == MissionDifficulty.beginner ||
            difficulty == MissionDifficulty.easy
        ? 6
        : 9;
    final grid =
        List.generate(gridSize, (_) => emojis[random.nextInt(emojis.length)]);
    return [
      CaptchaTask(
        id: 'captcha_${DateTime.now().millisecondsSinceEpoch}',
        difficulty: difficulty,
        targetEmoji: target,
        grid: grid,
      ),
    ];
  }

  @override
  bool validate(dynamic userAnswer, MissionTask task) {
    if (task is CaptchaTask) return task.validate(userAnswer);
    return false;
  }

  @override
  String get hint => 'Внимательно изучите изображение';

  @override
  List<String> get recommendations => type.recommendations;
}

/// ==================== MISSION FACTORY ====================

/// Фабрика для создания миссий
class MissionFactory {
  static Mission createMission(MissionType type,
      {MissionDifficulty? difficulty}) {
    final diff = difficulty ?? type.defaultDifficulty;

    switch (type) {
      case MissionType.math:
        return MathMission(difficulty: diff);
      case MissionType.holdButton:
        return HoldButtonMission(difficulty: diff);
      case MissionType.steps:
        return StepsMission(difficulty: diff);
      case MissionType.memory:
        return MemoryMission(difficulty: diff);
      case MissionType.typing:
        return TypingMission(difficulty: diff);
      case MissionType.shakePhone:
        return ShakePhoneMission(difficulty: diff);
      case MissionType.sequence:
        return SequenceMission(difficulty: diff);
      case MissionType.captcha:
        return CaptchaMission(difficulty: diff);
    }
  }

  static List<Mission> getAllMissions() {
    return MissionType.values.map((type) => createMission(type)).toList();
  }

  static List<Mission> getAvailableMissions() {
    return getAllMissions().where((m) => m.isAvailable).toList();
  }
}

/// ==================== CONCRETE TASKS ====================

/// Математическая задача
class MathTask extends MissionTask {
  final int operandA;
  final int operandB;
  final String operator;

  MathTask({
    required super.id,
    required super.difficulty,
    required this.operandA,
    required this.operandB,
    required this.operator,
  }) : super(
          type: MissionType.math,
          question: '$operandA $operator $operandB = ?',
          expectedAnswer: _calculateAnswer(operandA, operandB, operator),
          createdAt: DateTime.now(),
        );

  static int _calculateAnswer(int a, int b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return a ~/ b;
      default:
        return a + b;
    }
  }

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is int) {
      return userAnswer == expectedAnswer;
    }
    if (userAnswer is String) {
      return int.tryParse(userAnswer) == expectedAnswer;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'question': question,
      'expectedAnswer': expectedAnswer,
      'operandA': operandA,
      'operandB': operandB,
      'operator': operator,
      'isCompleted': isCompleted,
    };
  }

  factory MathTask.generate(
      {MissionDifficulty difficulty = MissionDifficulty.medium}) {
    final random = Random();
    final operators = ['+', '-', '*'];
    final operator = operators[random.nextInt(operators.length)];

    int a, b;
    switch (operator) {
      case '+':
        a = random.nextInt(50) + 10;
        b = random.nextInt(50) + 10;
        break;
      case '-':
        a = random.nextInt(50) + 20;
        b = random.nextInt(a - 1) + 1;
        break;
      case '*':
        a = random.nextInt(12) + 2;
        b = random.nextInt(12) + 2;
        break;
      default:
        a = random.nextInt(50) + 10;
        b = random.nextInt(50) + 10;
    }

    return MathTask(
      id: 'math_${DateTime.now().millisecondsSinceEpoch}',
      difficulty: difficulty,
      operandA: a,
      operandB: b,
      operator: operator,
    );
  }
}

/// Задача удерживания кнопки
class HoldButtonTask extends MissionTask {
  final int holdDurationSeconds;

  HoldButtonTask({
    required super.id,
    required super.difficulty,
    required this.holdDurationSeconds,
  }) : super(
          type: MissionType.holdButton,
          question: 'Удерживайте кнопку $holdDurationSeconds секунд',
          expectedAnswer: holdDurationSeconds,
          createdAt: DateTime.now(),
        );

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is int) {
      return userAnswer >= holdDurationSeconds;
    }
    if (userAnswer is double) {
      return userAnswer >= holdDurationSeconds;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'question': question,
      'holdDurationSeconds': holdDurationSeconds,
      'isCompleted': isCompleted,
    };
  }
}

/// Задача шагов (архитектура)
class StepsTask extends MissionTask {
  final int targetSteps;

  StepsTask({
    required super.id,
    required super.difficulty,
    required this.targetSteps,
  }) : super(
          type: MissionType.steps,
          question: 'Сделайте $targetSteps шагов',
          expectedAnswer: targetSteps,
          createdAt: DateTime.now(),
        );

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is int) {
      return userAnswer >= targetSteps;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'question': question,
      'targetSteps': targetSteps,
      'isCompleted': isCompleted,
    };
  }
}

/// Задача памяти
class MemoryTask extends MissionTask {
  final List<String> sequence;

  MemoryTask({
    required super.id,
    required super.difficulty,
    required this.sequence,
  }) : super(
          type: MissionType.memory,
          question: 'Повторите последовательность',
          expectedAnswer: sequence.join(','),
          createdAt: DateTime.now(),
        );

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is List<String>) {
      if (userAnswer.length != sequence.length) return false;
      for (int i = 0; i < sequence.length; i++) {
        if (userAnswer[i] != sequence[i]) return false;
      }
      return true;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'question': question,
      'sequence': sequence,
      'isCompleted': isCompleted,
    };
  }
}

/// Задача набора текста
class TypingTask extends MissionTask {
  final String text;

  TypingTask({
    required super.id,
    required super.difficulty,
    required this.text,
  }) : super(
          type: MissionType.typing,
          question: 'Наберите: $text',
          expectedAnswer: text,
          createdAt: DateTime.now(),
        );

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is String) {
      return userAnswer.trim() == text;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'question': question,
      'text': text,
      'isCompleted': isCompleted,
    };
  }
}

/// Задача встряхивания телефона
class ShakePhoneTask extends MissionTask {
  final int targetShakes;

  ShakePhoneTask({
    required super.id,
    required super.difficulty,
    required this.targetShakes,
  }) : super(
          type: MissionType.shakePhone,
          question: 'Встряхните телефон $targetShakes раз',
          expectedAnswer: targetShakes,
          createdAt: DateTime.now(),
        );

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is int) {
      return userAnswer >= targetShakes;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'question': question,
      'targetShakes': targetShakes,
      'isCompleted': isCompleted,
    };
  }
}

/// Задача последовательности
class SequenceTask extends MissionTask {
  final List<int> sequence;

  SequenceTask({
    required super.id,
    required super.difficulty,
    required this.sequence,
  }) : super(
          type: MissionType.sequence,
          question: 'Повторите последовательность из ${sequence.length} чисел',
          expectedAnswer: sequence.join(','),
          createdAt: DateTime.now(),
        );

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is List<int>) {
      if (userAnswer.length != sequence.length) return false;
      for (int i = 0; i < sequence.length; i++) {
        if (userAnswer[i] != sequence[i]) return false;
      }
      return true;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'question': question,
      'sequence': sequence,
      'isCompleted': isCompleted,
    };
  }
}

/// Задача CAPTCHA
class CaptchaTask extends MissionTask {
  final String targetEmoji;
  final List<String> grid;

  CaptchaTask({
    required super.id,
    required super.difficulty,
    required this.targetEmoji,
    required this.grid,
  }) : super(
          type: MissionType.captcha,
          question: 'Найдите $targetEmoji среди символов',
          expectedAnswer: targetEmoji,
          createdAt: DateTime.now(),
        );

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is String) {
      return userAnswer == targetEmoji;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'question': question,
      'targetEmoji': targetEmoji,
      'grid': grid,
      'isCompleted': isCompleted,
    };
  }
}
