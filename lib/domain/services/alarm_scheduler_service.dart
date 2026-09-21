import 'dart:async';
import 'package:flutter/services.dart';
import '../entities/alarm_entity.dart';

/// ==================== ALARM STATE ====================

/// Состояния жизненного цикла будильника
enum AlarmState {
  scheduled, // Запланирован, ждёт срабатывания
  ringing, // Звонит прямо сейчас
  snoozed, // Отложен (snooze)
  completed, // Миссия выполнена, будильник отключён
  missed, // Пропущен (не отключён вовремя)
  cancelled, // Отменён пользователем
}

extension AlarmStateExtension on AlarmState {
  String get displayName {
    switch (this) {
      case AlarmState.scheduled:
        return 'Запланирован';
      case AlarmState.ringing:
        return 'Звонит';
      case AlarmState.snoozed:
        return 'Отложен';
      case AlarmState.completed:
        return 'Выполнен';
      case AlarmState.missed:
        return 'Пропущен';
      case AlarmState.cancelled:
        return 'Отменён';
    }
  }

  bool get isActive =>
      this == AlarmState.scheduled ||
      this == AlarmState.ringing ||
      this == AlarmState.snoozed;
  bool get isTerminal =>
      this == AlarmState.completed ||
      this == AlarmState.missed ||
      this == AlarmState.cancelled;
}

/// ==================== ALARM STATE MACHINE ====================

/// Централизованное управление состоянием будильника
class AlarmStateMachine {
  final Map<String, AlarmState> _states = {};
  final Map<String, DateTime> _stateTimestamps = {};
  final Map<String, AlarmStateHistory> _history = {};

  final _stateController = StreamController<AlarmStateChange>.broadcast();
  Stream<AlarmStateChange> get stateChanges => _stateController.stream;

  /// Получить текущее состояние будильника
  AlarmState getState(String alarmId) {
    return _states[alarmId] ?? AlarmState.scheduled;
  }

  /// Получить время последнего изменения состояния
  DateTime? getStateTimestamp(String alarmId) {
    return _stateTimestamps[alarmId];
  }

  /// Получить историю состояний
  List<AlarmStateTransition> getHistory(String alarmId) {
    return _history[alarmId]?.transitions ?? [];
  }

  /// Переход в новое состояние с валидацией
  bool transition(String alarmId, AlarmState newState, {String? reason}) {
    final currentState = getState(alarmId);

    // Валидация перехода
    if (!_isValidTransition(currentState, newState)) {
      print(
          'Invalid transition: $currentState -> $newState for alarm $alarmId');
      return false;
    }

    final timestamp = DateTime.now();
    _states[alarmId] = newState;
    _stateTimestamps[alarmId] = timestamp;

    // Записываем в историю
    _history
        .putIfAbsent(alarmId, () => AlarmStateHistory(alarmId: alarmId))
        .addTransition(currentState, newState, timestamp, reason: reason);

    // Уведомляем слушателей
    _stateController.add(AlarmStateChange(
      alarmId: alarmId,
      fromState: currentState,
      toState: newState,
      timestamp: timestamp,
      reason: reason,
    ));

    return true;
  }

  /// Проверка валидности перехода
  bool _isValidTransition(AlarmState from, AlarmState to) {
    if (from == AlarmState.scheduled && to == AlarmState.scheduled) {
      return true;
    }
    // Разрешённые переходы
    final validTransitions = {
      AlarmState.scheduled: [AlarmState.ringing, AlarmState.cancelled],
      AlarmState.ringing: [
        AlarmState.completed,
        AlarmState.snoozed,
        AlarmState.missed
      ],
      AlarmState.snoozed: [AlarmState.ringing, AlarmState.cancelled],
      AlarmState.completed: [], // Терминальное состояние
      AlarmState.missed: [AlarmState.ringing], // Можно перезапустить
      AlarmState.cancelled: [AlarmState.scheduled], // Можно перезапланировать
    };

    return validTransitions[from]?.contains(to) ?? false;
  }

