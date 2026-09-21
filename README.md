# Alarm App

Flutter prototype of a task-based alarm clock. The core idea is that an alarm
is dismissed only after the user completes a selected mission, such as a math
exercise, QR scan, typing task, or movement challenge. The repository focuses
on application logic, screens, missions, local state, and Android alarm
integration; it is not presented as a finished store-ready release.

## Features

### Core Features
- **Task-based Alarm Dismissal**: Choose from multiple mission types to dismiss your alarm
- **Multiple Mission Types**: Math problems, Hold button, QR code scanning, Step counting, Memory games, Typing challenges, and more
- **Smart Alarm Scheduling**: Exact alarms with foreground service support
- **Anti-Cheat System**: Prevents bypassing missions through various exploits
- **Clean Architecture**: Well-structured, scalable codebase following Clean Architecture principles

### Gamification
- **User Profile**: Track your progress, level, and achievements
- **Achievement System**: Unlock achievements for consistent wake-ups
- **Level & XP System**: Gain experience points for completing alarms and missions
- **Daily Challenges**: Complete special challenges for bonus rewards
- **Statistics**: Detailed analytics about your wake-up habits

### Premium Features (Architecture Ready)
- **Subscription Tiers**: Free, Premium, and Lifetime plans
- **Feature Gating**: Unlock advanced missions and features with premium
- **Social Features**: Friends, leaderboards, and team challenges (architecture prepared)

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: StatefulWidget + ChangeNotifier (prepared for BLoC/Riverpod migration)
- **Local Storage**: SharedPreferences (prepared for Hive/SQLite migration)
- **Notifications**: flutter_local_notifications
- **Localization**: flutter_localizations + intl
- **Sensors**: sensors_plus (for shake missions)
- **QR Scanning**: mobile_scanner
- **Audio**: audioplayers

## Project Structure

````
lib/
├── core/
│   ├── constants/          # App constants, theme data
│   ├── errors/             # Failure classes, exceptions
│   ├── usecases/           # Base use case classes
│   └── utils/              # Utility functions, extensions
├── data/
│   ├── models/             # Data models (AlarmModel, UserProfile, etc.)
│   ├── repositories/       # Repository implementations
│   └── datasources/        # Local/Remote data sources
├── domain/
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces (abstract)
│   └── services/           # Business logic services
├── presentation/
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable widgets
│   └── blocs/              # State management (prepared)
├── missions/               # Mission handlers and logic
├── l10n/                   # Localization files (ARB)
└── main.dart               # Entry point

docs/
├── roadmap.md              # Project roadmap and feature planning
└── architecture_v2.md      # Architecture documentation

android/
├── app/src/main/
│   ├── kotlin/...            # Android native code
│   └── AndroidManifest.xml   # Permissions and receivers
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 2.17 or higher
- Android Studio or VS Code with Flutter extensions
- Android SDK (for Android development)
- Git

### Installation

1. **Clone the repository**
   ````bash
   git clone <repository-url>
   cd alarm_app
   ```

2. **Install dependencies**
   ````bash
   flutter pub get
   ```

3. **Generate localization files**
   ````bash
   flutter gen-l10n
   ```

4. **Run the app**
   ````bash
   flutter run
   ```

### Building for Production

**Android APK:**
````bash
flutter build apk --release
```

**Android App Bundle (for Google Play):**
````bash
flutter build appbundle --release
```

**With obfuscation:**
````bash
flutter build apk --obfuscate --split-debug-info=symbols
```

## Architecture

The project follows **Clean Architecture** with three main layers:

### 1. Presentation Layer
- Screens and widgets
- State management
- UI logic
- Located in: `lib/presentation/`

### 2. Domain Layer
- Business logic
- Use cases
- Repository interfaces (abstract)
- Entity definitions
- Located in: `lib/domain/`

### 3. Data Layer
- Repository implementations
- Data models
- Data sources (local/remote)
- Located in: `lib/data/`

### Key Services

- **AlarmService**: Core alarm management (CRUD operations)
- **AlarmSchedulerService**: Platform-specific alarm scheduling
- **StorageService**: Local data persistence
- **AntiCheatService**: Mission validation and exploit prevention
- **UserService**: Profile and progress management
- **ChallengeService**: Daily challenges and rewards
- **FeatureGateService**: Premium feature management

## Mission Types

| Mission | Description | Difficulty |
|---------|-------------|------------|
| **Math** | Solve arithmetic problems | Easy - Extreme |
| **Hold Button** | Hold a button for N seconds | Easy - Hard |
| **QR Code** | Scan a specific QR code | Medium |
| **Steps** | Walk a certain number of steps | Easy - Hard |
| **Memory** | Repeat a sequence of symbols | Easy - Extreme |
| **Typing** | Type a phrase without errors | Easy - Extreme |
| **Shake Phone** | Shake the phone vigorously | Easy - Hard |
| **Sequence** | Complete a pattern sequence | Medium - Hard |
| **Captcha** | Solve a visual challenge | Medium |

## Localization

The app supports multiple languages:
- **English** (en) - Complete
- **Russian** (ru) - Complete

To add a new language:
1. Create `lib/l10n/app_<language_code>.arb`
2. Add translations following the existing ARB structure
3. Run `flutter gen-l10n`
4. Update supported locales in `main.dart`

## Configuration

### Android Permissions

The following permissions are required in `AndroidManifest.xml`:

````xml
<!-- Alarm scheduling -->
<<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<<uses-permission android:name="android.permission.USE_EXACT_ALARM" />

<!-- Foreground service -->
<<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Notifications -->
<<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<<uses-permission android:name="android.permission.VIBRATE" />

<!-- Sensors -->
<<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<<uses-permission android:name="android.permission.HIGH_SAMPLING_RATE_SENSORS" />

<!-- Camera (for QR missions) -->
<<uses-permission android:name="android.permission.CAMERA" />
```

### Native Components

The app requires native Android components for reliable alarm delivery:

- **AlarmReceiver**: Receives alarm broadcasts and triggers the ringing screen
- **AlarmService**: Foreground service that keeps the alarm active
- **BootReceiver**: Reschedules alarms after device reboot
- **AlarmActivity**: Full-screen activity for alarm ringing (bypasses Doze mode)

## Development Roadmap

### V1 - Core (Completed)
- Basic alarm functionality
- Math and Hold Button missions
- Local storage
- Dark UI theme

### V2 - Enhanced Missions (In Progress)
- QR, Steps, Memory, Typing missions
- Anti-cheat framework
- Alarm state machine

### V3 - Gamification (Architecture Ready)
- Achievements system
- Level and XP system
- Daily challenges
- Statistics screen

### V4 - Social (Planned)
- Friends system
- Leaderboards
- Team challenges
- Competitions

### V5 - Premium (Planned)
- Subscription tiers
- Premium missions
- Advanced statistics
- Cloud backup

## Testing

### Unit Tests
````bash
flutter test
```

### Integration Tests
````bash
flutter test integration_test/
```

### Widget Tests
````bash
flutter test test/widget/
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary and confidential.

## Troubleshooting

### Common Issues

**Alarm not ringing:**
- Ensure battery optimization is disabled for the app
- Check that exact alarm permissions are granted
- Verify the app is not killed by the system

**Missions not working:**
- Check sensor permissions for shake/step missions
- Ensure camera permission for QR missions
- Verify the mission difficulty is set correctly

**Build errors:**
- Run `flutter clean` and `flutter pub get`
- Ensure Android SDK is properly configured
- Check that all native dependencies are installed

## Support

For issues and feature requests, please use the project's issue tracker.

---

Built with Flutter. Designed to wake you up.
