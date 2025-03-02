import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:family_choi_app/services/game_effects_service.dart';
import 'package:mockito/mockito.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('GameEffectsService 테스트', () {
    late GameEffectsService effectsService;
    
    setUp(() async {
      effectsService = GameEffectsService();
      await effectsService.initialize();
    });
    
    test('사운드 효과 토글 테스트', () {
      // 기본 설정은 사운드 활성화
      expect(effectsService.soundEnabled, true);
      
      // 사운드 비활성화
      effectsService.soundEnabled = false;
      expect(effectsService.soundEnabled, false);
      
      // 사운드 다시 활성화
      effectsService.soundEnabled = true;
      expect(effectsService.soundEnabled, true);
    });
    
    test('애니메이션 토글 테스트', () {
      // 기본 설정은 애니메이션 활성화
      expect(effectsService.animationEnabled, true);
      
      // 애니메이션 비활성화
      effectsService.animationEnabled = false;
      expect(effectsService.animationEnabled, false);
      
      // 애니메이션 다시 활성화
      effectsService.animationEnabled = true;
      expect(effectsService.animationEnabled, true);
    });
    
    test('사운드 경로 매핑 테스트', () {
      // 리플렉션을 사용해 private 메소드 테스트
      final levelUpPath = effectsService.getSoundPathForTesting(GameSound.levelUp);
      expect(levelUpPath, 'sounds/level_up.mp3');
      
      final xpGainPath = effectsService.getSoundPathForTesting(GameSound.xpGain);
      expect(xpGainPath, 'sounds/xp_gain.mp3');
      
      final achievementPath = effectsService.getSoundPathForTesting(GameSound.achievementUnlocked);
      expect(achievementPath, 'sounds/achievement.mp3');
    });
    
    test('애니메이션 경로 매핑 테스트', () {
      // 리플렉션을 사용해 private 메소드 테스트
      final levelUpPath = effectsService.getAnimationPathForTesting(GameAnimation.levelUp);
      expect(levelUpPath, 'assets/animations/level_up.json');
      
      final xpGainPath = effectsService.getAnimationPathForTesting(GameAnimation.xpGain);
      expect(xpGainPath, 'assets/animations/xp_gain.json');
      
      final achievementPath = effectsService.getAnimationPathForTesting(GameAnimation.achievementUnlocked);
      expect(achievementPath, 'assets/animations/achievement.json');
    });
  });
} 