  /// Сброс состояния (для повторяющихся будильников)
  void reset(String alarmId) {
    _states.remove(alarmId);
    _stateTimestamps.remove(alarmId);
    // Историю оставляем для статистики
  }

  /// Получить все активные будильники
  List<String> getActiveAlarmIds() {
    return _states.entries
        .where((e) => e.value.isActive)
        .map((e) => e.key)
        .toList();
  }

  /// Получить все звонящие будильники
  List<String> getRingingAlarmIds() {
    return _states.entries
        .where((e) => e.value == AlarmState.ringing)
        .map((e) => e.key)
        .toList();
  }

  void dispose() {
    _stateController.close();
  }
}

/// ==================== STATE HISTORY ====================

class AlarmStateTransition {
  final AlarmState fromState;
  final AlarmState toState;
  final DateTime timestamp;
  final String? reason;
  final Duration? duration; // Длительность предыдущего состояния

  AlarmStateTransition({
    required this.fromState,
    required this.toState,
    required this.timestamp,
    this.reason,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'fromState': fromState.name,
        'toState': toState.name,
        'timestamp': timestamp.toIso8601String(),
        'reason': reason,
        'durationMs': duration?.inMilliseconds,
      };
}

class AlarmStateHistory {
  final String alarmId;
  final List<AlarmStateTransition> transitions = [];

  AlarmStateHistory({required this.alarmId});

  void addTransition(AlarmState from, AlarmState to, DateTime timestamp,
      {String? reason}) {
    Duration? duration;
    if (transitions.isNotEmpty) {
      duration = timestamp.difference(transitions.last.timestamp);
    }

    transitions.add(AlarmStateTransition(
      fromState: from,
      toState: to,
      timestamp: timestamp,
      reason: reason,
      duration: duration,
    ));
  }

  /// Получить время, проведённое в состоянии
  Duration getTimeInState(AlarmState state) {
    Duration total = Duration.zero;
    for (int i = 0; i < transitions.length; i++) {
      if (transitions[i].fromState == state &&
          transitions[i].duration != null) {
        total += transitions[i].duration!;
      }
    }
    return total;
  }

  /// Получить среднее время реакции (scheduled -> completed)
  Duration? getAverageReactionTime() {
    final reactionTimes = <Duration>[];

    for (int i = 0; i < transitions.length; i++) {
      if (transitions[i].fromState == AlarmState.ringing &&
          transitions[i].toState == AlarmState.completed) {
        // Ищем предыдущий переход в ringing
        for (int j = i - 1; j >= 0; j--) {
          if (transitions[j].toState == AlarmState.ringing) {
            reactionTimes.add(
                transitions[i].timestamp.difference(transitions[j].timestamp));
            break;
          }
        }
      }
    }

    if (reactionTimes.isEmpty) return null;

    final totalMs = reactionTimes.fold(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ reactionTimes.length);
  }
}

class AlarmStateChange {
  final String alarmId;
  final AlarmState fromState;
  final AlarmState toState;
  final DateTime timestamp;
  final String? reason;

  AlarmStateChange({
    required this.alarmId,
    required this.fromState,
    required this.toState,
    required this.timestamp,
    this.reason,
  });
}

/// ==================== ALARM SCHEDULER SERVICE ====================
///
/// Основной сервис планирования будильников.
/// Отвечает за точное время срабатывания, foreground service,
/// reschedule после перезагрузки и управление несколькими будильниками.

abstract class AlarmSchedulerInterface {
  Future<void> initialize();
  Future<void> scheduleAlarm(AlarmModel alarm);
  Future<void> cancelAlarm(String alarmId);
  Future<void> snoozeAlarm(String alarmId, Duration duration);
  Future<void> rescheduleAll();
  Future<List<AlarmModel>> getScheduledAlarms();
  Future<void> stopRinging();
  Stream<String> get onAlarmTriggered;
}

/// Реализация для Flutter (без нативного кода)
/// TODO: Для production заменить на PlatformChannelAlarmScheduler
class FlutterAlarmScheduler implements AlarmSchedulerInterface {
  final AlarmStateMachine _stateMachine = AlarmStateMachine();
  Timer? _checkTimer;
  final _triggerController = StreamController<String>.broadcast();

