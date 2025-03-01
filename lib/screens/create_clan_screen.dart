import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/clan.dart';
import '../services/mock_ai_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'clan_dashboard_screen.dart';

/// 클랜 생성 화면
/// 캐릭터가 새로운 클랜을 창설할 수 있는 화면입니다.
class CreateClanScreen extends StatefulWidget {
  final Character character;
  
  const CreateClanScreen({
    super.key, 
    required this.character,
  });

  @override
  State<CreateClanScreen> createState() => _CreateClanScreenState();
}

class _CreateClanScreenState extends State<CreateClanScreen> {
  // 상태 관리
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;
  bool _isLoading = false;
  bool _isGeneratingName = false;
  String? _errorMessage;
  
  // AI 서비스 및 데이터 서비스
  late MockAIService _aiService;
  late MockDataService _dataService;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🛡️ CreateClanScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    _aiService = MockAIService();
    
    // 랜덤 이름으로 초기화 (필요시)
    _generateRandomClanName();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataService = Provider.of<MockDataService>(context, listen: false);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
  
  /// 클랜 이름 랜덤 생성
  Future<void> _generateRandomClanName() async {
    _debugPrint('클랜 이름 랜덤 생성 중...');
    
    setState(() {
      _isGeneratingName = true;
    });
    
    try {
      final clanName = _aiService.generateProjectName(type: 'clan');
      
      setState(() {
        _nameController.text = clanName;
      });
      
      _debugPrint('생성된 클랜 이름: $clanName');
    } catch (e) {
      _debugPrint('클랜 이름 생성 오류: $e');
    } finally {
      setState(() {
        _isGeneratingName = false;
      });
    }
  }
  
  /// 클랜 생성 시도
  Future<void> _createClan() async {
    // 폼 검증
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    
    _debugPrint('클랜 생성 시도: $name');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 새 클랜 생성
      final newClan = Clan(
        id: const Uuid().v4(),
        name: name,
        description: description,
        isPrivate: _isPrivate,
        inviteCode: _generateInviteCode(),
        founderCharacterId: widget.character.id,
        leaderId: widget.character.id,
        memberIds: [widget.character.id],
        createdAt: DateTime.now(),
      );
      
      // 데이터베이스에 저장
      await _dataService.addClan(newClan);
      
      // 캐릭터에 클랜 연결
      widget.character.joinClan(newClan.id);
      await _dataService.updateCharacter(widget.character);
      
      _debugPrint('클랜 생성 완료: ${newClan.name} (ID: ${newClan.id})');
      
      // 대시보드로 이동
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ClanDashboardScreen(character: widget.character),
        ),
      );
    } catch (e) {
      _debugPrint('클랜 생성 오류: $e');
      
      setState(() {
        _errorMessage = '클랜 생성 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 초대 코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    
    for (var i = 0; i < 8; i++) {
      buffer.write(chars[rnd % chars.length]);
    }
    
    final code = buffer.toString();
    _debugPrint('초대 코드 생성: $code');
    return code;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('새 클랜 창설'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 상단 제목
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        '당신만의 클랜을 창설하세요',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // 에러 메시지
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // 클랜 이름 입력
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: '클랜 이름',
                              hintText: '클랜의 이름을 입력하세요',
                              prefixIcon: const Icon(Icons.shield, color: AppTheme.primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '클랜 이름을 입력해주세요';
                              }
                              if (value.length < 3) {
                                return '클랜 이름은 최소 3글자 이상이어야 합니다';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // 랜덤 이름 생성 버튼
                        IconButton(
                          onPressed: _isGeneratingName ? null : _generateRandomClanName,
                          icon: _isGeneratingName
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.autorenew),
                          tooltip: '랜덤 이름 생성',
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 클랜 설명 입력
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: '클랜 설명',
                        hintText: '클랜에 대한 설명을 입력하세요',
                        prefixIcon: const Icon(Icons.description, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '클랜 설명을 입력해주세요';
                        }
                        if (value.length < 10) {
                          return '클랜 설명은 최소 10글자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 공개/비공개 설정
                    SwitchListTile(
                      title: const Text('비공개 클랜'),
                      subtitle: const Text('초대 코드로만 가입할 수 있습니다'),
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // 클랜 창설 버튼
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createClan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '클랜 창설하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 취소 버튼
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 