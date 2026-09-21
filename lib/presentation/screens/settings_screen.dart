import 'package:flutter/material.dart';
import '../../domain/services/user_service.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

/// ==================== SETTINGS SCREEN ====================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  // Настройки (пока в памяти, TODO: сохранять в SharedPreferences)
  double _soundVolume = 0.8;
  bool _vibrationEnabled = true;
  bool _snoozeEnabled = true;
  int _snoozeMinutes = 5;
  bool _darkTheme = true;
  String _language = 'ru';
  bool _notificationsEnabled = true;
  bool _gradualVolume = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader('Звук'),
          _buildVolumeSlider(),
          _buildSwitchTile(
            icon: Icons.vibration,
            title: 'Вибрация',
            subtitle: 'Вибрировать при срабатывании',
            value: _vibrationEnabled,
            onChanged: (v) => setState(() => _vibrationEnabled = v),
          ),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: 'Плавное увеличение громкости',
            subtitle: 'Громкость растёт постепенно',
            value: _gradualVolume,
            onChanged: (v) => setState(() => _gradualVolume = v),
          ),
          _buildSectionHeader('Отложить'),
          _buildSwitchTile(
            icon: Icons.snooze,
            title: 'Разрешить откладывать',
            subtitle: 'Включить кнопку "Отложить"',
            value: _snoozeEnabled,
            onChanged: (v) => setState(() => _snoozeEnabled = v),
          ),
          if (_snoozeEnabled) _buildSnoozeDurationSelector(),
          _buildSectionHeader('Внешний вид'),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Тёмная тема',
            subtitle: 'Использовать тёмное оформление',
            value: _darkTheme,
            onChanged: (v) => setState(() => _darkTheme = v),
          ),
          _buildSectionHeader('Язык'),
          _buildLanguageSelector(),
          _buildSectionHeader('Уведомления'),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Уведомления',
            subtitle: 'Показывать уведомления о будильниках',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          _buildSectionHeader('О приложении'),
          _buildAboutTile(),
          const SizedBox(height: 32),
          _buildDangerZone(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              const Icon(Icons.volume_up, color: AppTheme.primary, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Громкость будильника',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${(_soundVolume * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _soundVolume,
            onChanged: (v) => setState(() => _soundVolume = v),
            activeColor: AppTheme.primary,
            inactiveColor: Colors.white.withOpacity(0.1),
            divisions: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
          activeTrackColor: AppTheme.primary.withOpacity(0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSnoozeDurationSelector() {
    final durations = [1, 3, 5, 10, 15, 20, 30];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Интервал откладывания',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: durations
                .map((minutes) => _buildDurationChip(minutes))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(int minutes) {
    final isSelected = _snoozeMinutes == minutes;

    return ChoiceChip(
      label: Text('$minutes мин'),
      selected: isSelected,
      onSelected: (_) => setState(() => _snoozeMinutes = minutes),
      backgroundColor: AppTheme.surfaceVariant,
      selectedColor: AppTheme.primary.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.7),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final languages = [
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: languages
            .map((lang) => RadioListTile<String>(
                  title: Row(
                    children: [
                      Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        lang['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  value: lang['code']!,
                  groupValue: _language,
                  onChanged: (v) => setState(() => _language = v!),
                  activeColor: AppTheme.primary,
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppTheme.primary;
                    }
                    return Colors.white.withOpacity(0.3);
                  }),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAboutTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info, color: AppTheme.primary, size: 20),
            ),
            title: const Text(
              'Версия',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            trailing: const Text(
              '1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.code, color: AppTheme.success, size: 20),
            ),
            title: const Text(
              'Разработчик',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            trailing: const Text(
              'Alarm App Team',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppTheme.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Опасная зона',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.error.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(),
              icon: const Icon(Icons.delete_forever, color: AppTheme.error),
              label: const Text(
                'Сбросить все данные',
                style: TextStyle(color: AppTheme.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Сбросить все данные?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Это удалит все будильники, статистику, достижения и прогресс. Действие нельзя отменить.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Отмена', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Реализовать сброс данных
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Данные сброшены'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            child:
                const Text('Сбросить', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
