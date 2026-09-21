import 'dart:async';
import 'dart:math';

/// ==================== ANTI-CHEAT FRAMEWORK ====================
///
/// Система защиты от обхода миссий и манипуляций с будильником.
/// Работает на уровне приложения без root-доступа к ОС.

/// Правила античита
enum AntiCheatRule {
  preventInstantDismiss, // Запрет мгновенного отключения (< 2 сек)
  preventRapidClose, // Запрет быстрого закрытия экрана
  preventVolumeExploit, // Запрет отключения через кнопки громкости
  preventMissionSkip, // Запрет пропуска миссии
  preventAccidentalDismiss, // Защита от случайного отключения
  preventBackButton, // Блокировка кнопки назад
  preventHomeButton, // Блокировка кнопки домой (частичная)
  preventRecentApps, // Блокировка Recent Apps (частичная)
  preventPowerButton, // Блокировка кнопки питания (частичная)
  enforceMissionTimeout, // Таймаут на выполнение миссии
  detectScreenRecording, // Детекция записи экрана
  detectEmulator, // Детекция эмулятора
}

extension AntiCheatRuleExtension on AntiCheatRule {
  String get displayName {
    switch (this) {
      case AntiCheatRule.preventInstantDismiss:
        return 'Запрет мгновенного отключения';
      case AntiCheatRule.preventRapidClose:
        return 'Запрет быстрого закрытия';
      case AntiCheatRule.preventVolumeExploit:
        return 'Защита от кнопок громкости';
      case AntiCheatRule.preventMissionSkip:
        return 'Запрет пропуска миссии';
      case AntiCheatRule.preventAccidentalDismiss:
        return 'Защита от случайного отключения';
      case AntiCheatRule.preventBackButton:
        return 'Блокировка Back';
      case AntiCheatRule.preventHomeButton:
        return 'Блокировка Home';
      case AntiCheatRule.preventRecentApps:
        return 'Блокировка Recent Apps';
      case AntiCheatRule.preventPowerButton:
        return 'Блокировка Power';
      case AntiCheatRule.enforceMissionTimeout:
        return 'Таймаут миссии';
      case AntiCheatRule.detectScreenRecording:
        return 'Детекция записи';
      case AntiCheatRule.detectEmulator:
        return 'Детекция эмулятора';
    }
  }

  String get description {
    switch (this) {
      case AntiCheatRule.preventInstantDismiss:
        return 'Минимум 2 секунды перед отключением';
      case AntiCheatRule.preventRapidClose:
        return 'Нельзя закрыть приложение мгновенно';
      case AntiCheatRule.preventVolumeExploit:
        return 'Кнопки громкости не отключают будильник';
      case AntiCheatRule.preventMissionSkip:
        return 'Миссия обязательна для отключения';
      case AntiCheatRule.preventAccidentalDismiss:
        return 'Двойное подтверждение для отключения';
      case AntiCheatRule.preventBackButton:
        return 'Кнопка назад заблокирована';
      case AntiCheatRule.preventHomeButton:
        return 'Кнопка домой заблокирована (частично)';
      case AntiCheatRule.preventRecentApps:
        return 'Recent Apps заблокирован (частично)';
      case AntiCheatRule.preventPowerButton:
        return 'Кнопка питания заблокирована (частично)';
      case AntiCheatRule.enforceMissionTimeout:
        return 'Максимум 10 минут на миссию';
      case AntiCheatRule.detectScreenRecording:
        return 'Предупреждение при записи экрана';
      case AntiCheatRule.detectEmulator:
        return 'Предупреждение в эмуляторе';
    }
  }
}

/// Результат проверки античита
class AntiCheatResult {
  final bool isValid;
  final List<AntiCheatViolation> violations;
  final DateTime timestamp;
  final String? sessionId;

  AntiCheatResult({
    required this.isValid,
    required this.violations,
    required this.timestamp,
    this.sessionId,
  });

  bool get hasViolations => violations.isNotEmpty;

  List<String> get violationMessages =>
      violations.map((v) => v.message).toList();

  factory AntiCheatResult.valid({String? sessionId}) {
    return AntiCheatResult(
      isValid: true,
      violations: [],
      timestamp: DateTime.now(),
      sessionId: sessionId,
    );
  }

  factory AntiCheatResult.invalid(List<AntiCheatViolation> violations,
      {String? sessionId}) {
    return AntiCheatResult(
      isValid: false,
      violations: violations,
      timestamp: DateTime.now(),
      sessionId: sessionId,
    );
  }
}

/// Нарушение античита
class AntiCheatViolation {
  final AntiCheatRule rule;
  final String message;
  final DateTime timestamp;
  final String? details;

  AntiCheatViolation({
    required this.rule,
    required this.message,
    required this.timestamp,
    this.details,
  });
}

