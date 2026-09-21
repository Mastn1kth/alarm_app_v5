# Alarm App V2 - Architecture Documentation

## Общая архитектура

Приложение построено по принципам **Clean Architecture** с разделением на 4 слоя:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                         │
│  Screens | Widgets | Theme | BLoC (future)                  │
├─────────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER                             │
│  Entities | Services | Use Cases | Repositories (abstract)  │
├─────────────────────────────────────────────────────────────┤
│                    DATA LAYER                               │
│  Repositories (impl) | Models | Local Storage | DataSources │
├─────────────────────────────────────────────────────────────┤
│                    CORE LAYER                               │
│  Constants | Errors | Use Cases (base)                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Слои приложения

### 1. Core Layer (`lib/core/`)

**Назначение:** Базовые классы, константы, обработка ошибок.

- `constants/` - Константы приложения (цвета, размеры, таймауты)
- `errors/` - Классы ошибок (AppException, NetworkException, StorageException)
- `usecases/` - Базовые UseCase классы (FutureUseCase, StreamUseCase)

**Принцип:** Не зависит от других слоёв. Используется всеми остальными.

### 2. Domain Layer (`lib/domain/`)

**Назначение:** Бизнес-логика, сущности, абстракции репозиториев.

#### Entities (`lib/domain/entities/`)

- **AlarmEntity** (`alarm_entity.dart`) - Расширенная модель будильника
  - 18 полей: время, дни недели, миссия, сложность, звук, громкость, вибрация, snooze, метаданные
  - Методы: `nextRingTime`, `timeUntil`, `repeatText`, `canSnooze`
  
- **MissionEntity** (`mission_entity.dart`) - Система миссий
  - 9 типов миссий: math, holdButton, steps, qr, memory, typing, shakePhone, sequence, captcha
  - Базовый интерфейс `Mission` с `createTasks()`, `validate()`, `hint`, `recommendations`
  - `MissionFactory` для создания миссий
  - `MissionTask` абстрактный класс задачи

#### Services (`lib/domain/services/`)

| Сервис | Назначение | Статус |
|--------|-----------|--------|
| `alarm_service.dart` | CRUD операции с будильниками, базовое планирование | ✅ Работает |
| `alarm_scheduler_service.dart` | Exact alarms, State Machine, foreground service, reschedule | ✅ Архитектура + Flutter fallback |
| `anti_cheat_service.dart` | 12 правил защиты от обхода миссий | ✅ Архитектура + проверки |
| `user_service.dart` | Профиль, уровни, XP, достижения | ✅ Работает |
| `challenge_service.dart` | Ежедневные челленджи (8 типов) | ✅ Архитектура + логика |
| `reward_service.dart` | Система наград (6 типов) | ✅ Архитектура |
| `qr_mission_service.dart` | QR миссии: хранение меток, привязка, валидация | ✅ Архитектура + логика |
| `feature_gate_service.dart` | Premium tiers, Feature gates, Subscription | ✅ Архитектура |
| `enhanced_statistics_service.dart` | Расширенная статистика: дни недели, типы миссий, реакция | ✅ Архитектура + модели |

#### Repositories (abstract) (`lib/domain/repositories/`)

- `AlarmRepository` - абстракция для хранения будильников
  - 3 реализации: SharedPreferences (рабочая), Hive (заготовка), SQLite (заготовка)

### 3. Data Layer (`lib/data/`)

**Назначение:** Реализация репозиториев, модели данных, локальное хранение.

- `repositories/` - Реализации репозиториев
  - `SharedPreferencesAlarmRepository` - JSON в SharedPreferences с бэкапом
  - `HiveAlarmRepository` - заготовка для Hive
  - `SQLiteAlarmRepository` - заготовка для SQLite
- `models/` - DTO модели (для преобразования Entity -> Storage)
- `local/` - Локальные data sources (SharedPreferences, Hive, SQLite)
- `datasources/` - Внешние data sources (API, Cloud - future)

### 4. Presentation Layer (`lib/presentation/`)

**Назначение:** UI, экраны, виджеты, тема.

#### Screens (`lib/presentation/screens/`)

