import 'package:flutter/material.dart';
import 'package:family_choi_app/models/mission.dart';
import 'package:family_choi_app/models/character.dart';
import 'package:family_choi_app/services/mock_data_service.dart';
import 'package:family_choi_app/services/game_effects_service.dart';
import 'package:family_choi_app/theme/app_theme.dart';

// ... existing code ...

  void _markMissionComplete() async {
    setState(() {
      _isLoading = true;
    });

    // 미션 완료 처리
    final dataService = MockDataService();
    await dataService.completeMission(widget.missionId);

    // 캐릭터에 경험치 추가 (50 XP)
    final Character? character = await dataService.getCurrentCharacter();
    if (character != null && mission != null) {
      final int xpAmount = mission!.experienceReward ?? 50;
      await dataService.gainCharacterExperience(character.id, xpAmount, context: context);
      
      // 미션 완료 효과 표시
      GameEffectsService().showMissionCompleteEffect(context);
      
      // XP 획득 효과 표시
      GameEffectsService().showXpGainEffect(context, xpAmount);
    }

    // 화면 종료
    setState(() {
      _isLoading = false;
    });
    
    // 사용자에게 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('미션을 성공적으로 완료했습니다!'))
    );

    // 미션 상세 화면 닫기 (이전 화면으로 돌아가기)
    Navigator.of(context).pop(true);
  }

// ... existing code ...