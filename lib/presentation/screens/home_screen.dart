import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/services/alarm_service.dart';
import '../../core/di/injection_container.dart' as di;
import 'add_alarm_screen.dart';
import 'alarm_ring_screen.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _alarmService = di.sl<AlarmService>();
  List<AlarmModel> _alarms = [];
  bool _isLoading = true;
  StreamSubscription<AlarmModel>? _alarmSubscription;
  String? _displayedAlarmId;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _setupAlarmListener();
  }

  void _setupAlarmListener() {
    _alarmSubscription = _alarmService.onAlarmRing.listen((alarm) {
      _openAlarmScreen(alarm);
    });

    final activeAlarm = _alarmService.currentRingingAlarm;
    if (activeAlarm != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAlarmScreen(activeAlarm);
      });
    }
  }

  void _openAlarmScreen(AlarmModel alarm) {
    if (!mounted || _displayedAlarmId == alarm.id) return;
    _displayedAlarmId = alarm.id;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => AlarmRingScreen(alarm: alarm),
        fullscreenDialog: true,
      ),
    )
        .whenComplete(() {
      _displayedAlarmId = null;
      _loadAlarms();
    });
  }

  Future<void> _loadAlarms() async {
    await _alarmService.refreshAlarms();
    if (mounted) {
      setState(() {
        _alarms = _alarmService.alarms;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAlarm(String id) async {
    await _alarmService.toggleAlarm(id);
    _loadAlarms();
  }

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Удалить будильник?',
            style: TextStyle(color: Colors.white)),
        content: const Text('Это действие нельзя отменить',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Отмена', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<void> _deleteAlarm(String id) async {
    await _alarmService.deleteAlarm(id);
    await _loadAlarms();
  }

  Future<void> _editAlarm(AlarmModel alarm) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddAlarmScreen(alarm: alarm)),
    );
    if (changed == true) await _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final weekdays = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];
    final dateString =
        '${weekdays[now.weekday % 7]}, ${now.day} ${months[now.month - 1]}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка с текущим временем
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Заголовок секции
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Будильники',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_alarms.length} ${_alarms.length == 1 ? 'будильник' : _alarms.length < 5 ? 'будильника' : 'будильников'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Список будильников
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary))
                  : _alarms.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _alarms.length,
                          itemBuilder: (context, index) {
                            final alarm = _alarms[index];
                            return _buildAlarmCard(alarm);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddAlarmScreen()),
          );
          if (result == true || result == null) {
            await _loadAlarms();
          }
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет будильников',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите + чтобы добавить',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(AlarmModel alarm) {
    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      onDismissed: (_) => _deleteAlarm(alarm.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editAlarm(alarm),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Время
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alarm.timeString,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: alarm.enabled
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            alarm.title.isEmpty ? 'Будильник' : alarm.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: alarm.enabled
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  alarm.missionType.icon,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  alarm.missionType.displayName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alarm.repeatText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      if (alarm.daysOfWeek.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: DayOfWeek.values.map((day) {
                            final isActive = alarm.daysOfWeek.contains(day);
                            return Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.primary.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  day.shortName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? AppTheme.primary
                                        : Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                // Переключатель
                Switch(
                  value: alarm.enabled,
                  onChanged: (_) => _toggleAlarm(alarm.id),
                  activeColor: AppTheme.primary,
                  activeTrackColor: AppTheme.primary.withOpacity(0.3),
                  inactiveThumbColor: Colors.white.withOpacity(0.5),
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    super.dispose();
  }
}
