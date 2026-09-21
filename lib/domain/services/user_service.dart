import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ==================== USER PROFILE ====================

/// Модель профиля пользователя
class UserProfile {
  final String id;
  String name;
  String? avatarPath;
  int currentStreak;
  int bestStreak;
  int totalWakeUps;
  DateTime? lastWakeUpDate;
  DateTime createdAt;
  DateTime updatedAt;

  UserProfile({
    required this.id,
    this.name = 'Пользователь',
    this.avatarPath,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalWakeUps = 0,
    this.lastWakeUpDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarPath': avatarPath,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalWakeUps': totalWakeUps,
      'lastWakeUpDate': lastWakeUpDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Пользователь',
      avatarPath: json['avatarPath'] as String?,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalWakeUps: json['totalWakeUps'] as int? ?? 0,
      lastWakeUpDate: json['lastWakeUpDate'] != null
          ? DateTime.parse(json['lastWakeUpDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserProfile copyWith({
    String? name,
    String? avatarPath,
    int? currentStreak,
    int? bestStreak,
    int? totalWakeUps,
    DateTime? lastWakeUpDate,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalWakeUps: totalWakeUps ?? this.totalWakeUps,
      lastWakeUpDate: lastWakeUpDate ?? this.lastWakeUpDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// ==================== USER PROGRESS / LEVELS ====================

/// Модель прогресса пользователя (уровни и опыт)
class UserProgress {
  final String userId;
  int level;
  int xp;
  int totalXp;
  int xpToNextLevel;

  UserProgress({
    required this.userId,
    this.level = 1,
    this.xp = 0,
    this.totalXp = 0,
    this.xpToNextLevel = 100,
  });

  /// Рассчитать XP для следующего уровня
  static int calculateXpForLevel(int level) {
    // Формула: 100 * level^1.5
    return (100 * (level * 1.5)).round();
  }

  /// Добавить XP и проверить повышение уровня
  bool addXp(int amount) {
    xp += amount;
    totalXp += amount;

    bool leveledUp = false;
    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
      xpToNextLevel = calculateXpForLevel(level);
      leveledUp = true;
    }

    return leveledUp;
  }

  /// Прогресс к следующему уровню (0.0 - 1.0)
  double get levelProgress => xp / xpToNextLevel;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'level': level,
      'xp': xp,
      'totalXp': totalXp,
      'xpToNextLevel': xpToNextLevel,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] as String,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
    );
  }
}

/// ==================== ACHIEVEMENTS ====================

/// Модель достижения
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int requiredValue;
  final AchievementType type;
  bool isUnlocked;
  DateTime? unlockedAt;
  int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredValue,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  /// Проверить, выполнено ли достижение
  bool checkUnlock(int value) {
    currentProgress = value;
    if (!isUnlocked && value >= requiredValue) {
      isUnlocked = true;
      unlockedAt = DateTime.now();
      return true;
    }
    return false;
  }

  double get progressPercent =>
      (currentProgress / requiredValue).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'requiredValue': requiredValue,
      'type': type.name,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      requiredValue: json['requiredValue'] as int,
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.wakeUp,
      ),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      currentProgress: json['currentProgress'] as int? ?? 0,
    );
  }
}

enum AchievementType {
  wakeUp,
  streak,
  mission,
  earlyBird,
  noSnooze,
  custom,
}

/// ==================== STATISTICS ====================

/// Модель статистики пользователя
class UserStatistics {
  final String userId;
  int totalWakeUps;
  int currentStreak;
  int bestStreak;
  int totalMissionsCompleted;
  int totalSnoozes;
  int totalDismissals;
  Duration? averageDismissTime;
  DateTime? lastWakeUpDate;
  Map<String, int> missionTypeCounts;
  Map<String, List<DateTime>> wakeUpHistory;

  UserStatistics({
    required this.userId,
    this.totalWakeUps = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalMissionsCompleted = 0,
    this.totalSnoozes = 0,
    this.totalDismissals = 0,
    this.averageDismissTime,
    this.lastWakeUpDate,
    Map<String, int>? missionTypeCounts,
    Map<String, List<DateTime>>? wakeUpHistory,
  })  : missionTypeCounts = missionTypeCounts ?? {},
        wakeUpHistory = wakeUpHistory ?? {};

  /// Процент успешных подъёмов (без откладывания)
  double get successRate {
    if (totalWakeUps == 0) return 0.0;
    return (totalWakeUps - totalSnoozes) / totalWakeUps;
  }

