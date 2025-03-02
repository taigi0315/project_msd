import 'package:flutter/material.dart';
import 'package:family_choi_app/models/character.dart';
import 'package:family_choi_app/services/mock_data_service.dart';
import 'package:family_choi_app/services/game_effects_service.dart';

// ... existing code ...

  /// 경험치 추가 버튼 클릭 핸들러
  void _handleAddExperience() async {
    // 경험치 입력 다이얼로그 표시
    final int? amount = await _showAddExperienceDialog();
    
    if (amount != null && amount > 0) {
      setState(() {
        _isLoading = true;
      });
      
      // 경험치 추가
      final dataService = MockDataService();
      final bool didLevelUp = await dataService.gainCharacterExperience(
        widget.characterId.toString(), // 문자열로 변환
        amount,
        context: context, // 컨텍스트 전달하여 효과 표시
      );
      
      // 캐릭터 정보 다시 로드
      await _loadCharacter();
      
      setState(() {
        _isLoading = false;
      });
      
      // 레벨업 메시지 표시 (게임 효과 서비스에서 이미 효과를 표시했으므로 중복 표시하지 않음)
      if (!didLevelUp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$amount XP를 획득했습니다!'))
        );
      }
    }
  }
  
  /// 경험치 추가 다이얼로그 표시
  Future<int?> _showAddExperienceDialog() async {
    final TextEditingController controller = TextEditingController();
    
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('경험치 추가'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '경험치 (XP)',
            hintText: '추가할 경험치 양을 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final int? amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.of(context).pop(amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('유효한 경험치 값을 입력하세요'))
                );
              }
            },
            child: Text('추가'),
          ),
        ],
      ),
    );
  }

// ... existing code ...