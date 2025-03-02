import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/tutorial_manager.dart';
import '../widgets/app_tooltip.dart';

/// 앱 설정 화면
/// 앱의 다양한 설정을 관리할 수 있는 화면입니다.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useOpenAI = false;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  
  // 디버깅을 위한 출력
  void _debugPrint(String message) {
    debugPrint('⚙️ SettingsScreen: $message');
  }
  
  final GlobalKey _tutorialKey = GlobalKey();
  final GlobalKey _openAIKey = GlobalKey();
  final GlobalKey _notificationKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 설정 로드
    _loadSettings();
  }
  
  /// 저장된 설정 로드
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _useOpenAI = prefs.getBool('use_openai') ?? false;
        _soundEnabled = prefs.getBool('sound_enabled') ?? true;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      });
      _debugPrint('설정 로드 완료');
    } catch (e) {
      _debugPrint('설정 로드 중 오류 발생: $e');
    }
  }
  
  /// 설정 저장
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_openai', _useOpenAI);
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
      _debugPrint('설정 저장 완료');
    } catch (e) {
      _debugPrint('설정 저장 중 오류 발생: $e');
    }
  }
  
  /// 튜토리얼 재설정
  Future<void> _resetTutorials() async {
    try {
      final tutorialManager = TutorialManager.instance;
      await tutorialManager.initialize();
      await tutorialManager.resetAllTutorials();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 튜토리얼이 재설정되었습니다. 다음 실행 시 다시 표시됩니다.'),
        ),
      );
      
      _debugPrint('튜토리얼 재설정 완료');
    } catch (e) {
      _debugPrint('튜토리얼 재설정 중 오류 발생: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // OpenAI 사용 설정
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      key: _openAIKey,
                      children: [
                        SwitchListTile(
                          title: const Text('OpenAI API 사용'),
                          subtitle: const Text('AI 기능을 사용하여 컨텐츠를 생성합니다'),
                          value: _useOpenAI,
                          onChanged: (value) {
                            setState(() {
                              _useOpenAI = value;
                            });
                            _saveSettings();
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        if (_useOpenAI)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'OpenAI API 키',
                                border: OutlineInputBorder(),
                                hintText: 'sk-...',
                              ),
                              obscureText: true,
                              onChanged: (value) {
                                // API 키 저장 로직
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 앱 설정
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '앱 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('소리 효과'),
                      subtitle: const Text('게임 효과음을 켜거나 끕니다'),
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                        _saveSettings();
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                    SwitchListTile(
                      key: _notificationKey,
                      title: const Text('알림'),
                      subtitle: const Text('앱 알림을 켜거나 끕니다'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        _saveSettings();
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('다크 모드'),
                      subtitle: const Text('어두운 테마를 사용합니다'),
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                        _saveSettings();
                        
                        // 다크 모드 전환 알림
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('다크 모드 설정은 앱을 다시 시작하면 적용됩니다'),
                          ),
                        );
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            
            // 튜토리얼 재설정
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '튜토리얼',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      key: _tutorialKey,
                      title: const Text('튜토리얼 재설정'),
                      subtitle: const Text('모든 튜토리얼 가이드를 다시 표시합니다'),
                      trailing: const Icon(Icons.refresh),
                      onTap: _resetTutorials,
                    ),
                  ],
                ),
              ),
            ),
            
            // 앱 정보
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '앱 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('버전'),
                      subtitle: const Text('1.0.0-alpha'),
                      trailing: const Icon(Icons.info_outline),
                    ),
                    ListTile(
                      title: const Text('개발자'),
                      subtitle: const Text('Family Choi Team'),
                      trailing: const Icon(Icons.code),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
} 