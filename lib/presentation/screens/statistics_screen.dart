import 'package:flutter/material.dart';
import '../../domain/services/user_service.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

/// ==================== STATISTICS SCREEN ====================

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _userService.initialize();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final stats = _userService.statistics;
    final profile = _userService.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(stats, profile),
            const SizedBox(height: 24),
            _buildSuccessRate(stats),
            const SizedBox(height: 24),
            _buildMissionStats(stats),
            const SizedBox(height: 24),
            _buildAverageTime(stats),
            const SizedBox(height: 24),
            _buildWeeklyChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(dynamic stats, dynamic profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildSummaryCard(
          '🌅',
          'Всего подъёмов',
          '${stats?.totalWakeUps ?? 0}',
          AppTheme.success,
        ),
        _buildSummaryCard(
          '🔥',
          'Текущая серия',
          '${stats?.currentStreak ?? 0}',
          AppTheme.accent,
        ),
        _buildSummaryCard(
          '🏆',
          'Лучшая серия',
          '${stats?.bestStreak ?? 0}',
          AppTheme.warning,
        ),
        _buildSummaryCard(
          'вњ…',
          'Успешных',
          '${((stats?.successRate ?? 0) * 100).toInt()}%',
          AppTheme.primary,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRate(dynamic stats) {
    final rate = stats?.successRate ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Успешные подъёмы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: rate,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(
                        rate > 0.7
                            ? AppTheme.success
                            : rate > 0.4
                                ? AppTheme.warning
                                : AppTheme.accent,
                      ),
                      strokeWidth: 8,
                    ),
                    Center(
                      child: Text(
                        '${(rate * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRateDetail('Без откладывания',
                        '${stats?.totalWakeUps ?? 0 - stats?.totalSnoozes ?? 0}'),
                    const SizedBox(height: 8),
                    _buildRateDetail(
                        'С откладыванием', '${stats?.totalSnoozes ?? 0}'),
                    const SizedBox(height: 8),
                    _buildRateDetail(
                        'Пропущено', '${stats?.totalDismissals ?? 0}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionStats(dynamic stats) {
    final missionCounts = stats?.missionTypeCounts ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выполненные миссии',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (missionCounts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Пока нет данных о миссиях',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            )
          else
            ...missionCounts.entries
                .map((entry) => _buildMissionBar(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildMissionBar(String type, int count) {
    final total = _userService.statistics?.totalWakeUps ?? 1;
    final percent = count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageTime(dynamic stats) {
    final avgTime = stats?.averageDismissTime;
    final seconds = avgTime?.inSeconds ?? 0;
    final minutes = avgTime?.inMinutes ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.timer,
              size: 32,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Среднее время отключения',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  avgTime != null
                      ? minutes > 0
                          ? '$minutes мин ${seconds % 60} сек'
                          : '$seconds сек'
                      : 'Нет данных',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // TODO: Реализовать график подъёмов по дням недели
    // Можно использовать fl_chart или charts_flutter

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Активность за неделю',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                .map((day) => _buildDayColumn(day))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day) {
    // TODO: Загрузить реальные данные из wakeUpHistory
    final isToday = day == 'Вт'; // Пример
    final hasData = day == 'Пн' || day == 'Вт' || day == 'Ср'; // Пример

    return Column(
      children: [
        Container(
          width: 36,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 36,
              height: hasData ? 60 : 0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppTheme.primary : Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
