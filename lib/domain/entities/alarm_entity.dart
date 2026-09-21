import 'dart:convert';
import 'package:flutter/material.dart';

/// ==================== CORE TYPES ====================

/// Расширенные типы миссий для отключения будильника
enum MissionType {
  math,
  holdButton,
  steps,
  memory,
  typing,
  shakePhone,
  sequence,
  captcha,
}

extension MissionTypeExtension on MissionType {
  String get displayName {
    switch (this) {
      case MissionType.math:
        return 'Математика';
      case MissionType.holdButton:
        return 'Удерживать кнопку';
      case MissionType.steps:
        return 'Шаги';
      case MissionType.memory:
        return 'Память';
      case MissionType.typing:
        return 'Набор текста';
      case MissionType.shakePhone:
        return 'Встряхнуть телефон';
      case MissionType.sequence:
        return 'Последовательность';
      case MissionType.captcha:
        return 'CAPTCHA';
    }
  }

  String get icon {
    switch (this) {
      case MissionType.math:
        return '🧮';
      case MissionType.holdButton:
        return '👆';
      case MissionType.steps:
        return '👟';
      case MissionType.memory:
        return '🧠';
      case MissionType.typing:
        return '⌨️';
      case MissionType.shakePhone:
        return '📳';
      case MissionType.sequence:
        return '🔢';
      case MissionType.captcha:
        return '🔐';
    }
  }

  String get description {
    switch (this) {
      case MissionType.math:
        return 'Решите математические примеры для отключения';
      case MissionType.holdButton:
        return 'Удерживайте кнопку заданное время';
      case MissionType.steps:
        return 'Сделайте необходимое количество шагов';
      case MissionType.memory:
        return 'Запомните и повторите последовательность';
      case MissionType.typing:
        return 'Наберите предложение без ошибок';
      case MissionType.shakePhone:
        return 'Встряхните телефон несколько раз';
      case MissionType.sequence:
        return 'Нажмите кнопки в правильном порядке';
      case MissionType.captcha:
        return 'Решите визуальную задачу';
    }
  }

  /// Рекомендуемая сложность по умолчанию
  MissionDifficulty get defaultDifficulty {
    switch (this) {
      case MissionType.math:
      case MissionType.memory:
      case MissionType.sequence:
        return MissionDifficulty.medium;
      case MissionType.holdButton:
      case MissionType.typing:
      case MissionType.captcha:
        return MissionDifficulty.easy;
      case MissionType.steps:
      case MissionType.shakePhone:
        return MissionDifficulty.hard;
    }
  }

  List<String> get recommendations {
    switch (this) {
      case MissionType.math:
        return [
          'Подходит для лёгкого пробуждения',
          'Тренирует мозг',
          'Рекомендуется для студентов'
        ];
      case MissionType.holdButton:
        return [
          'Простая миссия',
          'Подходит для начинающих',
          'Не требует движения'
        ];
      case MissionType.steps:
        return [
          'Заставляет встать с кровати',
          'Отлично для утренней активности',
          'Требует акселерометр'
        ];
      case MissionType.memory:
        return ['Тренирует память', 'Подходит для всех', 'Можно усложнять'];
      case MissionType.typing:
        return [
          'Тренирует концентрацию',
          'Требует внимательности',
          'Хорошо для пробуждения'
        ];
      case MissionType.shakePhone:
        return [
          'Требует физической активности',
          'Подходит для спортсменов',
          'Интересная механика'
        ];
      case MissionType.sequence:
        return ['Тренирует реакцию', 'Можно усложнять', 'Развивает моторику'];
      case MissionType.captcha:
        return [
          'Самая сложная миссия',
          'Требует полной ясности мысли',
          'Для опытных пользователей'
        ];
    }
  }
}

/// Уровни сложности миссий
enum MissionDifficulty {
  beginner,
  easy,
  medium,
  hard,
  extreme,
}

