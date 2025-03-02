import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../models/clan.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'clan_dashboard_screen.dart';
import 'create_clan_screen.dart';

/// 클랜 선택 화면
/// 사용자가 기존 클랜에 참여하거나 새로운 클랜을 생성할 수 있는 화면입니다.
class ClanSelectionScreen extends StatefulWidget {
  final Character character;
  
  const ClanSelectionScreen({
    super.key, 
    required this.character,
  });

  @override
  State<ClanSelectionScreen> createState() => _ClanSelectionScreenState();
}

class _ClanSelectionScreenState extends State<ClanSelectionScreen> {
  // 상태 관리
  final _inviteCodeController = TextEditingController();
  bool _isLoading = true;
  bool _isJoining = false;
  String? _errorMessage;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🏰 ClanSelectionScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 초기화 완료
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _inviteCodeController.dispose();
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
  
  /// 초대 코드로 클랜 참여
  Future<void> _joinClanByInviteCode() async {
    _debugPrint('초대 코드로 클랜 참여 시도: ${_inviteCodeController.text}');
    
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an invite code.';
      });
      return;
    }
    
    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });
    
    try {
      // 데이터 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 초대 코드로 클랜 검색
      final clan = dataService.getClanByInviteCode(inviteCode);
      
      if (clan == null) {
        _debugPrint('유효하지 않은 초대 코드: $inviteCode');
        setState(() {
          _errorMessage = 'Invalid invite code.';
        });
        return;
      }
      
      // 이미 클랜에 가입되어 있는지 확인
      if (clan.memberIds.contains(widget.character.id)) {
        _debugPrint('이미 클랜에 가입됨: ${clan.name}');
        
        // 대시보드로 이동
        _navigateToDashboard(clan, widget.character);
        return;
      }
      
      // 클랜에 캐릭터 추가
      clan.addMember(widget.character.id);
      await dataService.updateClan(clan);
      
      // 캐릭터에 클랜 연결
      final updatedCharacter = widget.character.joinClan(clan.id);
      await dataService.updateCharacter(updatedCharacter);
      
      _debugPrint('클랜 가입 완료: ${clan.name}');
      
      // 대시보드로 이동
      if (!mounted) return;
      _navigateToDashboard(clan, updatedCharacter);
    } catch (e) {
      _debugPrint('클랜 참여 오류: $e');
      
      setState(() {
        _errorMessage = '클랜 참여 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }
  
  /// 클랜 생성 화면으로 이동
  void _navigateToCreateClan() {
    _debugPrint('클랜 생성 화면으로 이동');
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateClanScreen(character: widget.character),
      ),
    );
  }
  
  /// 클랜 대시보드로 이동
  void _navigateToDashboard(Clan clan, Character updatedCharacter) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ClanDashboardScreen(character: updatedCharacter),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    _debugPrint('빌드 중...');
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Select Clan'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단 헤더
                  Text(
                    'Join a clan and start your adventure',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'You can join an existing clan with an invite code or create a new one.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
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
                  
                  // 초대 코드 입력
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join by Invite Code',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'All clans are private. Enter an invite code to join a clan.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inviteCodeController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Invite Code',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.code, color: AppTheme.primaryColor),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              ElevatedButton(
                                onPressed: _isJoining ? null : _joinClanByInviteCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                ),
                                child: _isJoining
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Join'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 클랜 생성 대안
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Invite Code?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Start your own clan and invite others to join.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 클랜 생성 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _navigateToCreateClan,
                              icon: const Icon(Icons.add),
                              label: const Text('Create New Clan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 안내 메시지
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Need an invite code?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ask a clan member to share their invite code with you. Each clan has a unique code for security reasons.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 