/// ==================== ANTI-CHEAT SERVICE ====================

class AntiCheatService {
  static final AntiCheatService _instance = AntiCheatService._internal();
  factory AntiCheatService() => _instance;
  AntiCheatService._internal();

  // Активные правила
  final Set<AntiCheatRule> _activeRules = {
    AntiCheatRule.preventInstantDismiss,
    AntiCheatRule.preventRapidClose,
    AntiCheatRule.preventVolumeExploit,
    AntiCheatRule.preventMissionSkip,
    AntiCheatRule.preventAccidentalDismiss,
    AntiCheatRule.preventBackButton,
    AntiCheatRule.enforceMissionTimeout,
  };

  // Сессия будильника
  String? _currentSessionId;
  DateTime? _ringingStartTime;
  DateTime? _missionStartTime;
  int _dismissAttempts = 0;
  final Map<String, int> _missionAttempts = {};

  // Таймауты
  static const Duration _minDismissDuration = Duration(seconds: 2);
  static const Duration _missionTimeout = Duration(minutes: 10);
  static const int _maxDismissAttempts = 3;

  // Stream для уведомлений о нарушениях
  final _violationController = StreamController<AntiCheatViolation>.broadcast();
  Stream<AntiCheatViolation> get onViolation => _violationController.stream;

  /// Активировать правило
  void enableRule(AntiCheatRule rule) {
    _activeRules.add(rule);
  }

  /// Деактивировать правило
  void disableRule(AntiCheatRule rule) {
    _activeRules.remove(rule);
  }

  /// Проверить, активно ли правило
  bool isRuleActive(AntiCheatRule rule) => _activeRules.contains(rule);

  /// Начать сессию будильника
  void startAlarmSession(String alarmId) {
    _currentSessionId = '${alarmId}_${DateTime.now().millisecondsSinceEpoch}';
    _ringingStartTime = DateTime.now();
    _missionStartTime = null;
    _dismissAttempts = 0;
    _missionAttempts.clear();
  }

  /// Начать миссию
  void startMission(String missionType) {
    _missionStartTime = DateTime.now();
    _missionAttempts[missionType] = (_missionAttempts[missionType] ?? 0) + 1;
  }

  /// Завершить сессию
  void endSession() {
    _currentSessionId = null;
    _ringingStartTime = null;
    _missionStartTime = null;
    _dismissAttempts = 0;
    _missionAttempts.clear();
  }

  /// ==================== CHECKS ====================

  /// Проверка перед отключением будильника
  AntiCheatResult checkDismissAttempt() {
    if (_currentSessionId == null) {
      return AntiCheatResult.valid();
    }

    final violations = <AntiCheatViolation>[];

    // Проверка: мгновенное отключение
    if (isRuleActive(AntiCheatRule.preventInstantDismiss)) {
      if (_ringingStartTime != null) {
        final elapsed = DateTime.now().difference(_ringingStartTime!);
        if (elapsed < _minDismissDuration) {
          violations.add(AntiCheatViolation(
            rule: AntiCheatRule.preventInstantDismiss,
            message:
                'Слишком быстро! Подождите ${_minDismissDuration.inSeconds} секунды',
            timestamp: DateTime.now(),
            details: 'Elapsed: ${elapsed.inMilliseconds}ms',
          ));
        }
      }
    }

    // Проверка: случайное отключение (двойное подтверждение)
    if (isRuleActive(AntiCheatRule.preventAccidentalDismiss)) {
      _dismissAttempts++;
      if (_dismissAttempts < 2) {
        violations.add(AntiCheatViolation(
          rule: AntiCheatRule.preventAccidentalDismiss,
          message: 'Нажмите ещё раз для подтверждения (${_dismissAttempts}/2)',
          timestamp: DateTime.now(),
        ));
      }
    }

    // Проверка: пропуск миссии
    if (isRuleActive(AntiCheatRule.preventMissionSkip)) {
      if (_missionStartTime == null) {
        violations.add(AntiCheatViolation(
          rule: AntiCheatRule.preventMissionSkip,
          message: 'Сначала выполните миссию!',
          timestamp: DateTime.now(),
        ));
      }
    }

    return violations.isEmpty
        ? AntiCheatResult.valid(sessionId: _currentSessionId)
        : AntiCheatResult.invalid(violations, sessionId: _currentSessionId);
  }