extension MissionDifficultyExtension on MissionDifficulty {
  String get displayName {
    switch (this) {
      case MissionDifficulty.beginner:
        return 'Новичок';
      case MissionDifficulty.easy:
        return 'Легко';
      case MissionDifficulty.medium:
        return 'Средне';
      case MissionDifficulty.hard:
        return 'Сложно';
      case MissionDifficulty.extreme:
        return 'Экстрим';
    }
  }

  IconData get icon {
    switch (this) {
      case MissionDifficulty.beginner:
        return Icons.eco;
      case MissionDifficulty.easy:
        return Icons.sentiment_satisfied;
      case MissionDifficulty.medium:
        return Icons.sentiment_neutral;
      case MissionDifficulty.hard:
        return Icons.sentiment_dissatisfied;
      case MissionDifficulty.extreme:
        return Icons.local_fire_department;
    }
  }

  int get requiredCount {
    switch (this) {
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

  int get holdDurationSeconds {
    switch (this) {
      case MissionDifficulty.beginner:
        return 5;
      case MissionDifficulty.easy:
        return 10;
      case MissionDifficulty.medium:
        return 15;
      case MissionDifficulty.hard:
        return 20;
      case MissionDifficulty.extreme:
        return 30;
    }
  }

  int get stepTarget {
    switch (this) {
      case MissionDifficulty.beginner:
        return 10;
      case MissionDifficulty.easy:
        return 20;
      case MissionDifficulty.medium:
        return 35;
      case MissionDifficulty.hard:
        return 50;
      case MissionDifficulty.extreme:
        return 75;
    }
  }

  int get shakeTarget {
    switch (this) {
      case MissionDifficulty.beginner:
        return 8;
      case MissionDifficulty.easy:
        return 12;
      case MissionDifficulty.medium:
        return 20;
      case MissionDifficulty.hard:
        return 30;
      case MissionDifficulty.extreme:
        return 45;
    }
  }

  int get memorySequenceLength => requiredCount + 1;

  int get sequenceRounds => requiredCount + 1;

  Color get color {
    switch (this) {
      case MissionDifficulty.beginner:
        return const Color(0xFF4CAF50);
      case MissionDifficulty.easy:
        return const Color(0xFF00BFA6);
      case MissionDifficulty.medium:
        return const Color(0xFFFFB300);
      case MissionDifficulty.hard:
        return const Color(0xFFFF6D00);
      case MissionDifficulty.extreme:
        return const Color(0xFFD50000);
    }
  }

  String get description {
    switch (this) {
      case MissionDifficulty.beginner:
        return 'Простые примеры для начала';
      case MissionDifficulty.easy:
        return 'Быстрое пробуждение';
      case MissionDifficulty.medium:
        return 'Требует внимания';
      case MissionDifficulty.hard:
        return 'Серьёзное пробуждение';
      case MissionDifficulty.extreme:
        return 'Для самых стойких';
    }
  }
}

/// Дни недели для повторения
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension DayOfWeekExtension on DayOfWeek {
  String get shortName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Пн';
      case DayOfWeek.tuesday:
        return 'Вт';
      case DayOfWeek.wednesday:
        return 'Ср';
      case DayOfWeek.thursday:
        return 'Чт';
      case DayOfWeek.friday:
        return 'Пт';
      case DayOfWeek.saturday:
        return 'Сб';
      case DayOfWeek.sunday:
        return 'Вс';
    }
  }

  String get fullName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Понедельник';
      case DayOfWeek.tuesday:
        return 'Вторник';
      case DayOfWeek.wednesday:
        return 'Среда';
      case DayOfWeek.thursday:
        return 'Четверг';
      case DayOfWeek.friday:
        return 'Пятница';
      case DayOfWeek.saturday:
        return 'Суббота';
      case DayOfWeek.sunday:
        return 'Воскресенье';
    }
  }

  int get index => DayOfWeek.values.indexOf(this);
}

/// ==================== SOUND PACK ====================

/// Пакет звуков будильника
enum SoundPack {
  default_,
  classic,
  military,
  nature,
  emergency,
  sciFi,
}