| Экран | Назначение | Статус |
|-------|-----------|--------|
| `home_screen.dart` | Список будильников, переключатели, дни недели | ✅ Работает |
| `add_alarm_screen.dart` | Создание: время, дни, миссия, звук, snooze | ✅ Работает |
| `alarm_ring_screen.dart` | Полноэкранный звонок, snooze, миссия | ✅ Работает |
| `mission_screens.dart` | 9 миссий: Math, HoldButton, Memory, Typing, QR, Shake, Steps, Sequence, Captcha | ✅ 4 полные + 5 архитектура |
| `mission_selection_screen.dart` | Выбор миссии с BottomSheet сложности | ✅ Работает |
| `profile_screen.dart` | Профиль, уровень, XP, достижения | ✅ Работает |
| `statistics_screen.dart` | Статистика, графики, прогресс | ✅ Работает |
| `settings_screen.dart` | Настройки, язык, опасная зона | ✅ Работает |

#### Theme (`lib/presentation/theme/`)

- `app_theme.dart` - Material 3, цвета, типографика, анимации, декорации

#### Widgets (`lib/presentation/widgets/`)

- `alarm_widgets.dart` - Переиспользуемые: AlarmCard, GradientButton, StatCard, CircularProgress

---

## Поток данных

### Создание будильника

```
User Input (AddAlarmScreen)
    ↓
AlarmService.addAlarm()
    ↓
AlarmRepository.saveAlarm() [SharedPreferences]
    ↓
AlarmSchedulerService.scheduleAlarm()
    ↓
AlarmStateMachine.transition(scheduled)
    ↓
UI Update (HomeScreen)
```

### Срабатывание будильника

```
AlarmSchedulerService._checkAlarms() [Timer / Exact Alarm]
    ↓
AlarmStateMachine.transition(ringing)
    ↓
AntiCheatService.startAlarmSession()
    ↓
AlarmRingScreen (fullscreen, locked)
    ↓
User completes Mission
    ↓
AntiCheatService.checkMissionCompletion()
    ↓
AlarmStateMachine.transition(completed)
    ↓
UserService.recordWakeUp() + XP
    ↓
ChallengeService.registerWakeUp() + check challenges
    ↓
RewardService.grantRewards()
    ↓
Statistics update
```

### Система миссий

```
MissionFactory.createMission(type, difficulty)
    ↓
Mission.createTasks() → List<MissionTask>
    ↓
MissionScreen (type-specific UI)
    ↓
User input → MissionTask.validate()
    ↓
All tasks completed → Alarm dismissed
```

---

## Система миссий

### Архитектура

```
Mission (abstract)
    ├── title, description, difficulty
    ├── createTasks() → List<MissionTask>
    ├── validate() → bool
    └── hint, recommendations, icon

MissionTask (abstract)
    ├── question, expectedAnswer
    ├── validate(userAnswer) → bool
    └── isCompleted, completionDuration

MissionFactory
    └── createMission(type, difficulty) → Mission
```

### Реализованные миссии

| Миссия | Статус | Описание |
|--------|--------|----------|
| **Math** | ✅ Полная | 3 примера (+, −, ×), проверка ответа |
| **HoldButton** | ✅ Полная | Удерживание 15 сек с прогресс-баром |
| **Memory** | ✅ Полная | Последовательность символов, повторение |
| **Typing** | ✅ Полная | Случайная фраза, проверка без ошибок |
| **QR** | 🏗️ Архитектура | Хранение меток, привязка, валидация. TODO: mobile_scanner |
| **Shake** | 🏗️ Архитектура | Структура готова. TODO: sensors_plus |
| **Steps** | 🏗️ Архитектура | Заготовка. TODO: sensors_plus |
| **Sequence** | 🏗️ Архитектура | Заготовка |
| **Captcha** | 🏗️ Архитектура | Заготовка |

---

## Система уровней

### Модель

```
UserProgress
    ├── level (1+)
    ├── xp (0 - xpToNextLevel)
    ├── totalXp (всего заработано)
    └── xpToNextLevel = 100 * level^1.5
```

### Начисление XP

| Действие | XP |
|----------|-----|
| Базовый подъём | 50 |
| Без snooze | +25 |
| Быстрый подъём (< 30 сек) | +25 |
| Выполнение челленджа | 50-200 |
| Серия (streak bonus) | 10 * дней |
| Повышение уровня | - |

### Повышение уровня

