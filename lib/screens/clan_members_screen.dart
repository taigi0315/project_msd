import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../models/clan.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

/// 클랜 멤버 화면
/// 클랜에 속한 멤버들의 목록을 보여주고 관리하는 화면입니다.
class ClanMembersScreen extends StatefulWidget {
  final Character character;
  final Clan clan;
  
  const ClanMembersScreen({
    super.key, 
    required this.character, 
    required this.clan,
  });

  @override
  State<ClanMembersScreen> createState() => _ClanMembersScreenState();
}

class _ClanMembersScreenState extends State<ClanMembersScreen> {
  // 상태 관리
  bool _isLoading = true;
  List<Character> _members = [];
  String? _errorMessage;
  bool _isCreator = false;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('👥 ClanMembersScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 멤버 목록 로드
    _loadMembers();
  }
  
  /// 멤버 데이터 로드
  Future<void> _loadMembers() async {
    _debugPrint('멤버 데이터 로드 중...');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 클랜 멤버 데이터 로드
      final members = <Character>[];
      for (final memberId in widget.clan.memberIds) {
        final member = dataService.getCharacterById(memberId);
        if (member != null) {
          members.add(member);
        }
      }
      
      // 나(현재 캐릭터)가 클랜 창설자인지 확인
      _isCreator = widget.clan.founderCharacterId == widget.character.id;
      
      setState(() {
        _members = members;
      });
      
      _debugPrint('${members.length}명의 멤버 로드됨');
    } catch (e) {
      _debugPrint('멤버 로드 오류: $e');
      
      setState(() {
        _errorMessage = '멤버 정보를 불러오는 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 멤버 제거 처리
  Future<void> _removeMember(Character member) async {
    // 클랜 창설자가 아니거나 자기 자신을 제거하려는 경우 불가능
    if (!_isCreator || member.id == widget.character.id) {
      return;
    }
    
    _debugPrint('멤버 제거 시도: ${member.name}');
    
    try {
      // 확인 다이얼로그
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('멤버 제거'),
          content: Text('정말로 ${member.name}님을 클랜에서 제거하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('제거', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        _debugPrint('멤버 제거 취소됨');
        return;
      }
      
      // 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 클랜에서 멤버 제거
      widget.clan.removeMember(member.id);
      await dataService.updateClan(widget.clan);
      
      // 멤버의 클랜 정보 제거
      member.leaveClan();
      await dataService.updateCharacter(member);
      
      _debugPrint('멤버 제거 완료: ${member.name}');
      
      // 화면 갱신
      setState(() {
        _members.removeWhere((m) => m.id == member.id);
      });
      
      // 알림 표시
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.name}님이 클랜에서 제거되었습니다'),
        ),
      );
    } catch (e) {
      _debugPrint('멤버 제거 오류: $e');
      
      // 에러 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('멤버 제거 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// 초대 코드 공유
  void _shareInviteCode() {
    _debugPrint('초대 코드 공유: ${widget.clan.inviteCode}');
    
    // 실제 앱에서는 플랫폼별 공유 기능 사용
    // 여기서는 간단히 스낵바로 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('초대 코드가 복사되었습니다: ${widget.clan.inviteCode}'),
        action: SnackBarAction(
          label: '공유',
          onPressed: () {
            // 실제 공유 기능 구현
          },
        ),
      ),
    );
  }
  
  /// 초대 코드 재생성
  Future<void> _regenerateInviteCode() async {
    // 클랜 창설자가 아니면 불가능
    if (!_isCreator) {
      return;
    }
    
    _debugPrint('초대 코드 재생성 시도');
    
    try {
      // 확인 다이얼로그
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('초대 코드 재생성'),
          content: const Text('새로운 초대 코드를 생성하면 이전 코드는 만료됩니다. 계속하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('재생성'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        _debugPrint('초대 코드 재생성 취소됨');
        return;
      }
      
      // 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 새 초대 코드 생성
      final newCode = _generateInviteCode();
      widget.clan.inviteCode = newCode;
      
      // 저장
      await dataService.updateClan(widget.clan);
      
      _debugPrint('초대 코드 재생성 완료: $newCode');
      
      // 알림 표시
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('새 초대 코드가 생성되었습니다: $newCode'),
        ),
      );
      
      // 화면 갱신 (상태가 변경된 것은 아니지만 빌드를 다시 실행)
      setState(() {});
    } catch (e) {
      _debugPrint('초대 코드 재생성 오류: $e');
      
      // 에러 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('초대 코드 재생성 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    return code;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('${widget.clan.name} 멤버'),
        centerTitle: true,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMembers,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 초대 코드 섹션
                _buildInviteCodeSection(),
                
                // 구분선
                const Divider(height: 1),
                
                // 멤버 목록 헤더
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '클랜 멤버 (${_members.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      Text(
                        '창설자: ${_getFounderName()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 에러 메시지
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                
                // 멤버 목록
                Expanded(
                  child: _members.isEmpty
                      ? const Center(
                          child: Text(
                            '멤버가 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _members.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            return _buildMemberCard(member);
                          },
                        ),
                ),
              ],
            ),
    );
  }
  
  /// 초대 코드 섹션 위젯
  Widget _buildInviteCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '친구 초대하기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            '아래 코드를 공유하여 친구를 클랜에 초대하세요',
            style: TextStyle(fontSize: 14),
          ),
          
          const SizedBox(height: 16),
          
          // 초대 코드 카드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 초대 코드
                Text(
                  widget.clan.inviteCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                
                // 버튼 그룹
                Row(
                  children: [
                    // 복사 버튼
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _shareInviteCode,
                      tooltip: '복사',
                      color: AppTheme.primaryColor,
                    ),
                    
                    // 재생성 버튼 (클랜 창설자만)
                    if (_isCreator)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _regenerateInviteCode,
                        tooltip: '코드 재생성',
                        color: AppTheme.secondaryColor,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 멤버 카드 위젯
  Widget _buildMemberCard(Character member) {
    final isFounder = member.id == widget.clan.founderCharacterId;
    final isCurrentUser = member.id == widget.character.id;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isFounder
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 캐릭터 아바타
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isFounder ? AppTheme.primaryColor : Colors.grey[700],
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 캐릭터 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // 역할 뱃지
                      if (isFounder)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '창설자',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      
                      if (isCurrentUser && !isFounder)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '나',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 캐릭터 전문분야
                  Text(
                    '${member.specialty}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 레벨과 경험치
                  Text(
                    '레벨 ${member.level} (${member.experiencePoints} XP)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // 제거 버튼 (클랜 창설자만 볼 수 있으며, 창설자 본인은 제거 불가)
            if (_isCreator && !isFounder)
              IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.red),
                onPressed: () => _removeMember(member),
                tooltip: '멤버 제거',
              ),
          ],
        ),
      ),
    );
  }
  
  /// 창설자 이름 가져오기
  String _getFounderName() {
    final founder = _members.firstWhere(
      (member) => member.id == widget.clan.founderCharacterId,
      orElse: () => Character(
        id: '',
        name: '알 수 없음',
        userId: 'unknown',
        specialty: CharacterSpecialty.warrior,
        battleCry: '',
        createdAt: DateTime.now(),
      ),
    );
    
    return founder.name;
  }
} 