import 'package:flutter/material.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Alarm App';
  static const String appVersion = '1.0.0';

  static const String alarmsStorageKey = 'alarms_v2';
  static const String alarmsBackupKey = 'alarms_backup';
  static const String userProfileKey = 'user_profile';
  static const String userProgressKey = 'user_progress';
  static const String userAchievementsKey = 'user_achievements';
  static const String userStatisticsKey = 'user_statistics';
  static const String challengeKey = 'daily_challenges';
  static const String completedChallengesKey = 'completed_challenges';
  static const String qrCodesKey = 'saved_qr_codes';
  static const String preferredMissionKey = 'preferred_mission';
  static const String preferredDifficultyKey = 'preferred_difficulty';

  static const int defaultSnoozeMinutes = 5;
  static const int maxSnoozes = 3;
  static const int alarmCheckIntervalSeconds = 15;

  static const Color primaryColor = AppTheme.primary;
  static const Color backgroundColor = AppTheme.background;
  static const Color cardColor = AppTheme.surface;
  static const Color successColor = AppTheme.success;
}