```
addXp(amount) → xp += amount
    ↓
while xp >= xpToNextLevel:
    xp -= xpToNextLevel
    level++
    xpToNextLevel = 100 * level^1.5
    trigger LevelUp reward
```

---

## Система достижений

### Модель

```
Achievement
    ├── id, title, description, icon
    ├── type (wakeUp, streak, mission, earlyBird, noSnooze, custom)
    ├── requiredValue
    ├── currentProgress
    ├── isUnlocked
    └── unlockedAt
```

### Достижения (6 штук)

| ID | Название | Условие | Тип |
|----|----------|---------|-----|
| first_wake_up | Первый подъём | 1 подъём | wakeUp |
| streak_7 | Недельная серия | 7 дней подряд | streak |
| streak_30 | Месячная серия | 30 дней подряд | streak |
| alarms_100 | 100 будильников | 100 отключений | wakeUp |
| early_bird | Ранняя пташка | Встать до 6:00 | earlyBird |
| no_snooze_week | Неделя без откладывания | 7 дней без snooze | noSnooze |

### Проверка

```
UserService.recordWakeUp() → checkAchievements()
    ↓
Achievement.checkUnlock(value) → isUnlocked?
    ↓
RewardService.grantAchievementUnlock()
    ↓
Notification + UI update
```

---

## Anti-Cheat System

### Архитектура

```
AntiCheatService
    ├── activeRules: Set<AntiCheatRule>
    ├── session management
    ├── violation detection
    └── statistics

AntiCheatRule (enum, 12 правил)
    ├── preventInstantDismiss (min 2 sec)
    ├── preventRapidClose (min 3 sec)
    ├── preventVolumeExploit (volume buttons blocked)
    ├── preventMissionSkip (mission required)
    ├── preventAccidentalDismiss (double confirm)
    ├── preventBackButton (back blocked)
    ├── preventHomeButton (home blocked - partial)
    ├── preventRecentApps (recent blocked - partial)
    ├── preventPowerButton (power blocked - partial)
    ├── enforceMissionTimeout (max 10 min)
    ├── detectScreenRecording (warning)
    └── detectEmulator (warning)
```

### Поток проверок

```
Alarm rings → AntiCheatService.startAlarmSession()
    ↓
User attempts dismiss → checkDismissAttempt()
    ├── preventInstantDismiss: elapsed > 2s?
    ├── preventAccidentalDismiss: attempts >= 2?
    └── preventMissionSkip: mission completed?
    ↓
Valid? → dismiss
Invalid? → violation + block + warning
```

---

## Alarm Scheduler

### Архитектура

```
AlarmSchedulerInterface (abstract)
    ├── initialize()
    ├── scheduleAlarm(alarm)
    ├── cancelAlarm(id)
    ├── snoozeAlarm(id, duration)
    ├── rescheduleAll()
    └── onAlarmTriggered: Stream<String>

FlutterAlarmScheduler (fallback)
    ├── Timer.periodic(10s) for checking
    └── In-memory alarm list

PlatformChannelAlarmScheduler (production)
    ├── Android AlarmManager (exact alarms)
    ├── ForegroundService (keeps app alive)
    ├── BootReceiver (reschedule on reboot)
    └── MethodChannel for native integration
```

### Alarm State Machine

```
AlarmState (enum)
    ├── scheduled → ringing | cancelled
    ├── ringing → completed | snoozed | missed
    ├── snoozed → ringing | cancelled
    ├── completed → (terminal)
    ├── missed → ringing (can restart)
    └── cancelled → scheduled (can reschedule)

AlarmStateMachine
    ├── transition(id, newState) with validation
    ├── history tracking
    └── state change notifications
```

### Reschedule после перезагрузки

```
BootReceiver (Android)
    ├── Device rebooted
    ├── Read all alarms from storage
    ├── Filter enabled alarms
    └── AlarmScheduler.rescheduleAll()
```

---

## Premium Architecture

### Subscription Tiers

| Функция | Free | Premium | Lifetime |
|---------|------|---------|----------|
| Будильники | 5 | ∞ | ∞ |
| QR метки | 1 | ∞ | ∞ |
| Миссии | math, holdButton | Все 9 | Все 9 |
| Статистика | Базовая | Расширенная | Расширенная |
| Облако | ❌ | ✅ | ✅ |
| Социальное | ❌ | ✅ | ✅ |
| Реклама | ❌ | ❌ | ❌ |

