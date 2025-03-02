import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/tutorial_screen.dart';

/// 앱 튜토리얼 관리 서비스
/// 앱의 모든 튜토리얼 관련 기능을 관리합니다.
class TutorialManager {
  /// 싱글턴 인스턴스
  static final TutorialManager _instance = TutorialManager._internal();
  
  /// 공유 환경설정 인스턴스
  SharedPreferences? _prefs;
  
  /// 초기화 여부
  bool _isInitialized = false;
  
  /// 튜토리얼 완료 상태
  bool _tutorialCompleted = false;
  
  /// 기능별 튜토리얼 상태 맵
  final Map<String, bool> _featureTutorialShown = {};
  
  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    debugPrint('🔍 TutorialManager: $message');
  }
  
  /// 내부 생성자
  TutorialManager._internal();
  
  /// 팩토리 생성자
  factory TutorialManager() {
    return _instance;
  }
  
  /// 싱글턴 인스턴스 얻기
  static TutorialManager get instance => _instance;
  
  /// 튜토리얼 완료 상태 확인
  bool get isTutorialCompleted => _tutorialCompleted;
  
  /// 튜토리얼 관리자 초기화
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _tutorialCompleted = _prefs?.getBool('tutorial_completed') ?? false;
      _loadFeatureTutorialStatus();
      _isInitialized = true;
      _debugPrint('초기화 완료: 튜토리얼 완료 상태 = $_tutorialCompleted');
    } catch (e) {
      _debugPrint('초기화 중 오류 발생: $e');
    }
  }
  
  /// 기능별 튜토리얼 상태 로드
  void _loadFeatureTutorialStatus() {
    if (_prefs == null) {
      return;
    }
    
    try {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('tutorial_feature_')) {
          final featureKey = key.replaceFirst('tutorial_feature_', '');
          _featureTutorialShown[featureKey] = _prefs!.getBool(key) ?? false;
        }
      }
      _debugPrint('기능별 튜토리얼 상태 로드 완료: ${_featureTutorialShown.length}개');
    } catch (e) {
      _debugPrint('기능별 튜토리얼 상태 로드 중 오류 발생: $e');
    }
  }
  
  /// 기능별 튜토리얼 상태 설정
  Future<void> setFeatureTutorialShown(String featureKey, bool shown) async {
    if (_prefs == null) {
      await initialize();
    }
    
    try {
      _featureTutorialShown[featureKey] = shown;
      await _prefs?.setBool('tutorial_feature_$featureKey', shown);
      _debugPrint('기능별 튜토리얼 상태 설정: $featureKey = $shown');
    } catch (e) {
      _debugPrint('기능별 튜토리얼 상태 설정 중 오류 발생: $e');
    }
  }
  
  /// 기능별 튜토리얼 상태 확인
  bool isFeatureTutorialShown(String featureKey) {
    return _featureTutorialShown[featureKey] ?? false;
  }
  
  /// 앱 시작 튜토리얼 출력 여부 확인
  Future<bool> shouldShowAppTutorial() async {
    if (_prefs == null) {
      await initialize();
    }
    
    return !_tutorialCompleted;
  }
  
  /// 튜토리얼 완료 상태 설정
  Future<void> setTutorialCompleted(bool completed) async {
    if (_prefs == null) {
      await initialize();
    }
    
    try {
      _tutorialCompleted = completed;
      await _prefs?.setBool('tutorial_completed', completed);
      _debugPrint('튜토리얼 완료 상태 설정: $completed');
    } catch (e) {
      _debugPrint('튜토리얼 완료 상태 설정 중 오류 발생: $e');
    }
  }
  
  /// 모든 튜토리얼 상태 초기화
  Future<void> resetAllTutorials() async {
    if (_prefs == null) {
      await initialize();
    }
    
    try {
      // 앱 튜토리얼 초기화
      _tutorialCompleted = false;
      await _prefs?.setBool('tutorial_completed', false);
      
      // 기능별 튜토리얼 초기화
      for (final key in _featureTutorialShown.keys) {
        await _prefs?.setBool('tutorial_feature_$key', false);
      }
      _featureTutorialShown.clear();
      
      _debugPrint('모든 튜토리얼 상태 초기화 완료');
    } catch (e) {
      _debugPrint('모든 튜토리얼 상태 초기화 중 오류 발생: $e');
    }
  }
  
  /// 앱 튜토리얼 화면 표시
  Future<void> showAppTutorial(BuildContext context) async {
    _debugPrint('앱 튜토리얼 화면 표시');
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TutorialScreen(
          onComplete: () {
            setTutorialCompleted(true);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
  
  /// 특정 기능에 대한 간단한 툴팁 튜토리얼 표시
  Future<void> showFeatureTutorial({
    required BuildContext context,
    required String featureKey,
    required String message,
    required GlobalKey targetKey,
    VoidCallback? onComplete,
  }) async {
    // 이미 해당 기능의 튜토리얼을 봤다면 표시하지 않음
    if (isFeatureTutorialShown(featureKey)) {
      _debugPrint('이미 표시된 기능 튜토리얼: $featureKey');
      return;
    }
    
    _debugPrint('기능 튜토리얼 표시: $featureKey');
    
    // 대상 위젯의 위치와 크기 계산
    final RenderBox? renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      _debugPrint('대상 위젯을 찾을 수 없습니다: $featureKey');
      return;
    }
    
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    // 오버레이 항목 생성 및 삽입
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 배경 어둡게
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // 오버레이 제거
                overlayEntry.remove();
                // 기능 튜토리얼 표시 여부 저장
                setFeatureTutorialShown(featureKey, true);
                // 완료 콜백 실행
                if (onComplete != null) {
                  onComplete();
                }
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          
          // 대상 위젯 주변에 하이라이트 표시
          Positioned(
            left: position.dx - 8,
            top: position.dy - 8,
            width: size.width + 16,
            height: size.height + 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          // 메시지 표시
          Positioned(
            left: position.dx,
            top: position.dy + size.height + 16,
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // 오버레이 제거
                        overlayEntry.remove();
                        // 기능 튜토리얼 표시 여부 저장
                        setFeatureTutorialShown(featureKey, true);
                        // 완료 콜백 실행
                        if (onComplete != null) {
                          onComplete();
                        }
                      },
                      child: const Text('확인'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    
    overlayState.insert(overlayEntry);
  }
} 