import 'package:flutter/material.dart';
import 'package:family_choi_app/models/task.dart';
import 'package:family_choi_app/models/character.dart';
import 'package:family_choi_app/services/mock_data_service.dart';
import 'package:family_choi_app/services/game_effects_service.dart';

// ... existing code ...

  void _markTaskComplete() async {
    setState(() {
      _isLoading = true;
    });

    // 태스크 완료 처리
    final dataService = MockDataService();
    await dataService.completeTask(widget.taskId);

    // 캐릭터에 경험치 추가 (10 XP)
    final Character? character = await dataService.getCurrentCharacter();
    if (character != null) {
      await dataService.gainCharacterExperience(character.id, 10, context: context);
      
      // XP 획득 효과 표시
      GameEffectsService().showXpGainEffect(context, 10);
      GameEffectsService().playSound(GameSound.taskComplete);
    }

    // 화면 종료
    setState(() {
      _isLoading = false;
    });
    
    // 사용자에게 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('태스크가 완료되었습니다!'))
    );

    // 태스크 상세 화면 닫기 (이전 화면으로 돌아가기)
    Navigator.of(context).pop(true);
  }

// ... existing code ...