### Feature Gate

```
FeatureGateService
    ├── currentTier: SubscriptionTier
    ├── isFeatureAvailable(feature) → bool
    ├── checkLimit(feature, count) → bool
    └── getLimitMessage(feature) → String?

SubscriptionManager
    ├── purchasePremium()
    ├── purchaseLifetime()
    ├── restorePurchases()
    └── cancelSubscription()
```

---

## Интеграция с нативным Android

### Необходимые разрешения (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### Нативные компоненты (TODO)

```kotlin
// AlarmReceiver.kt - получает exact alarms
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Запуск ForegroundService + показ fullscreen activity
    }
}

// AlarmService.kt - foreground service
class AlarmService : Service() {
    // Удерживает процесс alive, пока звонит будильник
    // Управляет звуком, вибрацией, уведомлением
}

// BootReceiver.kt - reschedule после перезагрузки
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_BOOT_COMPLETED) {
            // Reschedule all enabled alarms
        }
    }
}
```

---

## Зависимости (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  shared_preferences: ^2.2.2      # Локальное хранение
  intl: ^0.18.1                   # Форматирование дат
  flutter_local_notifications: ^16.3.0  # Локальные уведомления
  timezone: ^0.9.2                # Часовые пояса
  sensors_plus: ^4.0.2            # Акселерометр (TODO)
  mobile_scanner: ^3.5.5          # QR сканер (TODO)
  audioplayers: ^5.2.1            # Воспроизведение звука
```

---

## Статус готовности по функциям

| Функция | Архитектура | Логика | UI | Интеграция | Готовность |
|---------|------------|--------|-----|-----------|------------|
| Базовый будильник | ✅ | ✅ | ✅ | ✅ | 100% |
| Math Mission | ✅ | ✅ | ✅ | ✅ | 100% |
| HoldButton Mission | ✅ | ✅ | ✅ | ✅ | 100% |
| Memory Mission | ✅ | ✅ | ✅ | ✅ | 100% |
| Typing Mission | ✅ | ✅ | ✅ | ✅ | 100% |
| QR Mission | ✅ | ✅ | ✅ | 🏗️ | 80% |
| Shake Mission | ✅ | ✅ | ✅ | 🏗️ | 80% |
| Steps Mission | ✅ | 🏗️ | 🏗️ | 🏗️ | 40% |
| Sequence Mission | ✅ | 🏗️ | 🏗️ | - | 20% |
| Captcha Mission | ✅ | 🏗️ | 🏗️ | - | 20% |
| Alarm Scheduler | ✅ | ✅ | - | 🏗️ | 70% |
| State Machine | ✅ | ✅ | - | - | 90% |
| Anti-Cheat | ✅ | ✅ | - | - | 80% |
| User Profile | ✅ | ✅ | ✅ | - | 90% |
| Statistics | ✅ | ✅ | ✅ | - | 85% |
| Achievements | ✅ | ✅ | ✅ | - | 90% |
| Daily Challenges | ✅ | ✅ | - | - | 75% |
| Rewards | ✅ | ✅ | - | - | 70% |
| Social Layer | ✅ | 🏗️ | - | - | 30% |
| Premium | ✅ | 🏗️ | - | - | 40% |
| Localization | ✅ | 🏗️ | 🏗️ | - | 30% |

**Легенда:**
- ✅ Готово
- 🏗️ В разработке / заготовка
- ❌ Не начато

---

## Следующие шаги для production

1. **Android Native Integration**
   - Реализовать AlarmReceiver, AlarmService, BootReceiver
   - Настроить exact alarms через AlarmManager
   - Добавить foreground service

2. **Sensors Integration**
   - Подключить sensors_plus
   - Реализовать детекцию шагов и встряхивания

3. **QR Scanner**
   - Подключить mobile_scanner
   - Реализовать экран сканирования

4. **Payment Integration**
   - Google Play Billing
   - App Store In-App Purchase

5. **Cloud Sync**
   - Firebase / AWS для бэкапа
   - Синхронизация между устройствами

6. **Testing**
   - Unit tests для сервисов
   - Widget tests для экранов
   - Integration tests для E2E сценариев