  /// Зарегистрировать подъём
  void recordWakeUp({
    required bool usedSnooze,
    required Duration? dismissTime,
    required String missionType,
  }) {
    totalWakeUps++;
    totalMissionsCompleted++;
    totalDismissals++;

    if (usedSnooze) {
      totalSnoozes++;
    }

    if (dismissTime != null) {
      if (averageDismissTime == null) {
        averageDismissTime = dismissTime;
      } else {
        // Скользящее среднее
        averageDismissTime = Duration(
          milliseconds:
              ((averageDismissTime!.inMilliseconds * (totalWakeUps - 1) +
                      dismissTime.inMilliseconds) ~/
                  totalWakeUps),
        );
      }
    }

    missionTypeCounts[missionType] = (missionTypeCounts[missionType] ?? 0) + 1;

    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    wakeUpHistory.putIfAbsent(dateKey, () => []).add(today);

    // Обновляем серию
    if (lastWakeUpDate != null) {
      final difference = today.difference(lastWakeUpDate!).inDays;
      if (difference == 1) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else if (difference > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
      bestStreak = 1;
    }

    lastWakeUpDate = today;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalWakeUps': totalWakeUps,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalMissionsCompleted': totalMissionsCompleted,
      'totalSnoozes': totalSnoozes,
      'totalDismissals': totalDismissals,
      'averageDismissTime': averageDismissTime?.inMilliseconds,
      'lastWakeUpDate': lastWakeUpDate?.toIso8601String(),
      'missionTypeCounts': missionTypeCounts,
      'wakeUpHistory': wakeUpHistory.map(
        (key, value) =>
            MapEntry(key, value.map((d) => d.toIso8601String()).toList()),
      ),
    };
  }

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      userId: json['userId'] as String,
      totalWakeUps: json['totalWakeUps'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalMissionsCompleted: json['totalMissionsCompleted'] as int? ?? 0,
      totalSnoozes: json['totalSnoozes'] as int? ?? 0,
      totalDismissals: json['totalDismissals'] as int? ?? 0,
      averageDismissTime: json['averageDismissTime'] != null
          ? Duration(milliseconds: json['averageDismissTime'] as int)
          : null,
      lastWakeUpDate: json['lastWakeUpDate'] != null
          ? DateTime.parse(json['lastWakeUpDate'] as String)
          : null,
      missionTypeCounts: (json['missionTypeCounts'] as Map<dynamic, dynamic>?)
          ?.map((k, v) => MapEntry(k as String, v as int)),
      wakeUpHistory: (json['wakeUpHistory'] as Map<dynamic, dynamic>?)
          ?.map((k, v) => MapEntry(
                k as String,
                (v as List<dynamic>)
                    .map((d) => DateTime.parse(d as String))
                    .toList(),
              )),
    );
  }
}

/// ==================== USER SERVICE ====================

