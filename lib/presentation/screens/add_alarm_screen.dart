import 'package:flutter/material.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/services/alarm_service.dart';
import '../../core/di/injection_container.dart' as di;
import 'mission_selection_screen.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

class AddAlarmScreen extends StatefulWidget {
  final AlarmModel? alarm;

  const AddAlarmScreen({super.key, this.alarm});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  final _titleController = TextEditingController();
  final _alarmService = di.sl<AlarmService>();

  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _repeatDaily = false;
  List<DayOfWeek> _selectedDays = [];
  MissionType _selectedMission = MissionType.math;
  MissionDifficulty _selectedDifficulty = MissionDifficulty.medium;
  SoundPack _selectedSound = SoundPack.default_;
  double _volume = 1.0;
  bool _vibration = true;
  bool _snooze = true;
  int _snoozeMinutes = 5;

  bool get _isEditing => widget.alarm != null;

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    if (alarm == null) return;
    _titleController.text = alarm.title;
    _selectedTime = TimeOfDay(hour: alarm.hour, minute: alarm.minute);
    _repeatDaily = alarm.repeatDaily;
    _selectedDays = List.of(alarm.daysOfWeek);
    _selectedMission = alarm.missionType;
    _selectedDifficulty = alarm.missionDifficulty;
    _selectedSound = alarm.soundPack;
    _volume = alarm.soundVolume;
    _vibration = alarm.vibrationEnabled;
    _snooze = alarm.snoozeEnabled;
    _snoozeMinutes = alarm.snoozeMinutes;
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surface,
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white70,
              dialHandColor: AppTheme.primary,
              dialBackgroundColor: AppTheme.background,
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.white70,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectMission() async {
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => MissionSelectionScreen(
          selectedType: _selectedMission,
          selectedDifficulty: _selectedDifficulty,
          onMissionSelected: (type, difficulty) {
            Navigator.pop(context, {'type': type, 'difficulty': difficulty});
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMission = result['type'] as MissionType;
        _selectedDifficulty = result['difficulty'] as MissionDifficulty;
      });
    }
  }

  Future<void> _saveAlarm() async {
    if (_titleController.text.trim().isEmpty) {
      _titleController.text = 'Будильник';
    }

    final existing = widget.alarm;
    final alarm = AlarmModel(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      enabled: existing?.enabled ?? true,
      repeatDaily: _repeatDaily,
      daysOfWeek: _selectedDays,
      missionType: _selectedMission,
      missionDifficulty: _selectedDifficulty,
      soundPack: _selectedSound,
      soundVolume: _volume,
      vibrationEnabled: _vibration,
      snoozeEnabled: _snooze,
      snoozeMinutes: _snoozeMinutes,
      snoozeCount: existing?.snoozeCount ?? 0,
      maxSnoozeCount: existing?.maxSnoozeCount ?? 3,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      lastTriggeredAt: existing?.lastTriggeredAt,
      triggerCount: existing?.triggerCount ?? 0,
    );

    if (_isEditing) {
      await _alarmService.updateAlarm(alarm);
    } else {
      await _alarmService.addAlarm(alarm);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _toggleDay(DayOfWeek day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Редактировать будильник' : 'Новый будильник',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Время
            _buildSectionTitle('Время'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Название
            _buildSectionTitle('Название'),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Например: "Работа", "Тренировка"',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 32),

            // Повторение
            _buildSectionTitle('Повторение'),
            const SizedBox(height: 12),
            _buildOptionCard(
              icon: Icons.repeat,
              title: 'Каждый день',
              subtitle: 'Будильник будет активен каждый день',
              trailing: Switch(
                value: _repeatDaily,
                onChanged: (value) => setState(() => _repeatDaily = value),
                activeColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (!_repeatDaily) _buildDaysSelector(),
            const SizedBox(height: 32),

            // Миссия
            _buildSectionTitle('Миссия для отключения'),
            const SizedBox(height: 12),
            _buildMissionSelector(),
            const SizedBox(height: 32),

            // Звук
            _buildSectionTitle('Звук'),
            const SizedBox(height: 12),
            _buildSoundSelector(),
            const SizedBox(height: 12),
            _buildVolumeSlider(),
            const SizedBox(height: 12),
            _buildOptionCard(
              icon: Icons.vibration,
              title: 'Вибрация',
              subtitle: 'Вибрировать при срабатывании',
              trailing: Switch(
                value: _vibration,
                onChanged: (v) => setState(() => _vibration = v),
                activeColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Отложить
            _buildSectionTitle('Отложить'),
            const SizedBox(height: 12),
            _buildOptionCard(
              icon: Icons.snooze,
              title: 'Разрешить откладывать',
              subtitle: '$_snoozeMinutes минут',
              trailing: Switch(
                value: _snooze,
                onChanged: (v) => setState(() => _snooze = v),
                activeColor: AppTheme.primary,
              ),
            ),
            if (_snooze) ...[
              const SizedBox(height: 12),
              _buildSnoozeDurationSelector(),
            ],
            const SizedBox(height: 32),

            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAlarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Сохранить изменения' : 'Сохранить будильник',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.6),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildDaysSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: DayOfWeek.values.map((day) {
          final isSelected = _selectedDays.contains(day);
          return GestureDetector(
            onTap: () => _toggleDay(day),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  day.shortName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMissionSelector() {
    final mission = MissionFactory.createMission(_selectedMission);

    return GestureDetector(
      onTap: _selectMission,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(mission.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mission.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _selectedDifficulty.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _selectedDifficulty.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _selectedDifficulty.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Пакет звуков',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SoundPack.values.map((pack) {
              final isSelected = _selectedSound == pack;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(pack.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(pack.displayName),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedSound = pack),
                backgroundColor: AppTheme.surfaceVariant,
                selectedColor: AppTheme.primary.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.primary
                      : Colors.white.withOpacity(0.7),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Громкость',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                '${(_volume * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _volume,
            onChanged: (v) => setState(() => _volume = v),
            activeColor: AppTheme.primary,
            inactiveColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeDurationSelector() {
    final durations = [1, 3, 5, 10, 15, 20, 30];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: durations
            .map((minutes) => ChoiceChip(
                  label: Text('$minutes мин'),
                  selected: _snoozeMinutes == minutes,
                  onSelected: (_) => setState(() => _snoozeMinutes = minutes),
                  backgroundColor: AppTheme.surfaceVariant,
                  selectedColor: AppTheme.primary.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: _snoozeMinutes == minutes
                        ? AppTheme.primary
                        : Colors.white.withOpacity(0.7),
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
