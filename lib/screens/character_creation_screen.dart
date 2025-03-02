import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/mock_data_service.dart';
import '../services/mock_ai_service.dart';
import '../theme/app_theme.dart';
import 'clan_selection_screen.dart';
import 'character_questionnaire_screen.dart';

/// 캐릭터 생성 화면
/// 사용자가 자신의 캐릭터를 생성하는 화면입니다.
/// AI 질문과 답변을 통해 캐릭터를 생성합니다.
class CharacterCreationScreen extends StatefulWidget {
  final String userId;
  
  const CharacterCreationScreen({
    super.key, 
    required this.userId,
  });

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  // 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🧙 CharacterCreationScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('Initializing...');
    
    // AI 질문 화면으로 자동 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToQuestionnaire();
    });
  }
  
  /// AI 질문 화면으로 이동
  void _navigateToQuestionnaire() {
    _debugPrint('Navigating to questionnaire screen...');
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CharacterQuestionnaireScreen(
          userId: widget.userId,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    _debugPrint('Building...');
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Character Creation'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI 설문조사 안내 이미지
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.psychology,
                size: 120,
                color: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 설명 텍스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Creating your character through AI Questionnaire...',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Please answer a few fun questions to help us create a character that perfectly matches your personality!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 로딩 인디케이터
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 