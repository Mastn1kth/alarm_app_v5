import 'dart:math';
import 'package:flutter/material.dart';
import '../entities/alarm_entity.dart';

abstract class MathTask {
  final String id;
  final MissionDifficulty difficulty;

  MathTask({required this.id, required this.difficulty});

  String get question;
  int get expectedAnswer;
  String get hint;

  bool validate(dynamic userAnswer) {
    if (userAnswer is int) return userAnswer == expectedAnswer;
    if (userAnswer is String) {
      final parsed = int.tryParse(userAnswer);
      return parsed == expectedAnswer;
    }
    return false;
  }
}

/// Прямое вычисление: a ○ b = ?
class DirectMathTask extends MathTask {
  final int operandA;
  final int operandB;
  final String operator;

  DirectMathTask({
    required super.id,
    required super.difficulty,
    required this.operandA,
    required this.operandB,
    required this.operator,
  });

  @override
  String get question {
    final op = operator == '*'
        ? '×'
        : operator == '/'
            ? '÷'
            : operator;
    return '$operandA $op $operandB = ?';
  }

  @override
  int get expectedAnswer {
    switch (operator) {
      case '+':
        return operandA + operandB;
      case '-':
        return operandA - operandB;
      case '*':
        return operandA * operandB;
      case '/':
        return operandA ~/ operandB;
      default:
        return operandA + operandB;
    }
  }

  @override
  String get hint {
    final op = operator == '*'
        ? 'умножение'
        : operator == '/'
            ? 'деление'
            : operator == '+'
                ? 'сложение'
                : 'вычитание';
    return 'Выполните $op';
  }
}

/// Найди пропущенное число: a ○ ? = c
class MissingNumberTask extends MathTask {
  final int operandA;
  final int result;
  final String operator;

  MissingNumberTask({
    required super.id,
    required super.difficulty,
    required this.operandA,
    required this.result,
    required this.operator,
  });

  @override
  String get question {
    final op = operator == '*'
        ? '×'
        : operator == '/'
            ? '÷'
            : operator;
    return '$operandA $op ? = $result';
  }

  @override
  int get expectedAnswer {
    switch (operator) {
      case '+':
        return result - operandA;
      case '-':
        return operandA - result;
      case '*':
        return result ~/ operandA;
      case '/':
        return operandA ~/ result;
      default:
        return result - operandA;
    }
  }

  @override
  String get hint => 'Найдите пропущенное число';

  @override
  bool validate(dynamic userAnswer) {
    if (super.validate(userAnswer)) return true;
    if (userAnswer is String) {
      final parsed = int.tryParse(userAnswer);
      if (parsed == null) return false;
      return parsed == expectedAnswer;
    }
    return false;
  }
}

/// Цепочка: a ○ b ○ c = ?
class ChainMathTask extends MathTask {
  final int operandA;
  final int operandB;
  final int operandC;
  final String op1;
  final String op2;

  ChainMathTask({
    required super.id,
    required super.difficulty,
    required this.operandA,
    required this.operandB,
    required this.operandC,
    required this.op1,
    required this.op2,
  });

  @override
  String get question {
    final o1 = op1 == '*'
        ? '×'
        : op1 == '/'
            ? '÷'
            : op1;
    final o2 = op2 == '*'
        ? '×'
        : op2 == '/'
            ? '÷'
            : op2;
    return '$operandA $o1 $operandB $o2 $operandC = ?';
  }

  @override
  int get expectedAnswer {
    int step1;
    switch (op1) {
      case '+':
        step1 = operandA + operandB;
        break;
      case '-':
        step1 = operandA - operandB;
        break;
      case '*':
        step1 = operandA * operandB;
        break;
      case '/':
        step1 = operandA ~/ operandB;
        break;
      default:
        step1 = operandA + operandB;
    }
    switch (op2) {
      case '+':
        return step1 + operandC;
      case '-':
        return step1 - operandC;
      case '*':
        return step1 * operandC;
      case '/':
        return step1 ~/ operandC;
      default:
        return step1 + operandC;
    }
  }

