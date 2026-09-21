import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import '../../data/repositories/alarm_repository.dart';
import '../../domain/services/alarm_service.dart';
import '../../domain/services/alarm_scheduler_service.dart';
import '../../domain/services/user_service.dart';
import '../../domain/services/challenge_service.dart';
import '../../domain/services/reward_service.dart';
import '../../domain/services/feature_gate_service.dart';
import '../../domain/services/anti_cheat_service.dart';
import '../../domain/services/math_problem_generator.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Repository
  sl.registerLazySingleton<AlarmRepository>(
      () => SharedPreferencesAlarmRepository());

  // Services
  sl.registerLazySingleton<AlarmService>(() => AlarmService());
  sl.registerLazySingleton<AlarmSchedulerInterface>(
    () => defaultTargetPlatform == TargetPlatform.android
        ? PlatformChannelAlarmScheduler()
        : FlutterAlarmScheduler(),
  );
  sl.registerLazySingleton<UserService>(() => UserService());
  sl.registerLazySingleton<ChallengeService>(() => ChallengeService());
  sl.registerLazySingleton<RewardService>(() => RewardService());
  sl.registerLazySingleton<FeatureGateService>(() => FeatureGateService());
  sl.registerLazySingleton<AntiCheatService>(() => AntiCheatService());
  sl.registerLazySingleton<MathProblemGenerator>(() => MathProblemGenerator());
}

Future<void> resetDependencies() async {
  await sl.reset();
}