  /// Проверка миссии
  AntiCheatResult checkMissionCompletion(String missionType,
      {Duration? completionTime}) {
    final violations = <AntiCheatViolation>[];

    // Проверка: таймаут миссии
    if (isRuleActive(AntiCheatRule.enforceMissionTimeout)) {
      if (_missionStartTime != null) {
        final elapsed = DateTime.now().difference(_missionStartTime!);
        if (elapsed > _missionTimeout) {
          violations.add(AntiCheatViolation(
            rule: AntiCheatRule.enforceMissionTimeout,
            message: 'Время на миссию истекло! Будильник продолжает звонить.',
            timestamp: DateTime.now(),
            details: 'Elapsed: ${elapsed.inMinutes} minutes',
          ));
        }
      }
    }

    // Проверка: слишком быстрое выполнение (подозрение на бот/скрипт)
    if (completionTime != null && completionTime < const Duration(seconds: 1)) {
      violations.add(AntiCheatViolation(
        rule: AntiCheatRule.preventInstantDismiss,
        message: 'Подозрительно быстрое выполнение!',
        timestamp: DateTime.now(),
        details: 'Completion time: ${completionTime.inMilliseconds}ms',
      ));
    }

    return violations.isEmpty
        ? AntiCheatResult.valid(sessionId: _currentSessionId)
        : AntiCheatResult.invalid(violations, sessionId: _currentSessionId);
  }

  /// Проверка закрытия экрана
  AntiCheatResult checkScreenClose() {
    final violations = <AntiCheatViolation>[];

    if (isRuleActive(AntiCheatRule.preventRapidClose)) {
      if (_ringingStartTime != null) {
        final elapsed = DateTime.now().difference(_ringingStartTime!);
        if (elapsed < const Duration(seconds: 3)) {
          violations.add(AntiCheatViolation(
            rule: AntiCheatRule.preventRapidClose,
            message: 'Нельзя закрыть экран так быстро!',
            timestamp: DateTime.now(),
          ));
        }
      }
    }

    return violations.isEmpty
        ? AntiCheatResult.valid(sessionId: _currentSessionId)
        : AntiCheatResult.invalid(violations, sessionId: _currentSessionId);
  }

  /// Проверка кнопок громкости
  AntiCheatResult checkVolumeButton() {
    if (isRuleActive(AntiCheatRule.preventVolumeExploit)) {
      return AntiCheatResult.invalid([
        AntiCheatViolation(
          rule: AntiCheatRule.preventVolumeExploit,
          message: 'Кнопки громкости не отключают будильник!',
          timestamp: DateTime.now(),
        )
      ], sessionId: _currentSessionId);
    }
    return AntiCheatResult.valid(sessionId: _currentSessionId);
  }

  /// ==================== EVENT HANDLERS ====================

  /// Обработчик нажатия кнопки назад
  bool onBackButtonPressed() {
    if (isRuleActive(AntiCheatRule.preventBackButton)) {
      _violationController.add(AntiCheatViolation(
        rule: AntiCheatRule.preventBackButton,
        message: 'Кнопка назад заблокирована во время будильника!',
        timestamp: DateTime.now(),
      ));
      return false; // Блокируем
    }
    return true;
  }

  /// Обработчик кнопки Home (частичная блокировка)
  void onHomeButtonPressed() {
    if (isRuleActive(AntiCheatRule.preventHomeButton)) {
      _violationController.add(AntiCheatViolation(
        rule: AntiCheatRule.preventHomeButton,
        message: 'Попытка нажать Home во время будильника',
        timestamp: DateTime.now(),
      ));
      // TODO: Для полной блокировки требуется системный доступ (Android)
    }
  }

  /// Обработчик кнопки питания (частичная блокировка)
  void onPowerButtonPressed() {
    if (isRuleActive(AntiCheatRule.preventPowerButton)) {
      _violationController.add(AntiCheatViolation(
        rule: AntiCheatRule.preventPowerButton,
        message: 'Попытка нажать Power во время будильника',
        timestamp: DateTime.now(),
      ));
      // TODO: Для полной блокировки требуется системный доступ (Android)
    }
  }

  /// ==================== STATISTICS ====================

  /// Получить статистику попыток обхода
  Map<String, dynamic> getStatistics() {
    return {
      'totalSessions': _currentSessionId != null ? 1 : 0,
      'totalDismissAttempts': _dismissAttempts,
      'missionAttempts': _missionAttempts,
      'activeRules': _activeRules.map((r) => r.name).toList(),
    };
  }

  void dispose() {
    _violationController.close();
  }
}

/// ==================== ANTI-CHEAT WIDGET ====================
///
/// Виджет-обёртка для экрана будильника с античит-защитой
///
/// Использование:
/// ```dart
/// AntiCheatGuard(
///   child: AlarmRingScreen(alarm: alarm),
///   onViolation: (violation) => showWarning(violation.message),
/// )
/// ```
///
/// TODO: Реализовать как StatefulWidget с:
/// - WillPopScope для блокировки Back
/// - RawKeyboardListener для блокировки Volume
/// - LifecycleObserver для отслеживания сворачивания
/// - Timer для проверки таймаутов