  @override
  String get hint => 'Решите по действиям';
}

/// Сравнение: что больше? a ○ b или c ○ d
class ComparisonTask extends MathTask {
  final int leftA;
  final int leftB;
  final String leftOp;
  final int rightA;
  final int rightB;
  final String rightOp;

  ComparisonTask({
    required super.id,
    required super.difficulty,
    required this.leftA,
    required this.leftB,
    required this.leftOp,
    required this.rightA,
    required this.rightB,
    required this.rightOp,
  });

  int get _leftResult {
    switch (leftOp) {
      case '+':
        return leftA + leftB;
      case '-':
        return leftA - leftB;
      case '*':
        return leftA * leftB;
      case '/':
        return leftA ~/ leftB;
      default:
        return leftA + leftB;
    }
  }

  int get _rightResult {
    switch (rightOp) {
      case '+':
        return rightA + rightB;
      case '-':
        return rightA - rightB;
      case '*':
        return rightA * rightB;
      case '/':
        return rightA ~/ rightB;
      default:
        return rightA + rightB;
    }
  }

  @override
  String get question {
    final lo = leftOp == '*'
        ? '×'
        : leftOp == '/'
            ? '÷'
            : leftOp;
    final ro = rightOp == '*'
        ? '×'
        : rightOp == '/'
            ? '÷'
            : rightOp;
    return 'Что больше?\n$leftA $lo $leftB  vs  $rightA $ro $rightB';
  }

  @override
  int get expectedAnswer {
    final l = _leftResult;
    final r = _rightResult;
    if (l == r) return 0;
    return l > r ? 1 : 2;
  }

  @override
  String get hint => 'Сравните результаты';

  @override
  bool validate(dynamic userAnswer) {
    if (userAnswer is int) return userAnswer == expectedAnswer;
    if (userAnswer is String) {
      final trimmed = userAnswer.trim().toLowerCase();
      if (expectedAnswer == 0 && (trimmed == 'равны' || trimmed == 'одинаково'))
        return true;
      if (expectedAnswer == 1 &&
          (trimmed == 'левое' || trimmed == 'первое' || trimmed == 'left'))
        return true;
      if (expectedAnswer == 2 &&
          (trimmed == 'правое' || trimmed == 'второе' || trimmed == 'right'))
        return true;
    }
    return false;
  }
}

class MathProblemGenerator {
  static final Random _random = Random();

  static MathTask generate(MissionDifficulty difficulty) {
    final types = _getTypesForDifficulty(difficulty);
    final type = types[_random.nextInt(types.length)];

    switch (type) {
      case 'direct':
        return _generateDirect(difficulty);
      case 'missing':
        return _generateMissing(difficulty);
      case 'chain':
        return _generateChain(difficulty);
      case 'comparison':
        return _generateComparison(difficulty);
      default:
        return _generateDirect(difficulty);
    }
  }

  static List<String> _getTypesForDifficulty(MissionDifficulty d) {
    switch (d) {
      case MissionDifficulty.beginner:
        return ['direct'];
      case MissionDifficulty.easy:
        return ['direct', 'missing'];
      case MissionDifficulty.medium:
        return ['direct', 'missing', 'chain'];
      case MissionDifficulty.hard:
        return ['direct', 'missing', 'chain', 'comparison'];
      case MissionDifficulty.extreme:
        return ['direct', 'missing', 'chain', 'comparison'];
    }
  }

