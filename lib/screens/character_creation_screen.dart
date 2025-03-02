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
/// 캐릭터의 이름, 전문 역할 등을 설정할 수 있습니다.
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
  // 캐릭터 생성 폼 키
  final _formKey = GlobalKey<FormState>();
  
  // 텍스트 컨트롤러
  final _nameController = TextEditingController();
  
  // 선택된 전문 역할
  CharacterSpecialty _selectedSpecialty = CharacterSpecialty.leader;
  
  // 생성된 전투 구호
  String _battleCry = '';
  
  // 화면 상태
  bool _isLoading = false;
  bool _isSubmitting = false;
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  // 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🧙 CharacterCreationScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('Initializing...');
    
    // 기본값 설정
    _nameController.text = 'Hero Name';
    _generateBattleCry();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _debugPrint('Resources released');
    super.dispose();
  }
  
  /// 전투 구호 생성
  void _generateBattleCry() {
    _debugPrint('Generating battle cry...');
    setState(() {
      _isLoading = true;
    });
    
    try {
      // AI 서비스 인스턴스 가져오기
      final aiService = MockAIService();
      
      // 전투 구호 생성
      final battleCry = aiService.generateBattleCry(
        _selectedSpecialty, 
        _nameController.text.isNotEmpty ? _nameController.text : 'The Fixer',
      );
      
      setState(() {
        _battleCry = battleCry;
      });
    } catch (e) {
      _debugPrint('Battle cry generation error: $e');
      
      // 오류 발생 시 기본 전투 구호 설정
      setState(() {
        _battleCry = "If it's broken, I'll fix it—or roast it!";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 다음 단계로 이동
  void _nextStep() {
    _debugPrint('Move to next step: ${_currentStep + 1}');
    
    if (_currentStep == 0) {
      // 1단계: 이름 및 역할 선택 검증
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }
    
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // 마지막 단계에서는 캐릭터 생성 완료
      _createCharacter();
    }
  }
  
  /// 이전 단계로 이동
  void _prevStep() {
    _debugPrint('Move to previous step: ${_currentStep - 1}');
    
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }
  
  /// 캐릭터 생성 완료
  Future<void> _createCharacter() async {
    _debugPrint('Creating character...');
    
    if (!_formKey.currentState!.validate()) {
      _debugPrint('Form validation failed');
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // 데이터 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 새 캐릭터 생성
      final character = Character(
        name: _nameController.text,
        userId: widget.userId,
        specialty: _selectedSpecialty,
        battleCry: _battleCry,
      );
      
      // 캐릭터 저장
      await dataService.addCharacter(character);
      _debugPrint('Character creation completed: ${character.name}');
      
      // 클랜 선택 화면으로 이동
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ClanSelectionScreen(character: character),
        ),
      );
    } catch (e) {
      _debugPrint('Character creation error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during character creation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // 진행 표시기
            LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            
            // 단계 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Step ${_currentStep + 1}/$_totalSteps: ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _getStepTitle(_currentStep),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // 단계별 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildStepContent(_currentStep),
              ),
            ),
            
            // AI 설문 옵션 (전통적 방식 대신 설문으로 클래스 선택)
            if (_currentStep == 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CharacterQuestionnaireScreen(
                          userId: widget.userId,
                          onCharacterGenerated: (Character character) {
                            // 생성된 캐릭터 정보로 업데이트
                            setState(() {
                              _nameController.text = character.name;
                              _selectedSpecialty = character.specialty;
                              _battleCry = character.battleCry;
                              _currentStep = 2; // 바로 전투 구호 단계로 이동
                            });
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology, color: AppTheme.secondaryColor),
                  label: const Text(
                    'Get Role Recommendation via AI Survey',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.secondaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ),
            
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 이전 버튼
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _prevStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  // 다음/완료 버튼
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 48),
                    ),
                    child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentStep < _totalSteps - 1 ? 'Next' : 'Complete',
                          style: const TextStyle(fontSize: 16),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 단계 제목 가져오기
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Specialty Selection';
      case 2:
        return 'Battle Cry Confirmation';
      default:
        return '';
    }
  }
  
  /// 단계별 콘텐츠 빌드
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildSpecialtySelectionStep();
      case 2:
        return _buildBattleCryStep();
      default:
        return const SizedBox.shrink();
    }
  }
  
  /// 1단계: 기본 정보 입력
  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us your adventurer\'s name',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'This name is an important element that distinguishes you from other adventurers.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        
        const SizedBox(height: 32),
        
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Character Name',
            hintText: 'Choi Chang-ik',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a character name';
            }
            return null;
          },
          onChanged: (value) {
            // 이름이 변경되면 전투 구호 업데이트
            if (value.isNotEmpty) {
              _generateBattleCry();
            }
          },
        ),
        
        const SizedBox(height: 32),
        
        // 중세 캐릭터 일러스트 이미지
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.person_outline,
              size: 120,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Are you ready to embark on an adventure?',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// 2단계: 전문 역할 선택
  Widget _buildSpecialtySelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your specialty?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Choose the role that best reflects your personality and abilities.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 16),
        
        Card(
          color: Colors.amber[50],
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppTheme.secondaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Having a hard time deciding on a role?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Click the "Get Role Recommendation via AI Survey" button at the bottom of the page to answer a survey, and AI will recommend a role that suits you.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        
        // 역할 선택 카드 목록
        ...CharacterSpecialty.values.map((specialty) => 
          _buildSpecialtyCard(specialty),
        ),
      ],
    );
  }
  
  /// 역할 선택 카드
  Widget _buildSpecialtyCard(CharacterSpecialty specialty) {
    final isSelected = specialty == _selectedSpecialty;
    
    // 역할별 아이콘
    IconData specialtyIcon;
    switch (specialty) {
      case CharacterSpecialty.leader:
        specialtyIcon = Icons.shield;
        break;
      case CharacterSpecialty.warrior:
        specialtyIcon = Icons.fitness_center;
        break;
      case CharacterSpecialty.mage:
        specialtyIcon = Icons.auto_fix_high;
        break;
      case CharacterSpecialty.healer:
        specialtyIcon = Icons.favorite;
        break;
      case CharacterSpecialty.scout:
        specialtyIcon = Icons.explore;
        break;
      case CharacterSpecialty.ranger:
        specialtyIcon = Icons.accessibility_new;
        break;
      case CharacterSpecialty.rogue:
        specialtyIcon = Icons.dangerous;
        break;
      case CharacterSpecialty.cleric:
        specialtyIcon = Icons.health_and_safety;
        break;
      default:
        specialtyIcon = Icons.person;
        break;
    }
    
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSpecialty = specialty;
          });
          _generateBattleCry();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 역할 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[300],
                ),
                child: Icon(
                  specialtyIcon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 32,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 역할 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialty.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.primaryColor : Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      specialty.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              // 선택 표시
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 3단계: 전투 구호 확인
  Widget _buildBattleCryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Battle Cry',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'A battle cry is a phrase that shows your determination and will.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        
        const SizedBox(height: 32),
        
        // 전투 구호 표시
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: AppTheme.secondaryColor,
                    size: 40,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    _battleCry,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    '- ${_nameController.text}, ${_selectedSpecialty.displayName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
        ),
        
        const SizedBox(height: 24),
        
        // 재생성 버튼
        Center(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _generateBattleCry,
            icon: const Icon(Icons.refresh),
            label: const Text('Regenerate Battle Cry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 최종 안내 문구
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.secondaryColor),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.secondaryColor,
                size: 28,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'All settings are complete!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Complete character creation and start your adventure.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 