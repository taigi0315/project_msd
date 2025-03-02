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
  List<Clan> _availableClans = [];
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🏰 ClanSelectionScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 클랜 목록 로드
    _loadClans();
  }
  
  @override
  void dispose() {
    _inviteCodeController.dispose();
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
  
  /// 클랜 목록 로드
  Future<void> _loadClans() async {
    _debugPrint('클랜 목록 로드 중...');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 데이터 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 클랜 목록 가져오기
      final clans = dataService.getAllClans();
      
      setState(() {
        _availableClans = clans;
      });
      
      _debugPrint('${clans.length}개의 클랜 로드됨');
    } catch (e) {
      _debugPrint('클랜 로드 오류: $e');
      
      setState(() {
        _errorMessage = '클랜 목록을 불러오는 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 초대 코드로 클랜 참여
  Future<void> _joinClanByInviteCode() async {
    _debugPrint('초대 코드로 클랜 참여 시도: ${_inviteCodeController.text}');
    
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      setState(() {
        _errorMessage = '초대 코드를 입력해주세요.';
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
          _errorMessage = '유효하지 않은 초대 코드입니다.';
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
  
  /// 클랜 참여
  Future<void> _joinClan(Clan clan) async {
    _debugPrint('클랜 참여: ${clan.name}');
    
    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });
    
    try {
      // 데이터 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
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
    ).then((_) {
      // 화면이 돌아오면 클랜 목록 다시 로드
      _loadClans();
    });
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
        title: const Text('클랜 선택'),
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
                    '클랜에 가입하여 모험을 시작하세요',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '기존 클랜에 참여하거나 새로운 클랜을 창설할 수 있습니다.',
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
                            '초대 코드로 참여',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            '클랜 초대 코드가 있다면 입력하세요.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inviteCodeController,
                                  decoration: InputDecoration(
                                    hintText: '초대 코드 입력',
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
                                    : const Text('참여'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 클랜 생성 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToCreateClan,
                      icon: const Icon(Icons.add),
                      label: const Text('새 클랜 창설하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 기존 클랜 목록 헤더
                  Text(
                    '공개 클랜 목록',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 클랜 목록
                  Expanded(
                    child: _availableClans.isEmpty
                        ? Center(
                            child: Text(
                              '참여 가능한 클랜이 없습니다.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _availableClans.length,
                            itemBuilder: (context, index) {
                              final clan = _availableClans[index];
                              return _buildClanCard(clan);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
  
  /// 클랜 카드 위젯
  Widget _buildClanCard(Clan clan) {
    final isAlreadyMember = clan.memberIds.contains(widget.character.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAlreadyMember ? AppTheme.primaryColor : Colors.transparent,
          width: isAlreadyMember ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => _joinClan(clan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 클랜 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.shield,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 클랜 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clan.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '멤버: ${clan.memberIds.length}명',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '프로젝트: ${clan.projectIds.length}개',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              // 참여 버튼
              ElevatedButton(
                onPressed: isAlreadyMember ? () => _navigateToDashboard(clan, widget.character) : () => _joinClan(clan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAlreadyMember ? AppTheme.secondaryColor : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(isAlreadyMember ? '입장' : '참여'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 