  static DirectMathTask _generateDirect(MissionDifficulty diff) {
    int a, b;
    String op;

    switch (diff) {
      case MissionDifficulty.beginner:
        op = ['+', '-'][_random.nextInt(2)];
        a = _random.nextInt(10) + 1;
        b = _random.nextInt(10) + 1;
        if (op == '-' && a < b) {
          final t = a;
          a = b;
          b = t;
        }
        break;
      case MissionDifficulty.easy:
        op = ['+', '-'][_random.nextInt(2)];
        a = _random.nextInt(30) + 1;
        b = _random.nextInt(30) + 1;
        if (op == '-' && a < b) {
          final t = a;
          a = b;
          b = t;
        }
        break;
      case MissionDifficulty.medium:
        op = ['+', '-', '*'][_random.nextInt(3)];
        if (op == '*') {
          a = _random.nextInt(12) + 2;
          b = _random.nextInt(12) + 2;
        } else {
          a = _random.nextInt(100) + 10;
          b = _random.nextInt(100) + 10;
          if (op == '-' && a < b) {
            final t = a;
            a = b;
            b = t;
          }
        }
        break;
      case MissionDifficulty.hard:
        op = ['+', '-', '*', '/'][_random.nextInt(4)];
        if (op == '/') {
          b = _random.nextInt(15) + 2;
          final r = _random.nextInt(20) + 2;
          a = b * r;
        } else if (op == '*') {
          a = _random.nextInt(25) + 5;
          b = _random.nextInt(20) + 5;
        } else {
          a = _random.nextInt(200) + 50;
          b = _random.nextInt(200) + 50;
          if (op == '-' && a < b) {
            final t = a;
            a = b;
            b = t;
          }
        }
        break;
      case MissionDifficulty.extreme:
        op = ['+', '-', '*', '/'][_random.nextInt(4)];
        if (op == '/') {
          b = _random.nextInt(50) + 3;
          final r = _random.nextInt(50) + 5;
          a = b * r;
        } else if (op == '*') {
          a = _random.nextInt(99) + 11;
          b = _random.nextInt(50) + 11;
        } else {
          a = _random.nextInt(999) + 100;
          b = _random.nextInt(999) + 100;
          if (op == '-' && a < b) {
            final t = a;
            a = b;
            b = t;
          }
        }
        break;
    }

    return DirectMathTask(
      id: 'math_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}',
      difficulty: diff,
      operandA: a,
      operandB: b,
      operator: op,
    );
  }

  static MissingNumberTask _generateMissing(MissionDifficulty diff) {
    int a, missing, result;
    String op;

    switch (diff) {
      case MissionDifficulty.beginner:
        op = '+';
        a = _random.nextInt(10) + 1;
        missing = _random.nextInt(10) + 1;
        result = a + missing;
        break;
      case MissionDifficulty.easy:
        op = ['+', '-'][_random.nextInt(2)];
        a = _random.nextInt(20) + 1;
        missing = _random.nextInt(20) + 1;
        result = op == '+' ? a + missing : a + missing;
        break;
      case MissionDifficulty.medium:
        op = ['+', '-', '*'][_random.nextInt(3)];
        if (op == '*') {
          a = _random.nextInt(10) + 2;
          missing = _random.nextInt(10) + 2;
          result = a * missing;
        } else {
          a = _random.nextInt(50) + 5;
          missing = _random.nextInt(50) + 5;
          result = op == '+' ? a + missing : a + missing;
        }
        break;
      case MissionDifficulty.hard:
        op = ['+', '-', '*', '/'][_random.nextInt(4)];
        if (op == '/') {
          a = _random.nextInt(15) + 5;
          result = _random.nextInt(20) + 2;
          missing = a * result;
        } else if (op == '*') {
          a = _random.nextInt(15) + 3;
          missing = _random.nextInt(15) + 3;
          result = a * missing;
        } else {
          a = _random.nextInt(100) + 10;
          missing = _random.nextInt(100) + 10;
          result = a + missing;
        }
        break;
      case MissionDifficulty.extreme:
        op = ['+', '-', '*', '/'][_random.nextInt(4)];
        if (op == '/') {
          a = _random.nextInt(30) + 10;
          result = _random.nextInt(30) + 3;
          missing = a * result;
        } else if (op == '*') {
          a = _random.nextInt(25) + 5;
          missing = _random.nextInt(25) + 5;
          result = a * missing;
        } else {
          a = _random.nextInt(500) + 50;
          missing = _random.nextInt(500) + 50;
          result = a + missing;
        }
        break;
    }

    return MissingNumberTask(
      id: 'math_miss_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}',
      difficulty: diff,
      operandA: a,
      result: result,
      operator: op,
    );
  }

