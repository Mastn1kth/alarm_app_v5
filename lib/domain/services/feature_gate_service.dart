/// ==================== SUBSCRIPTION TIER ====================

enum SubscriptionTier {
  free,
  premium,
  lifetime,
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Бесплатный';
      case SubscriptionTier.premium:
        return 'Премиум';
      case SubscriptionTier.lifetime:
        return 'Навсегда';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.free:
        return 'Базовый функционал';
      case SubscriptionTier.premium:
        return 'Все миссии и статистика';
      case SubscriptionTier.lifetime:
        return 'Пожизненный доступ ко всему';
    }
  }

  bool get hasAllMissions => this != SubscriptionTier.free;
  bool get hasExtendedStats => this != SubscriptionTier.free;
  bool get hasCloudBackup =>
      this == SubscriptionTier.premium || this == SubscriptionTier.lifetime;
  bool get hasPrioritySupport => this != SubscriptionTier.free;
  bool get hasCustomSounds => this != SubscriptionTier.free;
  bool get hasNoAds => this != SubscriptionTier.free;
  int get maxAlarms => this == SubscriptionTier.free ? 5 : 999;
  int get maxQrCodes => this == SubscriptionTier.free ? 1 : 999;
  int get maxFriends => this == SubscriptionTier.free ? 0 : 50;
}

/// ==================== FEATURE GATE ====================

enum AppFeature {
  unlimitedAlarms,
  allMissionTypes,
  qrMission,
  stepsMission,
  shakeMission,
  memoryMission,
  typingMission,
  sequenceMission,
  captchaMission,
  extendedStatistics,
  weeklyReports,
  cloudBackup,
  customSounds,
  socialFeatures,
  leaderboard,
  competitions,
  teamChallenges,
  prioritySupport,
  noAds,
  exportData,
}

extension AppFeatureExtension on AppFeature {
  String get displayName {
    switch (this) {
      case AppFeature.unlimitedAlarms:
        return 'Неограниченные будильники';
      case AppFeature.allMissionTypes:
        return 'Все типы миссий';
      case AppFeature.qrMission:
        return 'QR-миссия';
      case AppFeature.stepsMission:
        return 'Миссия "Шаги"';
      case AppFeature.shakeMission:
        return 'Миссия "Встряхнуть"';
      case AppFeature.memoryMission:
        return 'Миссия "Память"';
      case AppFeature.typingMission:
        return 'Миссия "Набор текста"';
      case AppFeature.sequenceMission:
        return 'Миссия "Последовательность"';
      case AppFeature.captchaMission:
        return 'Миссия "CAPTCHA"';
      case AppFeature.extendedStatistics:
        return 'Расширенная статистика';
      case AppFeature.weeklyReports:
        return 'Еженедельные отчёты';
      case AppFeature.cloudBackup:
        return 'Облачный бэкап';
      case AppFeature.customSounds:
        return 'Кастомные звуки';
      case AppFeature.socialFeatures:
        return 'Социальные функции';
      case AppFeature.leaderboard:
        return 'Таблица лидеров';
      case AppFeature.competitions:
        return 'Соревнования';
      case AppFeature.teamChallenges:
        return 'Командные челленджи';
      case AppFeature.prioritySupport:
        return 'Приоритетная поддержка';
      case AppFeature.noAds:
        return 'Без рекламы';
      case AppFeature.exportData:
        return 'Экспорт данных';
    }
  }

  String? get requiredTier {
    switch (this) {
      case AppFeature.unlimitedAlarms:
        return 'premium';
      case AppFeature.allMissionTypes:
        return 'premium';
      case AppFeature.qrMission:
        return 'premium';
      case AppFeature.stepsMission:
        return 'premium';
      case AppFeature.shakeMission:
        return 'premium';
      case AppFeature.memoryMission:
        return 'premium';
      case AppFeature.typingMission:
        return 'premium';
      case AppFeature.sequenceMission:
        return 'premium';
      case AppFeature.captchaMission:
        return 'premium';
      case AppFeature.extendedStatistics:
        return 'premium';
      case AppFeature.weeklyReports:
        return 'premium';
      case AppFeature.cloudBackup:
        return 'premium';
      case AppFeature.customSounds:
        return 'premium';
      case AppFeature.socialFeatures:
        return 'premium';
      case AppFeature.leaderboard:
        return 'premium';
      case AppFeature.competitions:
        return 'premium';
      case AppFeature.teamChallenges:
        return 'premium';
      case AppFeature.prioritySupport:
        return 'premium';
      case AppFeature.noAds:
        return 'premium';
      case AppFeature.exportData:
        return 'premium';
    }
  }
}

/// ==================== FEATURE GATE SERVICE ====================

class FeatureGateService {
  static final FeatureGateService _instance = FeatureGateService._internal();
  factory FeatureGateService() => _instance;
  FeatureGateService._internal();

  SubscriptionTier _currentTier = SubscriptionTier.free;

  SubscriptionTier get currentTier => _currentTier;

  /// Установить уровень подписки (для тестирования или после покупки)
  void setTier(SubscriptionTier tier) {
    _currentTier = tier;
  }