  List<AlarmModel> _scheduledAlarms = [];
  final Map<String, Timer> _snoozeTimers = {};

  @override
  Stream<String> get onAlarmTriggered => _triggerController.stream;

  @override
  Future<void> initialize() async {
    // TODO: Запросить разрешение на exact alarms (Android 12+)
    // TODO: Инициализировать AndroidAlarmManager
    // TODO: Зарегистрировать BootReceiver

    _startPeriodicCheck();
  }

  /// Запуск периодической проверки (fallback для Flutter-only)
  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    // Проверяем каждые 10 секунд
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkAlarms();
    });
  }

  void _checkAlarms() {
    final now = DateTime.now();

    for (final alarm in _scheduledAlarms) {
      if (!alarm.enabled) continue;

      final state = _stateMachine.getState(alarm.id);
      if (state != AlarmState.scheduled && state != AlarmState.snoozed)
        continue;

      // Проверяем совпадение времени
      if (now.hour == alarm.hour &&
          now.minute == alarm.minute &&
          now.second < 20) {
        // Проверяем дни недели
        if (alarm.daysOfWeek.isNotEmpty && !alarm.repeatDaily) {
          final currentDay = DayOfWeek.values[now.weekday - 1];
          if (!alarm.daysOfWeek.contains(currentDay)) continue;
        }

        // Проверяем, не звонил ли уже сегодня
        if (alarm.lastTriggeredAt != null) {
          final lastTrigger = alarm.lastTriggeredAt!;
          if (lastTrigger.year == now.year &&
              lastTrigger.month == now.month &&
              lastTrigger.day == now.day) {
            continue;
          }
        }

        _triggerAlarm(alarm);
      }
    }
  }

  void _triggerAlarm(AlarmModel alarm) {
    _stateMachine.transition(alarm.id, AlarmState.ringing,
        reason: 'Time matched: ${alarm.hour}:${alarm.minute}');
    _triggerController.add(alarm.id);
  }

  @override
  Future<void> scheduleAlarm(AlarmModel alarm) async {
    // Удаляем старую запись если есть
    _scheduledAlarms.removeWhere((a) => a.id == alarm.id);
    _scheduledAlarms.add(alarm);

    _stateMachine.transition(alarm.id, AlarmState.scheduled,
        reason: 'Alarm scheduled');

    // TODO: Для Android использовать AlarmManager.setExactAndAllowWhileIdle
    // TODO: Для iOS использовать UILocalNotification
  }

  @override
  Future<void> cancelAlarm(String alarmId) async {
    _scheduledAlarms.removeWhere((a) => a.id == alarmId);
    _snoozeTimers[alarmId]?.cancel();
    _snoozeTimers.remove(alarmId);

    _stateMachine.transition(alarmId, AlarmState.cancelled,
        reason: 'Alarm cancelled by user');
  }

  @override
  Future<void> snoozeAlarm(String alarmId, Duration duration) async {
    _stateMachine.transition(alarmId, AlarmState.snoozed,
        reason: 'Snoozed for ${duration.inMinutes} minutes');

    // Отменяем текущий звонок
    _snoozeTimers[alarmId]?.cancel();

    // Запускаем таймер для повторного срабатывания
    _snoozeTimers[alarmId] = Timer(duration, () {
      final alarm = _scheduledAlarms.firstWhere((a) => a.id == alarmId);
      _triggerAlarm(alarm);
    });

    // TODO: Для Android использовать AlarmManager с точным временем
  }

  @override
  Future<void> rescheduleAll() async {
    // TODO: Вызывать после перезагрузки устройства
    // TODO: Перечитать все будильники из хранилища и перезапланировать

    for (final alarm in _scheduledAlarms) {
      if (alarm.enabled) {
        await scheduleAlarm(alarm);
      }
    }
  }

  @override
  Future<List<AlarmModel>> getScheduledAlarms() async {
    return List.unmodifiable(_scheduledAlarms);
  }

  @override
  Future<void> stopRinging() async {}

  /// Отметить будильник как выполненный
  void markCompleted(String alarmId) {
    _stateMachine.transition(alarmId, AlarmState.completed,
        reason: 'Mission completed successfully');

    // Для повторяющихся будильников сбрасываем состояние
    final alarm = _scheduledAlarms.firstWhere((a) => a.id == alarmId);
    if (alarm.repeatDaily || alarm.daysOfWeek.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        _stateMachine.reset(alarmId);
        _stateMachine.transition(alarmId, AlarmState.scheduled,
            reason: 'Rescheduled for next occurrence');
      });
    }
  }

  /// Отметить будильник как пропущенный
  void markMissed(String alarmId) {
    _stateMachine.transition(alarmId, AlarmState.missed,
        reason: 'Alarm not dismissed within timeout');
  }

  /// Получить состояние машины (для внешнего доступа)
  AlarmStateMachine get stateMachine => _stateMachine;

  void dispose() {
    _checkTimer?.cancel();
    _triggerController.close();
    _snoozeTimers.values.forEach((t) => t.cancel());
    _stateMachine.dispose();
  }
}