  static ChainMathTask _generateChain(MissionDifficulty diff) {
    int a, b, c;
    String op1, op2;

    switch (diff) {
      case MissionDifficulty.medium:
        a = _random.nextInt(20) + 1;
        b = _random.nextInt(20) + 1;
        c = _random.nextInt(20) + 1;
        op1 = ['+', '-'][_random.nextInt(2)];
        op2 = ['+', '-'][_random.nextInt(2)];
        break;
      case MissionDifficulty.hard:
        a = _random.nextInt(30) + 5;
        b = _random.nextInt(30) + 2;
        c = _random.nextInt(30) + 2;
        op1 = ['+', '-', '*'][_random.nextInt(3)];
        op2 = ['+', '-'][_random.nextInt(2)];
        break;
      case MissionDifficulty.extreme:
        a = _random.nextInt(50) + 10;
        b = _random.nextInt(20) + 2;
        c = _random.nextInt(20) + 2;
        op1 = ['+', '-', '*', '/'][_random.nextInt(4)];
        op2 = ['+', '-', '*'][_random.nextInt(3)];
        if (op1 == '/' && a < b * 2) a = b * (_random.nextInt(10) + 2);
        break;
      default:
        return _generateChain(MissionDifficulty.medium);
    }

    return ChainMathTask(
      id: 'math_chain_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}',
      difficulty: diff,
      operandA: a,
      operandB: b,
      operandC: c,
      op1: op1,
      op2: op2,
    );
  }

  static ComparisonTask _generateComparison(MissionDifficulty diff) {
    String lo, ro;
    int la, lb, ra, rb;

    switch (diff) {
      case MissionDifficulty.hard:
        lo = ['+', '-', '*'][_random.nextInt(3)];
        ro = ['+', '-', '*'][_random.nextInt(3)];
        la = _random.nextInt(50) + 5;
        lb = _random.nextInt(50) + 5;
        ra = _random.nextInt(50) + 5;
        rb = _random.nextInt(50) + 5;
        break;
      case MissionDifficulty.extreme:
        lo = ['+', '-', '*', '/'][_random.nextInt(4)];
        ro = ['+', '-', '*', '/'][_random.nextInt(4)];
        la = _random.nextInt(100) + 10;
        lb = _random.nextInt(100) + 10;
        ra = _random.nextInt(100) + 10;
        rb = _random.nextInt(100) + 10;
        if (lo == '/') {
          lb = _random.nextInt(10) + 2;
          final r = _random.nextInt(15) + 2;
          la = lb * r;
        }
        if (ro == '/') {
          rb = _random.nextInt(10) + 2;
          final r = _random.nextInt(15) + 2;
          ra = rb * r;
        }
        break;
      default:
        return _generateComparison(MissionDifficulty.hard);
    }

    return ComparisonTask(
      id: 'math_cmp_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(99999)}',
      difficulty: diff,
      leftA: la,
      leftB: lb,
      leftOp: lo,
      rightA: ra,
      rightB: rb,
      rightOp: ro,
    );
  }

  static int getProblemCount(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.beginner:
        return 2;
      case MissionDifficulty.easy:
        return 3;
      case MissionDifficulty.medium:
        return 4;
      case MissionDifficulty.hard:
        return 5;
      case MissionDifficulty.extreme:
        return 7;
    }
  }
}
