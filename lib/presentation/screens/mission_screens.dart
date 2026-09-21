import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/services/math_problem_generator.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

/// ==================== MISSION ROUTER ====================

class MissionScreen extends StatelessWidget {
  final MissionType missionType;
  final MissionDifficulty difficulty;

  const MissionScreen({
    super.key,
    required this.missionType,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    switch (missionType) {
      case MissionType.math:
        return MathMissionScreen(difficulty: difficulty);
      case MissionType.holdButton:
        return HoldButtonMissionScreen(difficulty: difficulty);
      case MissionType.steps:
        return StepsMissionScreen(difficulty: difficulty);
      case MissionType.memory:
        return MemoryMissionScreen(difficulty: difficulty);
      case MissionType.typing:
        return TypingMissionScreen(difficulty: difficulty);
      case MissionType.shakePhone:
        return ShakePhoneMissionScreen(difficulty: difficulty);
      case MissionType.sequence:
        return SequenceMissionScreen(difficulty: difficulty);
      case MissionType.captcha:
        return CaptchaMissionScreen(difficulty: difficulty);
    }
  }
}

/// ==================== MATH MISSION (5 уровней, 4 типа задач) ====================

class MathMissionScreen extends StatefulWidget {
  final MissionDifficulty difficulty;

  const MathMissionScreen({super.key, required this.difficulty});

  @override
  State<MathMissionScreen> createState() => _MathMissionScreenState();
}

class _MathMissionScreenState extends State<MathMissionScreen> {
  late MissionDifficulty _difficulty;
  List<MathTask> _problems = [];
  final List<TextEditingController> _controllers = [];
  final List<bool?> _results = [];
  int _currentIndex = 0;
  bool _allSolved = false;
  bool _showDifficultySelector = false;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _generateProblems();
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  void _startMission() {
    setState(() {
      _showDifficultySelector = false;
      _generateProblems();
    });
  }

  void _generateProblems() {
    final count = MathProblemGenerator.getProblemCount(_difficulty);
    _problems = [];
    _controllers.clear();
    _results.clear();
    _currentIndex = 0;
    _allSolved = false;
    for (int i = 0; i < count; i++) {
      _problems.add(MathProblemGenerator.generate(_difficulty));
      _controllers.add(TextEditingController());
      _results.add(null);
    }
  }

  void _checkAnswer() {
    final controller = _controllers[_currentIndex];
    final answer = int.tryParse(controller.text.trim());
    if (answer == null) return;

    setState(() {
      final correct = _problems[_currentIndex].validate(answer);
      _results[_currentIndex] = correct;
      if (correct) {
        if (_currentIndex < _problems.length - 1) {
          _currentIndex++;
        } else {
          _allSolved = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _showDifficultySelector
                ? _buildDifficultySelector()
                : _buildMissionContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Математика',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 8),
        Text('Выберите уровень сложности',
            style:
                TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6))),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: MissionDifficulty.values.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final diff = MissionDifficulty.values[index];
              final isSelected = _difficulty == diff;
              final count = MathProblemGenerator.getProblemCount(diff);
              return GestureDetector(
                onTap: () => setState(() => _difficulty = diff),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? diff.color.withOpacity(0.15)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: diff.color, width: 2)
                        : null,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(diff.icon, color: diff.color, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(diff.displayName,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? diff.color
                                        : Colors.white)),
                            const SizedBox(height: 4),
                            Text(diff.description,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.5))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildChip('$count задач', diff.color),
                                const SizedBox(width: 8),
                                _buildChip(
                                    diff == MissionDifficulty.beginner
                                        ? '+ -'
                                        : diff == MissionDifficulty.extreme
                                            ? '+ - Г— Г·'
                                            : '+ - Г—',
                                    diff.color),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: diff.color, size: 28),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startMission,
            style: ElevatedButton.styleFrom(
              backgroundColor: _difficulty.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Начать (${_difficulty.displayName})',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMissionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(_problems.length, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 4,
                decoration: BoxDecoration(
                  color: _results[index] == true
                      ? AppTheme.success
                      : index == _currentIndex
                          ? AppTheme.primary
                          : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: _difficulty.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_difficulty.icon, size: 14, color: _difficulty.color),
                  const SizedBox(width: 6),
                  Text(_difficulty.displayName,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _difficulty.color)),
                ],
              ),
            ),
            Text(
              '${_currentIndex + 1} из ${_problems.length}',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!_allSolved) ...[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      _problems[_currentIndex].question,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _problems[_currentIndex].hint,
                    style: TextStyle(
                        fontSize: 13, color: Colors.white.withOpacity(0.4)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controllers[_currentIndex],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ваш ответ',
                      hintStyle: TextStyle(
                          fontSize: 24, color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(24),
                      errorText: _results[_currentIndex] == false
                          ? 'Неверно, попробуйте ещё раз'
                          : null,
                      errorStyle: const TextStyle(
                          color: Colors.redAccent, fontSize: 14),
                    ),
                    onSubmitted: (_) => _checkAnswer(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Проверить',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ] else ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.2),
                shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 64, color: AppTheme.success),
          ),
          const SizedBox(height: 24),
          const Text('Отлично!',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text('Все ${_problems.length} примеров решены верно',
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.6))),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Отключить будильник',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ],
    );
  }
}