  /// Проверить доступность функции
  bool isFeatureAvailable(AppFeature feature) {
    switch (feature) {
      // Всегда доступно для free
      case AppFeature.noAds:
        return true; // Пока нет рекламы

      // Требует premium
      case AppFeature.unlimitedAlarms:
      case AppFeature.allMissionTypes:
      case AppFeature.qrMission:
      case AppFeature.stepsMission:
      case AppFeature.shakeMission:
      case AppFeature.memoryMission:
      case AppFeature.typingMission:
      case AppFeature.sequenceMission:
      case AppFeature.captchaMission:
      case AppFeature.extendedStatistics:
      case AppFeature.weeklyReports:
      case AppFeature.cloudBackup:
      case AppFeature.customSounds:
      case AppFeature.socialFeatures:
      case AppFeature.leaderboard:
      case AppFeature.competitions:
      case AppFeature.teamChallenges:
      case AppFeature.prioritySupport:
      case AppFeature.exportData:
        return _currentTier != SubscriptionTier.free;
    }
  }

  /// Проверить ограничение количества
  bool checkLimit(AppFeature feature, int currentCount) {
    switch (feature) {
      case AppFeature.unlimitedAlarms:
        return currentCount < _currentTier.maxAlarms;
      case AppFeature.qrMission:
        return currentCount < _currentTier.maxQrCodes;
      case AppFeature.socialFeatures:
        return currentCount < _currentTier.maxFriends;
      default:
        return true;
    }
  }

  /// Получить доступные функции для текущего уровня
  List<AppFeature> getAvailableFeatures() {
    return AppFeature.values.where((f) => isFeatureAvailable(f)).toList();
  }

  /// Получить заблокированные функции для текущего уровня
  List<AppFeature> getLockedFeatures() {
    return AppFeature.values.where((f) => !isFeatureAvailable(f)).toList();
  }

  /// Получить список функций с информацией о блокировке
  List<FeatureInfo> getFeatureInfoList() {
    return AppFeature.values
        .map((feature) => FeatureInfo(
              feature: feature,
              isAvailable: isFeatureAvailable(feature),
              requiredTier: feature.requiredTier != null
                  ? SubscriptionTier.values.firstWhere(
                      (t) => t.name == feature.requiredTier,
                      orElse: () => SubscriptionTier.premium,
                    )
                  : null,
            ))
        .toList();
  }

  /// Проверить можно ли создать будильник
  bool canCreateAlarm(int currentAlarmCount) {
    return checkLimit(AppFeature.unlimitedAlarms, currentAlarmCount);
  }

  /// Проверить можно ли использовать миссию
  bool canUseMissionType(String missionType) {
    if (_currentTier != SubscriptionTier.free) return true;

    // Для free доступны только базовые миссии
    final freeMissions = ['math', 'holdButton'];
    return freeMissions.contains(missionType);
  }

  /// Получить сообщение об ограничении
  String? getLimitMessage(AppFeature feature) {
    if (isFeatureAvailable(feature)) return null;

    switch (feature) {
      case AppFeature.unlimitedAlarms:
        return 'Бесплатная версия: максимум 5 будильников. Обновитесь до Premium.';
      case AppFeature.qrMission:
      case AppFeature.stepsMission:
      case AppFeature.shakeMission:
      case AppFeature.memoryMission:
      case AppFeature.typingMission:
      case AppFeature.sequenceMission:
      case AppFeature.captchaMission:
        return 'Эта миссия доступна только в Premium. Обновитесь для разблокировки.';
      case AppFeature.extendedStatistics:
        return 'Расширенная статистика доступна в Premium.';
      case AppFeature.cloudBackup:
        return 'Облачный бэкап доступен в Premium.';
      default:
        return 'Эта функция доступна в Premium. Обновитесь для разблокировки.';
    }
  }
}

/// ==================== FEATURE INFO ====================

class FeatureInfo {
  final AppFeature feature;
  final bool isAvailable;
  final SubscriptionTier? requiredTier;

  FeatureInfo({
    required this.feature,
    required this.isAvailable,
    this.requiredTier,
  });
}

/// ==================== SUBSCRIPTION MANAGER ====================
///
/// TODO: Реализовать интеграцию с платёжными системами
/// Google Play Billing для Android
/// App Store In-App Purchase для iOS

class SubscriptionManager {
  static final SubscriptionManager _instance = SubscriptionManager._internal();
  factory SubscriptionManager() => _instance;
  SubscriptionManager._internal();

  final FeatureGateService _featureGate = FeatureGateService();

  SubscriptionTier get currentTier => _featureGate.currentTier;

  /// Инициализация (проверка существующих покупок)
  Future<void> initialize() async {
    // TODO: Проверить восстановленные покупки
    // TODO: Подключить Google Play Billing
    // TODO: Подключить App Store IAP
  }

  /// Купить подписку
  Future<bool> purchasePremium() async {
    // TODO: Реализовать покупку через Google Play Billing
    // TODO: Реализовать покупку через App Store IAP

    // Временно для тестирования:
    _featureGate.setTier(SubscriptionTier.premium);
    return true;
  }

  /// Купить пожизненный доступ
  Future<bool> purchaseLifetime() async {
    // TODO: Реализовать покупку

    // Временно для тестирования:
    _featureGate.setTier(SubscriptionTier.lifetime);
    return true;
  }

  /// Восстановить покупки
  Future<bool> restorePurchases() async {
    // TODO: Проверить восстановленные покупки
    return false;
  }

  /// Отменить подписку (только для premium, не lifetime)
  Future<void> cancelSubscription() async {
    // TODO: Открыть настройки Google Play / App Store
  }

  /// Получить цены (для UI)
  Map<String, String> getPrices() {
    // TODO: Загрузить реальные цены из стора
    return {
      'premium_monthly': '\$2.99/мес',
      'premium_yearly': '\$19.99/год',
      'lifetime': '\$49.99',
    };
  }

  /// Проверить активность подписки
  bool get isPremiumActive =>
      _featureGate.currentTier == SubscriptionTier.premium ||
      _featureGate.currentTier == SubscriptionTier.lifetime;
}
