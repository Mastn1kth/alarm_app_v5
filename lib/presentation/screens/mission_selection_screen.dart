import 'package:flutter/material.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/entities/mission_entity.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

/// ==================== MISSION SELECTION SCREEN ====================

class MissionSelectionScreen extends StatelessWidget {
  final MissionType? selectedType;
  final MissionDifficulty? selectedDifficulty;
  final Function(MissionType, MissionDifficulty)? onMissionSelected;

  const MissionSelectionScreen({
    super.key,
    this.selectedType,
    this.selectedDifficulty,
    this.onMissionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final missions = MissionFactory.getAllMissions();
    final availableMissions = MissionFactory.getAvailableMissions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор миссии'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          ...missions.map((mission) => _buildMissionCard(context, mission,
              availableMissions.any((m) => m.type == mission.type))),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Миссии для пробуждения',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите задание, которое поможет вам проснуться. Чем сложнее миссия, тем лучше результат.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(
      BuildContext context, Mission mission, bool isAvailable) {
    final isSelected = selectedType == mission.type;
    final difficulty = selectedDifficulty ?? mission.difficulty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isSelected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            isSelected ? Border.all(color: AppTheme.primary, width: 2) : null,
      ),
      child: InkWell(
        onTap: isAvailable
            ? () => _showDifficultySelector(context, mission)
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppTheme.primary.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      mission.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mission.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isAvailable
                                ? Colors.white.withOpacity(0.6)
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'SOON',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    )
                  else if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                ],
              ),
              if (isAvailable) ...[
                const SizedBox(height: 16),
                _buildDifficultyRow(mission, difficulty),
                const SizedBox(height: 12),
                _buildRecommendations(mission.recommendations),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyRow(Mission mission, MissionDifficulty difficulty) {
    return Row(
      children: MissionDifficulty.values.map((diff) {
        final isSelected = diff == difficulty;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? diff.color.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border:
                  isSelected ? Border.all(color: diff.color, width: 1.5) : null,
            ),
            child: Column(
              children: [
                Text(
                  diff.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? diff.color : Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${diff.requiredCount}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? diff.color : Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendations(List<String> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Рекомендации:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: AppTheme.success.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _showDifficultySelector(BuildContext context, Mission mission) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(mission.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  mission.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mission.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Выберите сложность:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            ...MissionDifficulty.values
                .map((diff) => _buildDifficultyOption(context, mission, diff)),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(
      BuildContext context, Mission mission, MissionDifficulty diff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onMissionSelected?.call(mission.type, diff);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: diff.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: diff.color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: diff.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diff.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: diff.color,
                      ),
                    ),
                    Text(
                      diff.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${diff.requiredCount}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: diff.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