extension SoundPackExtension on SoundPack {
  String get displayName {
    switch (this) {
      case SoundPack.default_:
        return 'Стандартный';
      case SoundPack.classic:
        return 'Классический';
      case SoundPack.military:
        return 'Военный';
      case SoundPack.nature:
        return 'Природа';
      case SoundPack.emergency:
        return 'Сирена';
      case SoundPack.sciFi:
        return 'Sci-Fi';
    }
  }

  String get icon {
    switch (this) {
      case SoundPack.default_:
        return '🔔';
      case SoundPack.classic:
        return '🎵';
      case SoundPack.military:
        return '🎺';
      case SoundPack.nature:
        return '🌊';
      case SoundPack.emergency:
        return '🚨';
      case SoundPack.sciFi:
        return '🚀';
    }
  }

  String get assetPath {
    switch (this) {
      case SoundPack.default_:
        return 'sounds/default_alarm.wav';
      case SoundPack.classic:
        return 'sounds/classic_alarm.wav';
      case SoundPack.military:
        return 'sounds/military_alarm.wav';
      case SoundPack.nature:
        return 'sounds/nature_alarm.wav';
      case SoundPack.emergency:
        return 'sounds/emergency_alarm.wav';
      case SoundPack.sciFi:
        return 'sounds/scifi_alarm.wav';
    }
  }
}

/// ==================== ALARM MODEL ====================

/// Модель будильника (расширенная)
class AlarmModel {
  final String id;
  final String title;
  final int hour;
  final int minute;
  final bool enabled;

  // Повторение
  final bool repeatDaily;
  final List<DayOfWeek> daysOfWeek;

  // Миссия
  final MissionType missionType;
  final MissionDifficulty missionDifficulty;
  final bool requireMission;
  final int missionAttempts;

  // Звук
  final SoundPack soundPack;
  final double soundVolume;
  final bool vibrationEnabled;

  // Отложить
  final bool snoozeEnabled;
  final int snoozeMinutes;
  final int snoozeCount;
  final int maxSnoozeCount;

  // Метаданные
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastTriggeredAt;
  final int triggerCount;

  const AlarmModel({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    this.enabled = true,
    this.repeatDaily = false,
    this.daysOfWeek = const [],
    required this.missionType,
    this.missionDifficulty = MissionDifficulty.medium,
    this.requireMission = true,
    this.missionAttempts = 3,
    this.soundPack = SoundPack.default_,
    this.soundVolume = 1.0,
    this.vibrationEnabled = true,
    this.snoozeEnabled = true,
    this.snoozeMinutes = 5,
    this.snoozeCount = 0,
    this.maxSnoozeCount = 3,
    required this.createdAt,
    required this.updatedAt,
    this.lastTriggeredAt,
    this.triggerCount = 0,
  });

  /// Форматированное время (HH:MM)
  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Текст повторения
  String get repeatText {
    if (repeatDaily) return 'Каждый день';
    if (daysOfWeek.isEmpty) return 'Один раз';
    if (daysOfWeek.length == 7) return 'Каждый день';
    if (daysOfWeek.length == 5 &&
        !daysOfWeek.contains(DayOfWeek.saturday) &&
        !daysOfWeek.contains(DayOfWeek.sunday)) {
      return 'По будням';
    }
    return daysOfWeek.map((d) => d.shortName).join(', ');
  }

  /// Следующее время срабатывания
  DateTime get nextRingTime {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);

    if (next.isBefore(now) || next.isAtSameMomentAs(now)) {
      next = next.add(const Duration(days: 1));
    }

    // Если заданы дни недели, найти следующий подходящий
    if (daysOfWeek.isNotEmpty && !repeatDaily) {
      final targetDays = daysOfWeek.map((d) => d.index + 1).toSet();
      for (int i = 0; i < 7; i++) {
        final checkDay = next.weekday;
        if (targetDays.contains(checkDay)) {
          final checkTime =
              DateTime(next.year, next.month, next.day, hour, minute);
          if (checkTime.isAfter(now)) {
            return checkTime;
          }
        }
        next = next.add(const Duration(days: 1));
      }
    }

