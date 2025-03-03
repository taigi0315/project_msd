import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import '../models/game_sound.dart';

/// 게임 요소 효과를 관리하는 서비스
/// 사운드 효과, 애니메이션 등을 처리합니다.
class GameEffectsService {
  static final GameEffectsService _instance = GameEffectsService._internal();
  
  // 싱글톤 인스턴스 가져오기
  factory GameEffectsService() {
    return _instance;
  }
  
  GameEffectsService._internal();
  
  // 오디오 플레이어 인스턴스
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // 사운드 효과 켜기/끄기 설정
  bool soundEnabled = true;
  
  // 애니메이션 켜기/끄기 설정
  bool animationEnabled = true;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    debugPrint('🎮 GameEffectsService: $message');
  }
  
  /// 서비스 초기화
  Future<void> initialize() async {
    _debugPrint('Initializing game effects service...');
    
    try {
      // 오디오 플레이어 초기화
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      
      _debugPrint('Game effects service initialized');
    } catch (e) {
      _debugPrint('Game effects service initialization failed: $e');
      // 실패해도 앱은 계속 실행될 수 있도록 함
    }
  }
  
  /// 오디오 볼륨 설정
  void setVolume(double volume) {
    try {
      _audioPlayer.setVolume(volume);
      _debugPrint('Audio volume set to: $volume');
    } catch (e) {
      _debugPrint('Failed to set audio volume: $e');
    }
  }
  
  /// 사운드 효과 재생
  Future<void> playSound(GameSound sound) async {
    if (!soundEnabled) {
      _debugPrint('Sound is disabled');
      return;
    }
    
    try {
      _debugPrint('Playing sound: ${sound.name}');
      await _audioPlayer.stop();
      
      // 사운드 리소스 경로 매핑
      final String assetPath = _getSoundPath(sound);
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      _debugPrint('Sound effect playback failed: $e');
    }
  }
  
  /// 사운드 파일 경로 가져오기
  String _getSoundPath(GameSound sound) {
    switch (sound) {
      case GameSound.levelUp:
        return 'sounds/level_up.mp3';
      case GameSound.xpGain:
        return 'sounds/xp_gain.mp3';
      case GameSound.achievementUnlocked:
        return 'sounds/achievement.mp3';
      case GameSound.missionComplete:
        return 'sounds/mission_complete.mp3';
      case GameSound.buttonClick:
        return 'sounds/button_click.mp3';
      case GameSound.swordClash:
        return 'sounds/sword_clash.mp3';
      case GameSound.taskComplete:
        return 'sounds/task_complete.mp3';
      case GameSound.success:
        return 'sounds/success.mp3';
      case GameSound.error:
        return 'sounds/error.mp3';
    }
  }
  
  /// 테스트를 위한 사운드 경로 가져오기
  @visibleForTesting
  String getSoundPathForTesting(GameSound sound) {
    return _getSoundPath(sound);
  }
  
  /// 효과 애니메이션 위젯 생성
  Widget buildAnimation(GameAnimation animation, {double? size, Color? color, VoidCallback? onFinish}) {
    if (!animationEnabled) {
      return const SizedBox();
    }
    
    // 애니메이션 리소스 경로 매핑
    final String assetPath = _getAnimationPath(animation);
    
    _debugPrint('Creating animation: ${animation.name}');
    
    return Lottie.asset(
      assetPath,
      width: size,
      height: size,
      animate: true,
      repeat: false,
      onLoaded: (composition) {
        _debugPrint('Animation loaded: ${animation.name}');
      },
      frameRate: FrameRate.max,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['**'], 
            value: color,
          ),
        ],
      ),
    );
  }
  
  /// 애니메이션 파일 경로 가져오기
  String _getAnimationPath(GameAnimation animation) {
    switch (animation) {
      case GameAnimation.levelUp:
        return 'assets/animations/level_up.json';
      case GameAnimation.xpGain:
        return 'assets/animations/xp_gain.json';
      case GameAnimation.achievementUnlocked:
        return 'assets/animations/achievement.json';
      case GameAnimation.confetti:
        return 'assets/animations/confetti.json';
      case GameAnimation.swordSlash:
        return 'assets/animations/sword_slash.json';
      case GameAnimation.sparkle:
        return 'assets/animations/sparkle.json';
    }
  }
  
  /// 테스트를 위한 애니메이션 경로 가져오기
  @visibleForTesting
  String getAnimationPathForTesting(GameAnimation animation) {
    return _getAnimationPath(animation);
  }
  
  /// XP 획득 효과 표시
  void showXpGainEffect(BuildContext context, int amount) {
    if (!animationEnabled) return;
    
    _debugPrint('XP gain effect displayed: +$amount XP');
    
    // 사운드 효과 재생
    playSound(GameSound.xpGain);
    
    // 오버레이 항목을 저장할 변수
    late OverlayEntry overlayEntry;
    
    // 오버레이 항목 정의
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildAnimation(
                GameAnimation.sparkle, 
                size: 40,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, -20 * value),
                      child: Text(
                        '+$amount XP',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    overlayEntry.remove();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
    
    // 오버레이에 항목 추가
    Overlay.of(context).insert(overlayEntry);
  }
  
  /// 레벨업 효과 표시
  void showLevelUpEffect(BuildContext context, int newLevel) {
    if (!animationEnabled) return;
    
    _debugPrint('Level up effect displayed: level $newLevel');
    
    // 사운드 효과 재생
    playSound(GameSound.levelUp);
    
    // 오버레이 항목을 저장할 변수
    late OverlayEntry overlayEntry;
    
    // 오버레이 항목 정의
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAnimation(
                  GameAnimation.levelUp, 
                  size: 150,
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Level Up!',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Congratulations! Level $newLevel achieved!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    Future.delayed(const Duration(seconds: 2), () {
                      overlayEntry.remove();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // 오버레이에 항목 추가
    Overlay.of(context).insert(overlayEntry);
  }
  
  /// 미션 완료 효과 표시
  void showMissionCompleteEffect(BuildContext context) {
    if (!animationEnabled) return;
    
    _debugPrint('Mission complete effect displayed');
    
    // 사운드 효과 재생
    playSound(GameSound.missionComplete);
    
    // 오버레이 항목을 저장할 변수
    late OverlayEntry overlayEntry;
    
    // 오버레이 항목 정의
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: buildAnimation(
              GameAnimation.confetti, 
              size: 200,
              onFinish: () {
                Future.delayed(const Duration(seconds: 1), () {
                  overlayEntry.remove();
                });
              },
            ),
          ),
        ),
      ),
    );
    
    // 오버레이에 항목 추가
    Overlay.of(context).insert(overlayEntry);
  }
  
  /// 업적 달성 효과 표시
  void showAchievementUnlockedEffect(BuildContext context, String achievementName) {
    if (!animationEnabled) return;
    
    _debugPrint('Achievement unlocked effect displayed: $achievementName');
    
    // 사운드 효과 재생
    playSound(GameSound.achievementUnlocked);
    
    // 오버레이 항목을 저장할 변수
    late OverlayEntry overlayEntry;
    
    // 오버레이 항목 정의
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildAnimation(
                            GameAnimation.achievementUnlocked, 
                            size: 60,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Achievement Unlocked!',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                achievementName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              onEnd: () {
                Future.delayed(const Duration(seconds: 3), () {
                  overlayEntry.remove();
                });
              },
            ),
          ),
        ),
      ),
    );
    
    // 오버레이에 항목 추가
    Overlay.of(context).insert(overlayEntry);
  }
  
  /// 리소스 해제
  void dispose() {
    _debugPrint('Game effects service resources released');
    _audioPlayer.dispose();
  }
} 