/// Сервис управления пользователем, прогрессом и достижениями
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  SharedPreferences? _prefs;

  UserProfile? _profile;
  UserProgress? _progress;
  UserStatistics? _statistics;
  List<Achievement> _achievements = [];

  UserProfile? get profile => _profile;
  UserProgress? get progress => _progress;
  UserStatistics? get statistics => _statistics;
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProfile();
    await _loadProgress();
    await _loadStatistics();
    await _loadAchievements();
  }

  // ==================== PROFILE ====================

  Future<void> _loadProfile() async {
    final json = _prefs?.getString('user_profile');
    if (json != null) {
      _profile = UserProfile.fromJson(jsonDecode(json));
    } else {
      _profile = UserProfile(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Пользователь',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    if (_profile != null) {
      await _prefs?.setString('user_profile', jsonEncode(_profile!.toJson()));
    }
  }

  Future<void> updateProfile({String? name, String? avatarPath}) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      name: name,
      avatarPath: avatarPath,
    );
    await _saveProfile();
  }

  // ==================== PROGRESS ====================

  Future<void> _loadProgress() async {
    final json = _prefs?.getString('user_progress');
    if (json != null) {
      _progress = UserProgress.fromJson(jsonDecode(json));
    } else {
      _progress = UserProgress(
        userId: _profile?.id ?? 'default',
        level: 1,
        xp: 0,
        totalXp: 0,
        xpToNextLevel: UserProgress.calculateXpForLevel(1),
      );
      await _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    if (_progress != null) {
      await _prefs?.setString('user_progress', jsonEncode(_progress!.toJson()));
    }
  }

  /// Начислить XP за подъём
  Future<bool> addWakeUpXp(
      {bool usedSnooze = false, Duration? dismissTime}) async {
    if (_progress == null) return false;

    int xp = 50; // Базовый XP
    if (!usedSnooze) xp += 25; // Бонус без откладывания
    if (dismissTime != null && dismissTime.inSeconds < 30)
      xp += 25; // Быстрый подъём

    final leveledUp = _progress!.addXp(xp);
    await _saveProgress();
    return leveledUp;
  }

  // ==================== STATISTICS ====================

  Future<void> _loadStatistics() async {
    final json = _prefs?.getString('user_statistics');
    if (json != null) {
      _statistics = UserStatistics.fromJson(jsonDecode(json));
    } else {
      _statistics = UserStatistics(
        userId: _profile?.id ?? 'default',
      );
      await _saveStatistics();
    }
  }

  Future<void> _saveStatistics() async {
    if (_statistics != null) {
      await _prefs?.setString(
          'user_statistics', jsonEncode(_statistics!.toJson()));
    }
  }

  Future<void> recordWakeUp({
    required bool usedSnooze,
    Duration? dismissTime,
    required String missionType,
  }) async {
    _statistics?.recordWakeUp(
      usedSnooze: usedSnooze,
      dismissTime: dismissTime,
      missionType: missionType,
    );
    await _saveStatistics();

    // Обновляем профиль
    if (_profile != null) {
      _profile = _profile!.copyWith(
        totalWakeUps: _profile!.totalWakeUps + 1,
        currentStreak: _statistics!.currentStreak,
        bestStreak: _statistics!.bestStreak,
        lastWakeUpDate: DateTime.now(),
      );
      await _saveProfile();
    }

    // Начисляем XP
    await addWakeUpXp(usedSnooze: usedSnooze, dismissTime: dismissTime);

    // Проверяем достижения
    await _checkAchievements();
  }

  // ==================== ACHIEVEMENTS ====================

  Future<void> _loadAchievements() async {
    final json = _prefs?.getString('user_achievements');
    if (json != null) {
      final list = jsonDecode(json) as List<dynamic>;
      _achievements = list.map((e) => Achievement.fromJson(e)).toList();
    } else {
      _achievements = _createDefaultAchievements();
      await _saveAchievements();
    }
  }

  Future<void> _saveAchievements() async {
    final list = _achievements.map((a) => a.toJson()).toList();
    await _prefs?.setString('user_achievements', jsonEncode(list));
  }

  List<Achievement> _createDefaultAchievements() {
    return [
      Achievement(
        id: 'first_wake_up',
        title: 'Первый подъём',
        description: 'Впервые проснулся с помощью приложения',
        icon: '🌅',
        requiredValue: 1,
        type: AchievementType.wakeUp,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Недельная серия',
        description: 'Просыпайтесь 7 дней подряд',
        icon: '🔥',
        requiredValue: 7,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Месячная серия',
        description: 'Просыпайтесь 30 дней подряд',
        icon: '🏆',
        requiredValue: 30,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'alarms_100',
        title: '100 будильников',
        description: 'Отключите 100 будильников',
        icon: '💯',
        requiredValue: 100,
        type: AchievementType.wakeUp,
      ),
      Achievement(
        id: 'early_bird',
        title: 'Ранняя пташка',
        description: 'Встаньте до 6:00 утра',
        icon: '🐦',
        requiredValue: 1,
        type: AchievementType.earlyBird,
      ),
      Achievement(
        id: 'no_snooze_week',
        title: 'Неделя без откладывания',
        description: '7 дней без нажатия на "Отложить"',
        icon: '⏰',
        requiredValue: 7,
        type: AchievementType.noSnooze,
      ),
    ];
  }

  Future<List<Achievement>> _checkAchievements() async {
    final unlocked = <Achievement>[];

    for (final achievement in _achievements) {
      int value = 0;

      switch (achievement.type) {
        case AchievementType.wakeUp:
          value = _statistics?.totalWakeUps ?? 0;
          break;
        case AchievementType.streak:
          value = _statistics?.currentStreak ?? 0;
          break;
        case AchievementType.mission:
          value = _statistics?.totalMissionsCompleted ?? 0;
          break;
        case AchievementType.earlyBird:
          // TODO: Проверить время подъёма
          value = 0;
          break;
        case AchievementType.noSnooze:
          // TODO: Проверить серию без откладывания
          value = 0;
          break;
        case AchievementType.custom:
          value = achievement.currentProgress;
          break;
      }

      if (achievement.checkUnlock(value)) {
        unlocked.add(achievement);
      }
    }

    await _saveAchievements();
    return unlocked;
  }

  /// Получить разблокированные достижения
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  /// Получить заблокированные достижения
  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();
}