    return next;
  }

  /// Осталось времени до срабатывания
  String get timeUntil {
    final diff = nextRingTime.difference(DateTime.now());
    if (diff.isNegative) return 'Просрочен';

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0) {
      return 'через $hours ч ${minutes > 0 ? '$minutes мин' : ''}';
    }
    return 'через $minutes мин';
  }

  /// Можно ли отложить
  bool get canSnooze => snoozeEnabled && snoozeCount < maxSnoozeCount;

  /// Оставшиеся попытки отложить
  int get remainingSnoozes => maxSnoozeCount - snoozeCount;

  AlarmModel copyWith({
    String? id,
    String? title,
    int? hour,
    int? minute,
    bool? enabled,
    bool? repeatDaily,
    List<DayOfWeek>? daysOfWeek,
    MissionType? missionType,
    MissionDifficulty? missionDifficulty,
    bool? requireMission,
    int? missionAttempts,
    SoundPack? soundPack,
    double? soundVolume,
    bool? vibrationEnabled,
    bool? snoozeEnabled,
    int? snoozeMinutes,
    int? snoozeCount,
    int? maxSnoozeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTriggeredAt,
    int? triggerCount,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      missionType: missionType ?? this.missionType,
      missionDifficulty: missionDifficulty ?? this.missionDifficulty,
      requireMission: requireMission ?? this.requireMission,
      missionAttempts: missionAttempts ?? this.missionAttempts,
      soundPack: soundPack ?? this.soundPack,
      soundVolume: soundVolume ?? this.soundVolume,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
      triggerCount: triggerCount ?? this.triggerCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hour': hour,
      'minute': minute,
      'enabled': enabled,
      'repeatDaily': repeatDaily,
      'daysOfWeek': daysOfWeek.map((d) => d.name).toList(),
      'missionType': missionType.name,
      'missionDifficulty': missionDifficulty.name,
      'requireMission': requireMission,
      'missionAttempts': missionAttempts,
      'soundPack': soundPack.name,
      'soundVolume': soundVolume,
      'vibrationEnabled': vibrationEnabled,
      'snoozeEnabled': snoozeEnabled,
      'snoozeMinutes': snoozeMinutes,
      'snoozeCount': snoozeCount,
      'maxSnoozeCount': maxSnoozeCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
      'triggerCount': triggerCount,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String,
      title: json['title'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      enabled: json['enabled'] as bool? ?? true,
      repeatDaily: json['repeatDaily'] as bool? ?? false,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>? ?? [])
          .map((e) => DayOfWeek.values.firstWhere(
                (d) => d.name == e,
                orElse: () => DayOfWeek.monday,
              ))
          .toList(),
      missionType: MissionType.values.firstWhere(
        (e) => e.name == json['missionType'],
        orElse: () => MissionType.math,
      ),
      missionDifficulty: MissionDifficulty.values.firstWhere(
        (e) => e.name == json['missionDifficulty'],
        orElse: () => MissionDifficulty.medium,
      ),
      requireMission: json['requireMission'] as bool? ?? true,
      missionAttempts: json['missionAttempts'] as int? ?? 3,
      soundPack: SoundPack.values.firstWhere(
        (e) => e.name == json['soundPack'],
        orElse: () => SoundPack.default_,
      ),
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 1.0,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      snoozeEnabled: json['snoozeEnabled'] as bool? ?? true,
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
      snoozeCount: json['snoozeCount'] as int? ?? 0,
      maxSnoozeCount: json['maxSnoozeCount'] as int? ?? 3,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastTriggeredAt: json['lastTriggeredAt'] != null
          ? DateTime.parse(json['lastTriggeredAt'] as String)
          : null,
      triggerCount: json['triggerCount'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'AlarmModel(id: $id, title: $title, time: $timeString, enabled: $enabled)';
  }
}
