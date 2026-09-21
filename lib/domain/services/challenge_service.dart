import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/alarm_entity.dart';
import '../entities/mission_entity.dart';

/// ==================== DAILY CHALLENGE ====================

/// Тип ежедневного челленджа
enum ChallengeType {
  noSnooze, // Проснуться без откладывания
  consecutiveMissions, // Выполнить N миссий подряд
  streakDays, // N дней подряд вставать вовремя
  earlyBird, // Встать до определённого времени
  missionVariety, // Использовать разные типы миссий
  perfectWeek, // Идеальная неделя (без пропусков)
  quickDismiss, // Отключить будильник быстрее N секунд
  weekendWarrior, // Встать вовремя в выходные
}

extension ChallengeTypeExtension on ChallengeType {
  String get displayName {
    switch (this) {
      case ChallengeType.noSnooze:
        return 'Без откладывания';
      case ChallengeType.consecutiveMissions:
        return 'Миссии подряд';
      case ChallengeType.streakDays:
        return 'Серия дней';
      case ChallengeType.earlyBird:
        return 'Ранняя пташка';
      case ChallengeType.missionVariety:
        return 'Разнообразие миссий';
      case ChallengeType.perfectWeek:
        return 'Идеальная неделя';
      case ChallengeType.quickDismiss:
        return 'Быстрый подъём';
      case ChallengeType.weekendWarrior:
        return 'Выходной воин';
    }
  }

  String get description {
    switch (this) {
      case ChallengeType.noSnooze:
        return 'Проснитесь без нажатия кнопки "Отложить"';
      case ChallengeType.consecutiveMissions:
        return 'Выполните несколько миссий подряд без ошибок';
      case ChallengeType.streakDays:
        return 'Вставайте вовремя несколько дней подряд';
      case ChallengeType.earlyBird:
        return 'Встаньте до 6:00 утра';
      case ChallengeType.missionVariety:
        return 'Используйте разные типы миссий за день';
      case ChallengeType.perfectWeek:
        return 'Не пропустите ни одного будильника за неделю';
      case ChallengeType.quickDismiss:
        return 'Отключите будильник менее чем за 30 секунд';
      case ChallengeType.weekendWarrior:
        return 'Встаньте вовремя в субботу и воскресенье';
    }
  }

  String get icon {
    switch (this) {
      case ChallengeType.noSnooze:
        return '⏰';
      case ChallengeType.consecutiveMissions:
        return '🎯';
      case ChallengeType.streakDays:
        return '🔥';
      case ChallengeType.earlyBird:
        return '🐦';
      case ChallengeType.missionVariety:
        return '🎲';
      case ChallengeType.perfectWeek:
        return '⭐';
      case ChallengeType.quickDismiss:
        return '⚡';
      case ChallengeType.weekendWarrior:
        return '💪';
    }
  }
}

/// Ежедневный челлендж
class DailyChallenge {
  final String id;
  final ChallengeType type;
  final String title;
  final String description;
  final int targetValue;
  int currentProgress;
  bool isCompleted;
  DateTime? completedAt;
  final DateTime date;
  final int xpReward;
  final String? badgeReward;

  DailyChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.date,
    required this.xpReward,
    this.badgeReward,
  });

  double get progressPercent => (currentProgress / targetValue).clamp(0.0, 1.0);
  bool get isInProgress => !isCompleted && currentProgress > 0;

  void updateProgress(int value) {
    currentProgress = value;
    if (currentProgress >= targetValue && !isCompleted) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'targetValue': targetValue,
        'currentProgress': currentProgress,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'date': date.toIso8601String(),
        'xpReward': xpReward,
        'badgeReward': badgeReward,
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.noSnooze,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      targetValue: json['targetValue'] as int,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      date: DateTime.parse(json['date'] as String),
      xpReward: json['xpReward'] as int,
      badgeReward: json['badgeReward'] as String?,
    );
  }
}

/// ==================== CHALLENGE SERVICE ====================