/// ==================== NATIVE SCHEDULER STUB ====================
///
/// TODO: Реализовать через MethodChannel для Android:
///
/// Android компоненты:
/// 1. AlarmReceiver (BroadcastReceiver) - получает exact alarms
/// 2. AlarmService (ForegroundService) - держит будильник активным
/// 3. BootReceiver - reschedule после перезагрузки
/// 4. AlarmManager - точное планирование
///
/// Необходимые разрешения в AndroidManifest.xml:
/// ```xml
/// <uses-permission android:name="android.permission.WAKE_LOCK" />
/// <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
/// <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
/// <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
/// <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
/// <receiver android:name=".alarm.AlarmReceiver" />
/// <receiver android:name=".alarm.BootReceiver"
///     android:enabled="true"
///     android:exported="true">
///     <intent-filter>
///         <action android:name="android.intent.action.BOOT_COMPLETED" />
///     </intent-filter>
/// </receiver>
/// <service android:name=".alarm.AlarmService"
///     android:foregroundServiceType="dataSync" />
/// ```

class PlatformChannelAlarmScheduler implements AlarmSchedulerInterface {
  static const MethodChannel _channel =
      MethodChannel('com.alarmapp.alarm_app/scheduler');
  final StreamController<String> _triggerController =
      StreamController<String>.broadcast();
  final Map<String, AlarmModel> _scheduledAlarms = {};

  @override
  Stream<String> get onAlarmTriggered => _triggerController.stream;

  @override
  Future<void> initialize() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'alarmTriggered' && call.arguments is String) {
        _triggerController.add(call.arguments as String);
      }
    });
    await _channel.invokeMethod<void>('initialize');
    final launchAlarmId =
        await _channel.invokeMethod<String>('consumeLaunchAlarmId');
    if (launchAlarmId != null) {
      scheduleMicrotask(() => _triggerController.add(launchAlarmId));
    }
  }

  @override
  Future<void> scheduleAlarm(AlarmModel alarm) async {
    _scheduledAlarms[alarm.id] = alarm;
    await _channel.invokeMethod<void>('scheduleAlarm', alarm.toJson());
  }

  @override
  Future<void> cancelAlarm(String alarmId) async {
    _scheduledAlarms.remove(alarmId);
    await _channel.invokeMethod<void>('cancelAlarm', {'alarmId': alarmId});
  }

  @override
  Future<void> snoozeAlarm(String alarmId, Duration duration) async {
    final alarm = _scheduledAlarms[alarmId];
    if (alarm == null) return;
    await _channel.invokeMethod<void>('snoozeAlarm', {
      'alarm': alarm.toJson(),
      'durationMs': duration.inMilliseconds,
    });
  }

  @override
  Future<void> rescheduleAll() => _channel.invokeMethod<void>('rescheduleAll');

  @override
  Future<List<AlarmModel>> getScheduledAlarms() async =>
      List.unmodifiable(_scheduledAlarms.values);

  @override
  Future<void> stopRinging() => _channel.invokeMethod<void>('stopRinging');

  void dispose() {
    _triggerController.close();
  }
}