/// ==================== HOLD BUTTON MISSION (FULL) ====================

class HoldButtonMissionScreen extends StatefulWidget {
  final MissionDifficulty difficulty;

  const HoldButtonMissionScreen({super.key, required this.difficulty});

  @override
  State<HoldButtonMissionScreen> createState() =>
      _HoldButtonMissionScreenState();
}

class _HoldButtonMissionScreenState extends State<HoldButtonMissionScreen> {
  bool _isHolding = false;
  double _progress = 0.0;
  Timer? _timer;
  bool _completed = false;
  int get _holdDuration => widget.difficulty.holdDurationSeconds;

  void _startHolding() {
    setState(() => _isHolding = true);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.1 / _holdDuration;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _completed = true;
          _isHolding = false;
          timer.cancel();
        }
      });
    });
  }

  void _stopHolding() {
    _timer?.cancel();
    setState(() {
      _isHolding = false;
      if (!_completed) _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_completed) ...[
                  Text('Удерживайте кнопку',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 8),
                  Text('$_holdDuration секунд',
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w200,
                          color: Colors.white)),
                  const SizedBox(height: 48),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                          decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(4))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${(_progress * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.5))),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTapDown: (_) => _startHolding(),
                    onTapUp: (_) => _stopHolding(),
                    onTapCancel: () => _stopHolding(),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isHolding ? AppTheme.primary : AppTheme.surface,
                        border: Border.all(color: AppTheme.primary, width: 4),
                        boxShadow: _isHolding
                            ? [
                                BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.5),
                                    blurRadius: 40,
                                    spreadRadius: 10)
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Icon(
                            _isHolding ? Icons.touch_app : Icons.pan_tool_alt,
                            size: 64,
                            color:
                                _isHolding ? Colors.white : AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(_isHolding ? 'Удерживайте...' : 'Нажмите и удерживайте',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.6))),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        size: 64, color: AppTheme.success),
                  ),
                  const SizedBox(height: 24),
                  const Text('Готово!',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Вы удерживали кнопку $_holdDuration секунд',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Отключить будильник',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// ==================== MEMORY MISSION (FULL) ====================

class MemoryMissionScreen extends StatefulWidget {
  final MissionDifficulty difficulty;

  const MemoryMissionScreen({super.key, required this.difficulty});

  @override
  State<MemoryMissionScreen> createState() => _MemoryMissionScreenState();
}

class _MemoryMissionScreenState extends State<MemoryMissionScreen> {
  late List<String> _sequence;
  late List<String> _userSequence;
  bool _showingSequence = true;
  int _currentIndex = 0;
  bool _completed = false;
  bool _failed = false;
  late int _sequenceLength;
  Timer? _showTimer;

  final List<String> _symbols = ['🔴', '🟢', '🔵', '🟡', '🟣', '🟠'];

  @override
  void initState() {
    super.initState();
    _sequenceLength = widget.difficulty.memorySequenceLength;
    _generateSequence();
  }

  void _generateSequence() {
    final random = Random();
    _sequence = List.generate(
        _sequenceLength, (_) => _symbols[random.nextInt(_symbols.length)]);
    _userSequence = [];
    _currentIndex = 0;
    _showingSequence = true;
    _completed = false;
    _failed = false;

    // Показываем последовательность с задержкой
    _startShowSequence();
  }

  void _startShowSequence() {
    _showTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _currentIndex++;
        if (_currentIndex >= _sequence.length) {
          timer.cancel();
          _showingSequence = false;
          _currentIndex = 0;
        }
      });
    });
  }

  void _onSymbolTap(String symbol) {
    if (_showingSequence || _completed || _failed) return;

    setState(() {
      _userSequence.add(symbol);

      if (_userSequence[_userSequence.length - 1] !=
          _sequence[_userSequence.length - 1]) {
        _failed = true;
        return;
      }

      if (_userSequence.length == _sequence.length) {
        _completed = true;
      }
    });
  }

  void _retry() {
    setState(() {
      _generateSequence();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  _showingSequence
                      ? 'Запомните последовательность'
                      : 'Повторите последовательность',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _showingSequence
                      ? '${_currentIndex + 1} / ${_sequence.length}'
                      : '${_userSequence.length} / ${_sequence.length}',
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.5)),
                ),
                const SizedBox(height: 32),

                // Отображение последовательности
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(_sequence.length, (index) {
                    final isVisible = _showingSequence
                        ? index <= _currentIndex
                        : index < _userSequence.length;
                    final isCorrect =
                        !_showingSequence && index < _userSequence.length
                            ? _userSequence[index] == _sequence[index]
                            : true;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isVisible
                            ? (isCorrect
                                ? AppTheme.surface
                                : Colors.red.withOpacity(0.3))
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isVisible
                              ? (isCorrect ? AppTheme.primary : Colors.red)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isVisible ? _sequence[index] : '?',
                          style: TextStyle(
                            fontSize: 28,
                            color: isVisible
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const Spacer(),

                if (_completed) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        size: 64, color: AppTheme.success),
                  ),
                  const SizedBox(height: 24),
                  const Text('Память отличная!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Отключить будильник',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ] else if (_failed) ...[
                  const Icon(Icons.close, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text('Неправильно!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent)),
                  const SizedBox(height: 8),
                  Text('Попробуйте ещё раз',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Попробовать снова',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ] else if (!_showingSequence) ...[
                  // Кнопки символов для ввода
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: _symbols
                        .map((symbol) => GestureDetector(
                              onTap: () => _onSymbolTap(symbol),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppTheme.primary.withOpacity(0.3),
                                      width: 2),
                                ),
                                child: Center(
                                    child: Text(symbol,
                                        style: const TextStyle(fontSize: 36))),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    super.dispose();
  }
}

/// ==================== TYPING MISSION (FULL) ====================

class TypingMissionScreen extends StatefulWidget {
  final MissionDifficulty difficulty;

  const TypingMissionScreen({super.key, required this.difficulty});

  @override
  State<TypingMissionScreen> createState() => _TypingMissionScreenState();
}

class _TypingMissionScreenState extends State<TypingMissionScreen> {
  late String _targetPhrase;
  final TextEditingController _controller = TextEditingController();
  bool _completed = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _attempts = 0;
  DateTime? _startTime;

  final List<String> _phrases = [
    'Утро начинается с кофе',
    'Сегодня будет отличный день',
    'Я просыпаюсь бодрым',
    'Солнце светит ярко',
    'Новый день новые возможности',
    'Я готов к новым свершениям',
    'Проснись и пой',
    'Утренняя зарядка бодрит',
    'Свежий воздух бодрит',
    'Каждый день это подарок',
  ];

  @override
  void initState() {
    super.initState();
    _generatePhrase();
  }

  void _generatePhrase() {
    final random = Random();
    final phrase = _phrases[random.nextInt(_phrases.length)];
    final repetitions = switch (widget.difficulty) {
      MissionDifficulty.beginner => 1,
      MissionDifficulty.easy => 1,
      MissionDifficulty.medium => 1,
      MissionDifficulty.hard => 2,
      MissionDifficulty.extreme => 3,
    };
    _targetPhrase = List.filled(repetitions, phrase).join(' ');
    _controller.clear();
    _completed = false;
    _hasError = false;
    _errorMessage = '';
    _startTime = DateTime.now();
  }

  void _checkPhrase() {
    final userText = _controller.text.trim();

    if (userText == _targetPhrase) {
      setState(() {
        _completed = true;
        _hasError = false;
      });
    } else {
      setState(() {
        _hasError = true;
        _attempts++;

        if (userText.length != _targetPhrase.length) {
          _errorMessage =
              'Длина не совпадает (${userText.length} vs ${_targetPhrase.length})';
        } else {
          // Находим первое несовпадение
          for (int i = 0; i < userText.length; i++) {
            if (userText[i] != _targetPhrase[i]) {
              _errorMessage =
                  'Ошибка в позиции ${i + 1}: "${userText[i]}" вместо "${_targetPhrase[i]}"';
              break;
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Наберите фразу без ошибок',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Попытка ${_attempts + 1}',
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.5)),
                ),
                const SizedBox(height: 32),

                // Целевая фраза
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Фраза для набора:',
                        style: TextStyle(
                            fontSize: 14, color: Colors.white.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _targetPhrase,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (!_completed) ...[
                  TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Начните набирать здесь...',
                      hintStyle: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      errorText: _hasError ? _errorMessage : null,
                      errorStyle: const TextStyle(
                          color: Colors.redAccent, fontSize: 14),
                    ),
                    onChanged: (_) {
                      if (_hasError) {
                        setState(() => _hasError = false);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkPhrase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Проверить',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        size: 64, color: AppTheme.success),
                  ),
                  const SizedBox(height: 24),
                  const Text('Безупречно!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    'Фраза набрана без ошибок',
                    style: TextStyle(
                        fontSize: 16, color: Colors.white.withOpacity(0.6)),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Отключить будильник',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// ==================== SHAKE MISSION (ARCHITECTURE) ====================

class ShakePhoneMissionScreen extends StatefulWidget {
  final MissionDifficulty difficulty;

  const ShakePhoneMissionScreen({super.key, required this.difficulty});

  @override
  State<ShakePhoneMissionScreen> createState() =>
      _ShakePhoneMissionScreenState();
}

class _ShakePhoneMissionScreenState extends State<ShakePhoneMissionScreen> {
  int _shakeCount = 0;
  int get _targetShakes => widget.difficulty.shakeTarget;
  bool _completed = false;
  StreamSubscription? _accelerometerSubscription;
  double _lastMagnitude = 0;
  DateTime? _lastShakeTime;
  bool _accelerometerAvailable = true;

  @override
  void initState() {
    super.initState();
    _initAccelerometer();
  }

  void _initAccelerometer() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen((event) {
        final magnitude =
            sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

        if (_lastShakeTime != null) {
          final timeDiff = DateTime.now().difference(_lastShakeTime!);
          if (timeDiff.inMilliseconds < 200) return;
        }

        if ((magnitude - _lastMagnitude).abs() > 12) {
          setState(() {
            _shakeCount++;
            _lastShakeTime = DateTime.now();
            if (_shakeCount >= _targetShakes) {
              _completed = true;
            }
          });
        }

        _lastMagnitude = magnitude;
      });
    } catch (e) {
      setState(() => _accelerometerAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.vibration,
                    size: 64,
                    color: _shakeCount > 0
                        ? AppTheme.primary
                        : Colors.white.withOpacity(0.3)),
                const SizedBox(height: 24),
                Text(
                  'Встряхните телефон',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_shakeCount / $_targetShakes',
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w200,
                      color: Colors.white),
                ),
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _targetShakes > 0
                        ? (_shakeCount / _targetShakes).clamp(0.0, 1.0)
                        : 0,
                    child: Container(
                        decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(4))),
                  ),
                ),
                if (!_accelerometerAvailable) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Акселерометр недоступен. Эта миссия не поддерживается устройством.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                ],
                if (_completed) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        size: 64, color: AppTheme.success),
                  ),
                  const SizedBox(height: 24),
                  const Text('Готово!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Отключить будильник',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }
}

/// ==================== QR MISSION (ARCHITECTURE) ====================

/// ==================== SEQUENCE MISSION (FULL) ====================

class SequenceMissionScreen extends StatefulWidget {
  final MissionDifficulty difficulty;

  const SequenceMissionScreen({super.key, required this.difficulty});

  @override
  State<SequenceMissionScreen> createState() => _SequenceMissionScreenState();
}

class _SequenceMissionScreenState extends State<SequenceMissionScreen>
    with SingleTickerProviderStateMixin {
  final List<Color> _buttonColors = const [
    AppTheme.missionRed,
    AppTheme.missionTeal,
    AppTheme.missionYellow,
    AppTheme.primary,
  ];

  final List<String> _buttonLabels = ['A', 'B', 'C', 'D'];

  late AnimationController _animController;

  List<int> _sequence = [];
  int _playerIndex = 0;
  int _round = 0;
  int _highlightedIndex = -1;

  bool _showingSequence = false;
  bool _playerTurn = false;
  bool _completed = false;
  bool _failed = false;

  int get _maxRounds => widget.difficulty.sequenceRounds;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _startRound();
  }

  void _startRound() {
    setState(() {
      _sequence.add(_randomButton());
      _playerIndex = 0;
      _showingSequence = true;
      _playerTurn = false;
      _completed = false;
      _failed = false;
    });
    _showSequence();
  }

  int _randomButton() => Random().nextInt(_buttonColors.length);

  Future<void> _showSequence() async {
    for (int i = 0; i < _sequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _highlightedIndex = _sequence[i]);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() => _highlightedIndex = -1);
    }
    if (!mounted) return;
    setState(() {
      _showingSequence = false;
      _playerTurn = true;
    });
  }

  void _onButtonTap(int index) {
    if (!_playerTurn || _completed || _failed) return;

    setState(() => _highlightedIndex = index);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _highlightedIndex = -1);
    });

    if (index != _sequence[_playerIndex]) {
      setState(() => _failed = true);
      return;
    }

    _playerIndex++;
    if (_playerIndex >= _sequence.length) {
      _round++;
      if (_round >= _maxRounds) {
        setState(() => _completed = true);
      } else {
        Future.delayed(const Duration(milliseconds: 500), _startRound);
      }
    }
  }

  void _retry() {
    setState(() {
      _sequence.clear();
      _round = 0;
    });
    _startRound();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  _completed
                      ? 'Последовательность пройдена!'
                      : 'Повторите последовательность',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _completed
                      ? '$_maxRounds раундов'
                      : 'Раунд ${_round + 1} / $_maxRounds',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                if (!_completed) ...[
                  LinearProgressIndicator(
                    value: _round / _maxRounds,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    shrinkWrap: true,
                    childAspectRatio: 1.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(4, (index) {
                      final isHighlighted = _highlightedIndex == index;
                      return GestureDetector(
                        onTap: () => _onButtonTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _playerTurn
                                ? (isHighlighted
                                    ? _buttonColors[index]
                                    : _buttonColors[index].withOpacity(0.4))
                                : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _playerTurn
                                  ? _buttonColors[index].withOpacity(0.6)
                                  : Colors.white.withOpacity(0.1),
                              width: 3,
                            ),
                            boxShadow: isHighlighted && _playerTurn
                                ? [
                                    BoxShadow(
                                      color:
                                          _buttonColors[index].withOpacity(0.5),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              _buttonLabels[index],
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _showingSequence
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (_failed) ...[
                  const Icon(Icons.close, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  const Text(
                    'Неверно!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Начать заново',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
                if (_completed) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        size: 64, color: AppTheme.success),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Отличная память!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Отключить будильник',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}

/// ==================== CAPTCHA MISSION (FULL) ====================

class CaptchaMissionScreen extends StatefulWidget {
  final MissionDifficulty difficulty;

  const CaptchaMissionScreen({super.key, required this.difficulty});

  @override
  State<CaptchaMissionScreen> createState() => _CaptchaMissionScreenState();
}

class _CaptchaMissionScreenState extends State<CaptchaMissionScreen> {
  late CaptchaChallenge _challenge;
  final Set<int> _selectedIndices = {};
  bool _completed = false;
  bool _wrong = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _challenge = CaptchaChallenge.generate(widget.difficulty);
  }

  void _toggleTile(int index) {
    if (_completed) return;
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _wrong = false;
    });
  }

  void _submit() {
    final correct = _challenge.checkAnswer(_selectedIndices);
    if (correct) {
      setState(() => _completed = true);
    } else {
      setState(() {
        _wrong = true;
        _attempts++;
        _selectedIndices.clear();
      });
    }
  }

  void _regenerate() {
    setState(() {
      _challenge = CaptchaChallenge.generate(widget.difficulty);
      _selectedIndices.clear();
      _completed = false;
      _wrong = false;
      _attempts = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _completed
                      ? 'Капча пройдена!'
                      : 'Выберите все ${_challenge.instruction}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _challenge.hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                if (_wrong)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Попробуйте ещё раз (попытка $_attempts)',
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(_challenge.tiles.length, (index) {
                      final tile = _challenge.tiles[index];
                      final isSelected = _selectedIndices.contains(index);
                      return GestureDetector(
                        onTap: () => _toggleTile(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withOpacity(0.3)
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.white.withOpacity(0.08),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(tile,
                                style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (!_completed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedIndices.isEmpty ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Подтвердить',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _regenerate,
                      child: Text(
                        'Новая задача',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        size: 64, color: AppTheme.success),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Капча решена!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Отключить будильник',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CaptchaChallenge {
  final List<String> tiles;
  final String instruction;
  final String hint;
  final Set<int> _correctIndices;

  CaptchaChallenge._({
    required this.tiles,
    required this.instruction,
    required this.hint,
    required Set<int> correctIndices,
  }) : _correctIndices = correctIndices;

  bool checkAnswer(Set<int> selected) {
    if (selected.length != _correctIndices.length) return false;
    return selected.containsAll(_correctIndices);
  }

  static CaptchaChallenge generate(MissionDifficulty difficulty) {
    final random = Random();

    final categories = [
      {
        'instruction': 'фрукты',
        'items': ['🍎', '🍊', '🍋', '🍇', '🍓', '🍑', '🍒', '🍌'],
        'distractors': ['🥕', '🥦', '🍄', '🌽', '🥬', '🧅', '🥩', '🧀'],
      },
      {
        'instruction': 'животных',
        'items': ['🐶', '🐱', '🐼', '🐨', '🦊', '🐯', '🐸', '🐙'],
        'distractors': ['🌈', '⭐', '🌙', '☀️', '⛅', '❄️', '🔥', '💧'],
      },
      {
        'instruction': 'транспорт',
        'items': ['🚗', '🚌', '🚲', '✈️', '🚢', '🚁', '🚂', '🛴'],
        'distractors': ['🏠', '🏢', '⛪', '🏫', '🏥', '🏪', '🌲', '⛰️'],
      },
      {
        'instruction': 'спортивные мячи',
        'items': ['⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏓', '🥎'],
        'distractors': ['🎸', '🎺', '🎻', '🥁', '🎹', '🎤', '🎧', '🎷'],
      },
    ];

    final category = categories[random.nextInt(categories.length)];
    final items = (category['items'] as List<String>);
    final distractors = (category['distractors'] as List<String>);

    final correctCount = difficulty.requiredCount.clamp(2, 6);
    final shuffledItems = [...items]..shuffle(random);
    final selectedCorrect = shuffledItems.take(correctCount).toList();

    final gridSize = switch (difficulty) {
      MissionDifficulty.beginner => 6,
      MissionDifficulty.easy => 9,
      MissionDifficulty.medium => 9,
      MissionDifficulty.hard => 12,
      MissionDifficulty.extreme => 12,
    };
    final distractorCount = gridSize - correctCount;
    final shuffledDistractors = [...distractors]..shuffle(random);
    final selectedDistractors =
        shuffledDistractors.take(distractorCount).toList();

    final allTiles = [...selectedCorrect, ...selectedDistractors]
      ..shuffle(random);

    final correctSet = <int>{};
    for (int i = 0; i < allTiles.length; i++) {
      if (selectedCorrect.contains(allTiles[i])) {
        correctSet.add(i);
      }
    }

    return CaptchaChallenge._(
      tiles: allTiles,
      instruction: '${category['instruction']}',
      hint:
          'Нажмите на ${category['instruction']}, затем нажмите "Подтвердить"',
      correctIndices: correctSet,
    );
  }
}

/// ==================== STEPS MISSION (FULL) ====================

class StepsMissionScreen extends StatefulWidget {
  final MissionDifficulty difficulty;

  const StepsMissionScreen({super.key, required this.difficulty});

  @override
  State<StepsMissionScreen> createState() => _StepsMissionScreenState();
}

class _StepsMissionScreenState extends State<StepsMissionScreen>
    with SingleTickerProviderStateMixin {
  static const EventChannel _stepChannel =
      EventChannel('com.alarmapp.alarm_app/steps');

  int _steps = 0;
  late int _targetSteps;
  bool _completed = false;
  bool _sensorAvailable = true;
  StreamSubscription<dynamic>? _stepSubscription;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _targetSteps = widget.difficulty.stepTarget;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _stepSubscription = _stepChannel.receiveBroadcastStream().listen(
      (_) => _onStep(),
      onError: (_) {
        if (mounted) setState(() => _sensorAvailable = false);
      },
    );
  }

  void _onStep() {
    if (_completed || !_sensorAvailable) return;
    setState(() {
      _steps++;
      if (_steps >= _targetSteps) {
        _completed = true;
      }
    });
    _pulseController.forward().then((_) => _pulseController.reverse());
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_steps / _targetSteps).clamp(0.0, 1.0);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                Text(
                  'Шаги',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_targetSteps шагов для отключения',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 40),

                // Круглый счётчик шагов
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surface,
                      border: Border.all(
                        color: _completed
                            ? AppTheme.success
                            : AppTheme.primary.withOpacity(0.5),
                        width: 6,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_steps',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w200,
                              color:
                                  _completed ? AppTheme.success : Colors.white,
                            ),
                          ),
                          Text(
                            '$_targetSteps',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Прогресс-бар
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _completed ? AppTheme.success : AppTheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),

                const Spacer(flex: 2),

                if (!_completed) ...[
                  Icon(
                    _sensorAvailable
                        ? Icons.directions_walk
                        : Icons.sensors_off,
                    size: 72,
                    color:
                        _sensorAvailable ? AppTheme.primary : Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _sensorAvailable
                        ? 'Идите с телефоном в руке.\nШаги считаются датчиком движения.'
                        : 'Датчик движения недоступен на этом устройстве.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        size: 64, color: AppTheme.success),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Цель достигнута!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_steps шагов сделано',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Отключить будильник',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }
}
