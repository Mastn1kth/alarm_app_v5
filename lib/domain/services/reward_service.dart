import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/alarm_entity.dart';

/// ==================== REWARD TYPES ====================

enum RewardType {
  xp,
  badge,
  title,
  achievementUnlock,
  streakBonus,
  levelUp,
}

/// ==================== REWARD ====================

class Reward {
  final String id;
  final RewardType type;
  final String name;
  final String description;
  final int? xpValue;
  final String? badgeIcon;
  final String? titleText;
  final String? achievementId;
  final DateTime earnedAt;
  final bool isClaimed;

  Reward({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    this.xpValue,
    this.badgeIcon,
    this.titleText,
    this.achievementId,
    required this.earnedAt,
    this.isClaimed = false,
  });

  factory Reward.xp(int amount, {String? reason}) {
    return Reward(
      id: 'xp_${DateTime.now().millisecondsSinceEpoch}',
      type: RewardType.xp,
      name: '$amount XP',
      description: reason ?? 'За выполнение задания',
      xpValue: amount,
      earnedAt: DateTime.now(),
    );
  }

  factory Reward.badge(String name, String icon, {String? description}) {
    return Reward(
      id: 'badge_${DateTime.now().millisecondsSinceEpoch}',
      type: RewardType.badge,
      name: name,
      description: description ?? 'Новый бейдж!',
      badgeIcon: icon,
      earnedAt: DateTime.now(),
    );
  }

  factory Reward.title(String title, {String? description}) {
    return Reward(
      id: 'title_${DateTime.now().millisecondsSinceEpoch}',
      type: RewardType.title,
      name: title,
      description: description ?? 'Новый титул!',
      titleText: title,
      earnedAt: DateTime.now(),
    );
  }

  factory Reward.achievementUnlock(String achievementId, String name) {
    return Reward(
      id: 'ach_${DateTime.now().millisecondsSinceEpoch}',
      type: RewardType.achievementUnlock,
      name: 'Достижение: $name',
      description: 'Достижение разблокировано!',
      achievementId: achievementId,
      earnedAt: DateTime.now(),
    );
  }

  factory Reward.streakBonus(int streakDays, int xpBonus) {
    return Reward(
      id: 'streak_${DateTime.now().millisecondsSinceEpoch}',
      type: RewardType.streakBonus,
      name: 'Бонус серии x$streakDays',
      description: 'Бонус за $streakDays дней подряд!',
      xpValue: xpBonus,
      earnedAt: DateTime.now(),
    );
  }

  factory Reward.levelUp(int newLevel) {
    return Reward(
      id: 'levelup_${DateTime.now().millisecondsSinceEpoch}',
      type: RewardType.levelUp,
      name: 'Уровень $newLevel!',
      description: 'Поздравляем с повышением уровня!',
      earnedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'description': description,
        'xpValue': xpValue,
        'badgeIcon': badgeIcon,
        'titleText': titleText,
        'achievementId': achievementId,
        'earnedAt': earnedAt.toIso8601String(),
        'isClaimed': isClaimed,
      };

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.xp,
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      xpValue: json['xpValue'] as int?,
      badgeIcon: json['badgeIcon'] as String?,
      titleText: json['titleText'] as String?,
      achievementId: json['achievementId'] as String?,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }
}

/// ==================== REWARD SERVICE ====================

class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  SharedPreferences? _prefs;
  final List<Reward> _rewards = [];
  final _rewardController = StreamController<Reward>.broadcast();

  Stream<Reward> get onRewardEarned => _rewardController.stream;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadRewards();
  }

  Future<void> _loadRewards() async {
    final jsonString = _prefs?.getString('earned_rewards');
    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        _rewards.clear();
        _rewards.addAll(jsonList.map((j) => Reward.fromJson(j)));
      } catch (e) {
        // Ошибка загрузки
      }
    }
  }

  Future<void> _saveRewards() async {
    final jsonList = _rewards.map((r) => r.toJson()).toList();
    await _prefs?.setString('earned_rewards', jsonEncode(jsonList));
  }

  /// Начислить награду
  Future<Reward> grantReward(Reward reward) async {
    _rewards.add(reward);
    await _saveRewards();
    _rewardController.add(reward);
    return reward;
  }

  /// Начислить XP
  Future<Reward> grantXp(int amount, {String? reason}) async {
    return grantReward(Reward.xp(amount, reason: reason));
  }

  /// Начислить бейдж
  Future<Reward> grantBadge(String name, String icon,
      {String? description}) async {
    return grantReward(Reward.badge(name, icon, description: description));
  }

  /// Начислить титул
  Future<Reward> grantTitle(String title, {String? description}) async {
    return grantReward(Reward.title(title, description: description));
  }

  /// Начислить бонус серии
  Future<Reward> grantStreakBonus(int streakDays) async {
    final xpBonus = streakDays * 10; // 10 XP за каждый день серии
    return grantReward(Reward.streakBonus(streakDays, xpBonus));
  }

  /// Начислить повышение уровня
  Future<Reward> grantLevelUp(int newLevel) async {
    return grantReward(Reward.levelUp(newLevel));
  }

  /// Получить все награды
  List<Reward> get allRewards => List.unmodifiable(_rewards);

  /// Получить невостребованные награды
  List<Reward> get unclaimedRewards =>
      _rewards.where((r) => !r.isClaimed).toList();

  /// Получить награды по типу
  List<Reward> getRewardsByType(RewardType type) =>
      _rewards.where((r) => r.type == type).toList();

  /// Получить общее количество XP из наград
  int get totalXpEarned => _rewards
      .where((r) => r.type == RewardType.xp || r.type == RewardType.streakBonus)
      .fold(0, (sum, r) => sum + (r.xpValue ?? 0));

  /// Получить статистику наград
  Map<String, dynamic> getRewardStats() {
    final stats = <String, int>{};
    for (final type in RewardType.values) {
      stats[type.name] = _rewards.where((r) => r.type == type).length;
    }

    return {
      'totalRewards': _rewards.length,
      'unclaimedCount': unclaimedRewards.length,
      'totalXpEarned': totalXpEarned,
      'byType': stats,
    };
  }

  /// Очистить историю наград (для тестирования)
  Future<void> clearRewards() async {
    _rewards.clear();
    await _prefs?.remove('earned_rewards');
  }

  void dispose() {
    _rewardController.close();
  }
}