class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  SharedPreferences? _prefs;
  List<DailyChallenge> _todayChallenges = [];
  DateTime? _lastGeneratedDate;

  List<DailyChallenge> get todayChallenges =>
      List.unmodifiable(_todayChallenges);
  List<DailyChallenge> get completedChallenges =>
      _todayChallenges.where((c) => c.isCompleted).toList();
  List<DailyChallenge> get activeChallenges =>
      _todayChallenges.where((c) => !c.isCompleted).toList();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadChallenges();
    _generateDailyChallengesIfNeeded();
  }

  /// Загрузить сохранённые челленджи
  Future<void> _loadChallenges() async {
    final jsonString = _prefs?.getString('daily_challenges');
    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        _todayChallenges =
            jsonList.map((j) => DailyChallenge.fromJson(j)).toList();

        // Проверяем, не устарели ли челленджи
        if (_todayChallenges.isNotEmpty) {
          final lastDate = _todayChallenges.first.date;
          if (!_isSameDay(lastDate, DateTime.now())) {
            _todayChallenges = []; // Сбрасываем для нового дня
          }
        }
      } catch (e) {
        _todayChallenges = [];
      }
    }
  }

  /// Сохранить челленджи
  Future<void> _saveChallenges() async {
    final jsonList = _todayChallenges.map((c) => c.toJson()).toList();
    await _prefs?.setString('daily_challenges', jsonEncode(jsonList));
  }

  /// Сгенерировать челленджи на сегодня (если нужно)
  void _generateDailyChallengesIfNeeded() {
    if (_todayChallenges.isNotEmpty) return;

    final random = Random();
    final today = DateTime.now();
    final isWeekend = today.weekday == 6 || today.weekday == 7;

    // Генерируем 3 челленджа на день
    final availableTypes = ChallengeType.values.toList()..shuffle(random);

    // В выходные добавляем Weekend Warrior
    if (isWeekend) {
      _todayChallenges.add(_createChallenge(
        ChallengeType.weekendWarrior,
        1,
        100,
        today,
      ));
    }

    // Добавляем случайные челленджи до 3 штук
    for (int i = 0; i < 3 && i < availableTypes.length; i++) {
      if (_todayChallenges.any((c) => c.type == availableTypes[i])) continue;

      final (target, xp) = _getChallengeParams(availableTypes[i]);
      _todayChallenges
          .add(_createChallenge(availableTypes[i], target, xp, today));
    }

    _saveChallenges();
  }

  DailyChallenge _createChallenge(
      ChallengeType type, int target, int xp, DateTime date) {
    return DailyChallenge(
      id: 'challenge_${type.name}_${date.millisecondsSinceEpoch}',
      type: type,
      title: type.displayName,
      description: type.description,
      targetValue: target,
      date: date,
      xpReward: xp,
    );
  }

  (int target, int xp) _getChallengeParams(ChallengeType type) {
    switch (type) {
      case ChallengeType.noSnooze:
        return (1, 50);
      case ChallengeType.consecutiveMissions:
        return (3, 75);
      case ChallengeType.streakDays:
        return (3, 100);
      case ChallengeType.earlyBird:
        return (1, 75);
      case ChallengeType.missionVariety:
        return (2, 60);
      case ChallengeType.perfectWeek:
        return (7, 200);
      case ChallengeType.quickDismiss:
        return (1, 50);
      case ChallengeType.weekendWarrior:
        return (2, 100);
    }
  }

  /// Обновить прогресс челленджа
  Future<List<DailyChallenge>> updateProgress(
    ChallengeType type, {
    int increment = 1,
    Map<String, dynamic>? context,
  }) async {
    final completed = <DailyChallenge>[];

    for (final challenge in _todayChallenges) {
      if (challenge.type == type && !challenge.isCompleted) {
        // Дополнительные проверки для специфических челленджей
        if (_checkChallengeConditions(challenge, context)) {
          challenge.updateProgress(challenge.currentProgress + increment);

          if (challenge.isCompleted) {
            completed.add(challenge);
          }
        }
      }
    }

    await _saveChallenges();
    return completed;
  }

  bool _checkChallengeConditions(
      DailyChallenge challenge, Map<String, dynamic>? context) {
    if (context == null) return true;

    switch (challenge.type) {
      case ChallengeType.earlyBird:
        final hour = context['hour'] as int?;
        return hour != null && hour <= 6;

      case ChallengeType.quickDismiss:
        final dismissTime = context['dismissTimeMs'] as int?;
        return dismissTime != null && dismissTime <= 30000;

      case ChallengeType.weekendWarrior:
        final weekday = context['weekday'] as int?;
        return weekday != null && (weekday == 6 || weekday == 7);

      default:
        return true;
    }
  }

  /// Зарегистрировать подъём (вызывается из AlarmService)
  Future<List<DailyChallenge>> registerWakeUp({
    required bool usedSnooze,
    required Duration? dismissTime,
    required DateTime wakeUpTime,
    required MissionType missionType,
  }) async {
    final completed = <DailyChallenge>[];
    final context = {
      'hour': wakeUpTime.hour,
      'weekday': wakeUpTime.weekday,
      'dismissTimeMs': dismissTime?.inMilliseconds,
      'missionType': missionType.name,
    };

    // No Snooze
    if (!usedSnooze) {
      completed.addAll(
          await updateProgress(ChallengeType.noSnooze, context: context));
    }

    // Quick Dismiss
    if (dismissTime != null && dismissTime.inSeconds <= 30) {
      completed.addAll(
          await updateProgress(ChallengeType.quickDismiss, context: context));
    }

    // Early Bird
    if (wakeUpTime.hour <= 6) {
      completed.addAll(
          await updateProgress(ChallengeType.earlyBird, context: context));
    }

    // Weekend Warrior
    if (wakeUpTime.weekday == 6 || wakeUpTime.weekday == 7) {
      completed.addAll(
          await updateProgress(ChallengeType.weekendWarrior, context: context));
    }

    // Mission Variety (отслеживаем отдельно)
    await _trackMissionType(missionType);

    return completed;
  }

  /// Отслеживание типов миссий для челленджа "Разнообразие"
  Future<void> _trackMissionType(MissionType type) async {
    final today = DateTime.now();
    final key = 'mission_types_${today.year}_${today.month}_${today.day}';

    final types = _prefs?.getStringList(key) ?? [];
    if (!types.contains(type.name)) {
      types.add(type.name);
      await _prefs?.setStringList(key, types);

      if (types.length >= 2) {
        await updateProgress(ChallengeType.missionVariety,
            increment: types.length, context: {});
      }
    }
  }

  /// Получить общий прогресс на сегодня
  Map<String, dynamic> getDailyProgress() {
    final total = _todayChallenges.length;
    final completed = _todayChallenges.where((c) => c.isCompleted).length;
    final totalXp = _todayChallenges
        .where((c) => c.isCompleted)
        .fold(0, (sum, c) => sum + c.xpReward);

    return {
      'totalChallenges': total,
      'completedChallenges': completed,
      'completionPercent': total > 0 ? completed / total : 0.0,
      'totalXpEarned': totalXp,
      'remainingXp': _todayChallenges
          .where((c) => !c.isCompleted)
          .fold(0, (sum, c) => sum + c.xpReward),
    };
  }

  /// Получить историю челленджей
  Future<List<DailyChallenge>> getChallengeHistory({int days = 7}) async {
    final history = <DailyChallenge>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final key = 'daily_challenges_${date.year}_${date.month}_${date.day}';
      final jsonString = _prefs?.getString(key);

      if (jsonString != null) {
        try {
          final jsonList = jsonDecode(jsonString) as List<dynamic>;
          history.addAll(jsonList.map((j) => DailyChallenge.fromJson(j)));
        } catch (e) {
          // Игнорируем повреждённые данные
        }
      }
    }

    return history;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
