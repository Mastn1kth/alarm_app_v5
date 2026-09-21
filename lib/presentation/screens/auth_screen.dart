import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/alarm_entity.dart';
import '../../domain/services/user_service.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'package:alarm_app/presentation/theme/app_theme.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    final userService = UserService();
    await userService.initialize();
    final profile = userService.profile;
    setState(() {
      _isRegistered = profile != null && profile.name != 'Пользователь';
      _isLoading = false;
    });
  }

  void _onRegistrationComplete() {
    setState(() => _isRegistered = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    if (!_isRegistered) {
      return RegistrationScreen(onComplete: _onRegistrationComplete);
    }
    return const MainNavigationScreen();
  }
}

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const RegistrationScreen({super.key, required this.onComplete});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _pageController = PageController();
  int _currentPage = 0;
  String? _selectedAvatar;
  MissionType _preferredMission = MissionType.math;
  MissionDifficulty _preferredDifficulty = MissionDifficulty.medium;
  bool _isSubmitting = false;

  final List<String> _avatars = [
    '👤',
    '🦁',
    '🦊',
    '🐼',
    '🐨',
    '🐯',
    '🐷',
    '🐸',
    '🐙',
    '🦄'
  ];

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _completeRegistration() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    final userService = UserService();
    await userService.updateProfile(
      name: _nameController.text.trim(),
      avatarPath: _selectedAvatar,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_mission', _preferredMission.name);
    await prefs.setString('preferred_difficulty', _preferredDifficulty.name);
    setState(() => _isSubmitting = false);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primary
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNamePage(),
                  _buildAvatarPage(),
                  _buildMissionPreferencePage(),
                  _buildWelcomePage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Назад',
                          style: TextStyle(color: Colors.white70)),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed:
                        _currentPage == 3 ? _completeRegistration : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_currentPage == 3 ? 'Начать!' : 'Далее'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Как вас зовут?',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text('Это имя будет отображаться в вашем профиле',
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 18, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Введите ваше имя',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Выберите аватар',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text('Можно изменить позже в профиле',
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _avatars.map((avatar) {
              final isSelected = _selectedAvatar == avatar;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = avatar),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.3)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Center(
                      child:
                          Text(avatar, style: const TextStyle(fontSize: 40))),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionPreferencePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Предпочтения',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text('Выберите любимую миссию и сложность по умолчанию',
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 32),
          Text('Любимая миссия',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MissionType.values.map((type) {
              final isSelected = _preferredMission == type;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(type.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(type.displayName),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _preferredMission = type),
                backgroundColor: AppTheme.surface,
                selectedColor: AppTheme.primary.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.primary
                      : Colors.white.withOpacity(0.7),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Сложность по умолчанию',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MissionDifficulty.values.map((diff) {
              final isSelected = _preferredDifficulty == diff;
              return ChoiceChip(
                label: Text(diff.displayName),
                selected: isSelected,
                onSelected: (_) => setState(() => _preferredDifficulty = diff),
                backgroundColor: AppTheme.surface,
                selectedColor: diff.color.withOpacity(0.3),
                labelStyle: TextStyle(
                  color:
                      isSelected ? diff.color : Colors.white.withOpacity(0.7),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(_selectedAvatar ?? '👤',
                style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 24),
          Text(
            'Привет, ${_nameController.text.isNotEmpty ? _nameController.text : "друг"}!',
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Готовы просыпаться по-настоящему?\nВы выбрали миссию "${_preferredMission.displayName}" со сложностью "${_preferredDifficulty.displayName}".',
            style:
                TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _buildTipItem(
                    '🎯', 'Выполняйте миссии, чтобы отключить будильник'),
                const SizedBox(height: 12),
                _buildTipItem('🏆', 'Зарабатывайте XP и повышайте уровень'),
                const SizedBox(height: 12),
                _buildTipItem('🔥', 'Собирайте серии из ежедневных подъёмов'),
                const SizedBox(height: 12),
                _buildTipItem('⭐', 'Выполняйте ежедневные челленджи'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 14, color: Colors.white.withOpacity(0.7)))),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatisticsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(icon: Icons.alarm, label: 'Будильники'),
    NavigationItem(icon: Icons.bar_chart, label: 'Статистика'),
    NavigationItem(icon: Icons.person, label: 'Профиль'),
    NavigationItem(icon: Icons.settings, label: 'Настройки'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border:
              Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navigationItems.length, (index) {
                final item = _navigationItems[index];
                final isSelected = _currentIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon,
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.white.withOpacity(0.4),
                            size: 24),
                        const SizedBox(height: 4),
                        Text(item.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.white.withOpacity(0.4),
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  const NavigationItem({required this.icon, required this.label});
}
