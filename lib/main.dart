import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'domain/services/alarm_service.dart';
import 'domain/services/user_service.dart';
import 'domain/services/challenge_service.dart';
import 'domain/services/reward_service.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await di.initDependencies();
  await di.sl<UserService>().initialize();
  await di.sl<ChallengeService>().initialize();
  await di.sl<RewardService>().initialize();
  await di.sl<AlarmService>().initialize();

  runApp(const AlarmApp());
}

class AlarmApp extends StatelessWidget {
  const AlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}