/// ==================== SOCIAL LAYER (ARCHITECTURE) ====================

/// Модель друга (локальная, без backend)
class Friend {
  final String id;
  final String name;
  final String? avatarPath;
  final int level;
  final int currentStreak;
  final int bestStreak;
  final int totalWakeUps;
  final DateTime addedAt;
  final String? shareCode; // Код для добавления друга

  Friend({
    required this.id,
    required this.name,
    this.avatarPath,
    required this.level,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalWakeUps = 0,
    required this.addedAt,
    this.shareCode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarPath': avatarPath,
        'level': level,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'totalWakeUps': totalWakeUps,
        'addedAt': addedAt.toIso8601String(),
        'shareCode': shareCode,
      };

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarPath: json['avatarPath'] as String?,
      level: json['level'] as int,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalWakeUps: json['totalWakeUps'] as int? ?? 0,
      addedAt: DateTime.parse(json['addedAt'] as String),
      shareCode: json['shareCode'] as String?,
    );
  }
}

/// Запись в таблице лидеров
class LeaderboardEntry {
  final String userId;
  final String userName;
  final int score;
  final int rank;
  final DateTime recordedAt;
  final String? period; // 'daily', 'weekly', 'monthly', 'alltime'

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.score,
    required this.rank,
    required this.recordedAt,
    this.period,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'score': score,
        'rank': rank,
        'recordedAt': recordedAt.toIso8601String(),
        'period': period,
      };
}

/// Соревнование
class Competition {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final CompetitionType type;
  final List<String> participantIds;
  final Map<String, int> scores; // userId -> score
  final bool isActive;

  Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.participantIds = const [],
    this.scores = const {},
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'type': type.name,
        'participantIds': participantIds,
        'scores': scores,
        'isActive': isActive,
      };
}

enum CompetitionType {
  streakBattle, // Кто дольше серия
  wakeUpRace, // Кто раньше встаёт
  missionMaster, // Кто больше миссий выполнил
  earlyBird, // Кто чаще встаёт до 6
  noSnooze, // Кто без откладывания
}

/// Командный челлендж
class TeamChallenge {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final Map<String, int> teamProgress; // teamId -> progress
  final DateTime deadline;
  final bool isCompleted;

  TeamChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.teamProgress = const {},
    required this.deadline,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetValue': targetValue,
        'teamProgress': teamProgress,
        'deadline': deadline.toIso8601String(),
        'isCompleted': isCompleted,
      };
}

/// ==================== SOCIAL SERVICE (ARCHITECTURE) ====================
///
/// TODO: Реализовать полную функциональность при добавлении backend
/// Пока только локальное хранение и архитектура

class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  SharedPreferences? _prefs;
  final List<Friend> _friends = [];
  final List<Competition> _competitions = [];
  final List<TeamChallenge> _teamChallenges = [];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  Future<void> _loadData() async {
    // TODO: Загрузить друзей, соревнования, командные челленджи
  }

  Future<void> _saveData() async {
    // TODO: Сохранить данные
  }

  /// Добавить друга по коду
  Future<bool> addFriendByCode(String code) async {
    // TODO: Реализовать при добавлении backend
    // Сейчас: локальная заглушка
    return false;
  }

  /// Создать соревнование
  Future<Competition> createCompetition(Competition competition) async {
    _competitions.add(competition);
    await _saveData();
    return competition;
  }

  /// Обновить счёт в соревновании
  Future<void> updateCompetitionScore(
      String competitionId, String userId, int score) async {
    final competition = _competitions.firstWhere((c) => c.id == competitionId);
    final updatedScores = Map<String, int>.from(competition.scores);
    updatedScores[userId] = score;

    // TODO: Обновить соревнование
  }

  /// Получить таблицу лидеров (локальная)
  List<LeaderboardEntry> getLocalLeaderboard({String period = 'weekly'}) {
    // TODO: Сортировать друзей по score
    return [];
  }

  /// Сгенерировать share code для текущего пользователя
  String generateShareCode() {
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10)).join();
    return code;
  }
}
