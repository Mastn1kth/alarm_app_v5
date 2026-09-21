import 'package:flutter/material.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/services/alarm_service.dart';
import '../../domain/services/anti_cheat_service.dart';
import '../../core/di/injection_container.dart' as di;
import 'mission_screens.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmModel alarm;

  const AlarmRingScreen({super.key, required this.alarm});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen>
    with WidgetsBindingObserver {
  final _alarmService = di.sl<AlarmService>();
  final _antiCheat = di.sl<AntiCheatService>();
  bool _canSnooze = true;
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    _canSnooze = widget.alarm.canSnooze;
    WidgetsBinding.instance.addObserver(this);
    _antiCheat.startAlarmSession(widget.alarm.id);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _wasBackgrounded = true;
    }
  }

  Future<void> _startMission() async {
    if (_wasBackgrounded) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Нельзя отключить будильник после свёртывания приложения')),
        );
      }
      return;
    }

    _antiCheat.startMission(widget.alarm.missionType.name);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MissionScreen(
          missionType: widget.alarm.missionType,
          difficulty: widget.alarm.missionDifficulty,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      await _alarmService.completeMission();
      _antiCheat.endSession();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _snoozeAlarm() async {
    if (!_canSnooze) return;

    final success = await _alarmService.snoozeAlarm();
    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Отложено на ${widget.alarm.snoozeMinutes} минут'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.3),
              radius: 0.8,
              colors: [
                AppTheme.primary.withOpacity(0.3),
                AppTheme.background,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Иконка будильника
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alarm,
                    size: 64,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Время
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // Название будильника
                Text(
                  widget.alarm.title.isEmpty ? 'Будильник' : widget.alarm.title,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),

                // Тип миссии
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.alarm.missionType.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.alarm.missionType.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (widget.alarm.missionDifficulty !=
                    MissionDifficulty.easy) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          widget.alarm.missionDifficulty.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.alarm.missionDifficulty.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.alarm.missionDifficulty.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                const Spacer(flex: 2),

                // Кнопка выполнения миссии
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startMission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Выполнить задание',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Кнопка отложить
                if (_canSnooze) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _snoozeAlarm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.6),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.snooze, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Отложить (${widget.alarm.remainingSnoozes} осталось)',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Предупреждение
                Text(
                  widget.alarm.requireMission
                      ? 'Будильник нельзя отключить без выполнения задания'
                      : 'Нажмите "Выполнить задание" для отключения',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
