# Alarm App v5 — Project Context

## Stack
- Flutter/Dart, theme dark via `AppTheme`
- State: `provider` + `get_it` DI
- Audio: `audioplayers`, MP3 assets in `assets/sounds/`
- Storage: `shared_preferences`
- Notifications: `flutter_local_notifications`
- No code generation (`build_runner`/`mockito` not configured)

## Architecture
```
lib/
  core/          — DI (injection_container), constants, interfaces
  domain/
    entities/    — alarm_entity.dart (enums, AlarmModel), mission_entity.dart (missions)
    services/    — alarm_service, anti_cheat_service, math_problem_generator
  presentation/
    screens/     — auth_screen, home_screen, add_alarm_screen, alarm_ring_screen,
                   mission_screens, mission_selection_screen, profile_screen,
                   statistics_screen, settings_screen
    theme/       — app_theme.dart (AppTheme, AppTextStyles, AppDecorations, AppAnimations)
    widgets/     — alarm_widgets.dart
```

## Key Rules
- Enums (`MissionType`, `MissionDifficulty`, `DayOfWeek`, `SoundPack`) live in `alarm_entity.dart`
- Mission implementations (`Mission`, `MissionFactory`, `MissionTask`, `MathTask`) in `mission_entity.dart`
- `mission_entity.dart` imports enums from `alarm_entity.dart` — no redefinition
- `MathTask` in `math_problem_generator.dart` is a separate hierarchy from `mission_entity.dart`'s `MathTask`
- `AlarmService.instance` delegates to `di.sl<AlarmService>()` — prefer `di.sl<AlarmService>()` directly
- Colors: always use `AppTheme.primary/surface/background/...`, never `Color(0xFF…)`

## Known Issues
- No Android platform (`android/` missing) — run `flutter create --platforms android .`
- No iOS/macOS/Windows/Linux/web platform directories
- `assets/sounds/` has 6 placeholder MP3s — replace with real audio files
- `assets/fonts/` needs Inter TTF files (Inter-Regular, Medium, SemiBold, Bold)
- `assets/images/` is empty
- Tests pass only after `flutter pub get` + `flutter test` — syntax verified, runtime not
- `flutter_lints` may have issues with `prefer_const_constructors` on `AppTheme.*` refs

## Test Files
- `test/domain/` — alarm_model, mission_entity, anti_cheat, alarm_state_machine (new)
- `test/core/interfaces_test.dart` — uses real domain types
- `test/missions/math_mission_test.dart` — uses real `MathProblemGenerator`
- `test/integration/app_logic_test.dart` — uses real `AlarmModel`
- Old stub types removed from all tests
