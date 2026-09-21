import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/alarm_entity.dart';

abstract class AlarmRepository {
  Future<void> initialize();
  Future<List<AlarmModel>> getAllAlarms();
  Future<AlarmModel?> getAlarmById(String id);
  Future<void> saveAlarm(AlarmModel alarm);
  Future<void> deleteAlarm(String id);
  Future<void> saveAllAlarms(List<AlarmModel> alarms);
  Future<void> clearAll();
}

class SharedPreferencesAlarmRepository implements AlarmRepository {
  static const String _alarmsKey = 'alarms_v2';
  static const String _alarmsBackupKey = 'alarms_backup';

  SharedPreferences? _prefs;
  static final SharedPreferencesAlarmRepository _instance =
      SharedPreferencesAlarmRepository._internal();

  factory SharedPreferencesAlarmRepository() => _instance;
  SharedPreferencesAlarmRepository._internal();

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<AlarmModel>> getAllAlarms() async {
    final jsonString = _prefs?.getString(_alarmsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => AlarmModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _restoreFromBackup();
    }
  }

  @override
  Future<AlarmModel?> getAlarmById(String id) async {
    final alarms = await getAllAlarms();
    try {
      return alarms.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAlarm(AlarmModel alarm) async {
    final alarms = await getAllAlarms();
    final index = alarms.indexWhere((a) => a.id == alarm.id);

    if (index >= 0) {
      alarms[index] = alarm;
    } else {
      alarms.add(alarm);
    }

    await saveAllAlarms(alarms);
  }

  @override
  Future<void> deleteAlarm(String id) async {
    final alarms = await getAllAlarms();
    alarms.removeWhere((a) => a.id == id);
    await saveAllAlarms(alarms);
  }

  @override
  Future<void> saveAllAlarms(List<AlarmModel> alarms) async {
    final jsonList = alarms.map((a) => a.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    final current = _prefs?.getString(_alarmsKey);
    if (current != null) {
      await _prefs?.setString(_alarmsBackupKey, current);
    }

    await _prefs?.setString(_alarmsKey, jsonString);
  }

  @override
  Future<void> clearAll() async {
    await _prefs?.remove(_alarmsKey);
    await _prefs?.remove(_alarmsBackupKey);
  }

  Future<List<AlarmModel>> _restoreFromBackup() async {
    final backup = _prefs?.getString(_alarmsBackupKey);
    if (backup == null) return [];

    try {
      final jsonList = jsonDecode(backup) as List<dynamic>;
      return jsonList
          .map((json) => AlarmModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

class AlarmRepositoryProvider {
  static AlarmRepository? _repository;

  static AlarmRepository get repository {
    _repository ??= SharedPreferencesAlarmRepository();
    return _repository!;
  }

  static void setRepository(AlarmRepository repo) {
    _repository = repo;
  }

  static Future<void> initialize() async {
    await repository.initialize();
  }
}
