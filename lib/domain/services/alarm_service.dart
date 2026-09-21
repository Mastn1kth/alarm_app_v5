import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../entities/alarm_entity.dart';
import '../../data/repositories/alarm_repository.dart';
import '../../core/di/injection_container.dart' as di;
import 'alarm_scheduler_service.dart';
import 'challenge_service.dart';
import 'user_service.dart';

class AlarmService {
  static AlarmService get instance => di.sl<AlarmService>();

  final AlarmRepository _repository;
  final AlarmSchedulerInterface _scheduler;
  final UserService _userService;
  final ChallengeService _challengeService;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _checkTimer;
  StreamSubscription<String>? _schedulerSubscription;

  final StreamController<AlarmModel> _alarmRingController =
      StreamController<AlarmModel>.broadcast();
  Stream<AlarmModel> get onAlarmRing => _alarmRingController.stream;

  List<AlarmModel> _alarms = [];
  List<AlarmModel> get alarms => List.unmodifiable(_alarms);

  AlarmModel? _currentRingingAlarm;
  DateTime? _ringingStartedAt;
  bool _usedSnooze = false;
  AlarmModel? get currentRingingAlarm => _currentRingingAlarm;

  bool get isRinging => _currentRingingAlarm != null;

  AlarmService({
    AlarmRepository? repository,
    AlarmSchedulerInterface? scheduler,
    UserService? userService,
    ChallengeService? challengeService,
  })  : _repository = repository ?? di.sl<AlarmRepository>(),
        _scheduler = scheduler ?? di.sl<AlarmSchedulerInterface>(),
        _userService = userService ?? di.sl<UserService>(),
        _challengeService = challengeService ?? di.sl<ChallengeService>();

  Future<void> initialize() async {
    await _repository.initialize();
    await _loadAlarms();
    _schedulerSubscription =
        _scheduler.onAlarmTriggered.listen(triggerAlarmById);
    await _scheduler.initialize();
    for (final alarm in _alarms.where((alarm) => alarm.enabled)) {
      await _scheduler.scheduleAlarm(alarm);
    }
    if (_scheduler is FlutterAlarmScheduler) {
      _startAlarmChecker();
    }
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(1.0);
  }

  Future<void> _loadAlarms() async {
    _alarms = await _repository.getAllAlarms();
  }

  void _startAlarmChecker() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkAlarms();
    });
  }

  void _checkAlarms() {
    final now = DateTime.now();
    for (final alarm in _alarms) {
      if (!alarm.enabled) continue;
      if (now.hour == alarm.hour &&
          now.minute == alarm.minute &&
          now.second < 20) {
        if (alarm.daysOfWeek.isNotEmpty && !alarm.repeatDaily) {
          final currentDay = DayOfWeek.values[now.weekday - 1];
          if (!alarm.daysOfWeek.contains(currentDay)) continue;
        }
        if (alarm.lastTriggeredAt != null) {
          final lastTrigger = alarm.lastTriggeredAt!;
          if (lastTrigger.year == now.year &&
              lastTrigger.month == now.month &&
              lastTrigger.day == now.day) continue;
        }
        _triggerAlarm(alarm);
        break;
      }
    }
  }

  Future<void> _triggerAlarm(AlarmModel alarm) async {
    if (_currentRingingAlarm != null) return;
    _ringingStartedAt = DateTime.now();
    final updatedAlarm = alarm.copyWith(
      lastTriggeredAt: DateTime.now(),
      triggerCount: alarm.triggerCount + 1,
    );
    _currentRingingAlarm = updatedAlarm;
    await _repository.saveAlarm(updatedAlarm);
    await _loadAlarms();
    _alarmRingController.add(updatedAlarm);
    if (_scheduler is! PlatformChannelAlarmScheduler) {
      await _playAlarmSound(updatedAlarm);
    }
    _lockScreen();
  }

  Future<void> _playAlarmSound(AlarmModel alarm) async {
    try {
      await _audioPlayer.setVolume(alarm.soundVolume);
      await _audioPlayer.play(AssetSource(alarm.soundPack.assetPath));
    } catch (_) {
      // Аудиофайлы могут отсутствовать — игнорируем ошибку
    }
  }

  Future<void> stopAlarmSound() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  void _lockScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void unlockScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    await _repository.saveAlarm(alarm);
    if (alarm.enabled) await _scheduler.scheduleAlarm(alarm);
    await _loadAlarms();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    await _repository.saveAlarm(alarm);
    if (alarm.enabled) {
      await _scheduler.scheduleAlarm(alarm);
    } else {
      await _scheduler.cancelAlarm(alarm.id);
    }
    await _loadAlarms();
  }

  Future<void> deleteAlarm(String id) async {
    await _scheduler.cancelAlarm(id);
    await _repository.deleteAlarm(id);
    await _loadAlarms();
  }

  Future<void> toggleAlarm(String id) async {
    final alarm = _alarms.firstWhere((a) => a.id == id);
    final updated = alarm.copyWith(enabled: !alarm.enabled);
    await updateAlarm(updated);
  }

  Future<bool> snoozeAlarm() async {
    if (_currentRingingAlarm == null) return false;
    final alarm = _currentRingingAlarm!;
    if (!alarm.canSnooze) return false;
    await stopAlarmSound();
    await _scheduler.stopRinging();
    unlockScreen();
    final updated = alarm.copyWith(snoozeCount: alarm.snoozeCount + 1);
    await updateAlarm(updated);
    _usedSnooze = true;
    await _scheduler.snoozeAlarm(
      alarm.id,
      Duration(minutes: alarm.snoozeMinutes),
    );
    _currentRingingAlarm = null;
    return true;
  }

  Future<void> completeMission() async {
    if (_currentRingingAlarm == null) return;
    await stopAlarmSound();
    await _scheduler.stopRinging();
    unlockScreen();
    final alarm = _currentRingingAlarm!;
    final completedAt = DateTime.now();
    final dismissTime = _ringingStartedAt == null
        ? null
        : completedAt.difference(_ringingStartedAt!);
    _currentRingingAlarm = null;
    final updated = alarm.copyWith(snoozeCount: 0);
    if (!alarm.repeatDaily && alarm.daysOfWeek.isEmpty) {
      await updateAlarm(updated.copyWith(enabled: false));
    } else {
      await updateAlarm(updated);
    }
    await _userService.recordWakeUp(
      usedSnooze: _usedSnooze,
      dismissTime: dismissTime,
      missionType: alarm.missionType.name,
    );
    await _challengeService.registerWakeUp(
      usedSnooze: _usedSnooze,
      dismissTime: dismissTime,
      wakeUpTime: completedAt,
      missionType: alarm.missionType,
    );
    _ringingStartedAt = null;
    _usedSnooze = false;
  }

  Future<void> refreshAlarms() async {
    await _loadAlarms();
  }

  Future<void> triggerAlarmById(String id) async {
    final alarm = await _repository.getAlarmById(id);
    if (alarm != null && alarm.enabled) {
      await _triggerAlarm(alarm);
    }
  }

  void dispose() {
    _checkTimer?.cancel();
    _schedulerSubscription?.cancel();
    _audioPlayer.dispose();
    _alarmRingController.close();
  }
}
