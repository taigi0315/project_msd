import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../models/project.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

/// 캐릭터 프로필 화면
/// 캐릭터의 정보와 업적, 레벨, 경험치 등을 보여주는 화면입니다.
class CharacterProfileScreen extends StatefulWidget {
  final Character character;
  
  const CharacterProfileScreen({
    super.key, 
    required this.character,
  });

  @override
  State<CharacterProfileScreen> createState() => _CharacterProfileScreenState();
}

class _CharacterProfileScreenState extends State<CharacterProfileScreen> with SingleTickerProviderStateMixin {
  // 상태 관리
  bool _isLoading = true;
  String? _errorMessage;
  List<Achievement> _unlockedAchievements = [];
  int _completedMissions = 0;
  late TabController _tabController;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('👤 CharacterProfileScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 탭 컨트롤러 초기화
    _tabController = TabController(length: 3, vsync: this);
    
    // 데이터 로드
    _loadCharacterData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
  
  /// 캐릭터 데이터 로드
  Future<void> _loadCharacterData() async {
    _debugPrint('캐릭터 데이터 로드 중...');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 업적 및 미션 데이터 로드
      final achievements = <Achievement>[];
      var completedMissions = 0;
      
      // 클랜에 속한 모든 프로젝트를 확인
      if (widget.character.clanId != null) {
        final clan = dataService.getClanById(widget.character.clanId!);
        
        if (clan != null) {
          for (final projectId in clan.projectIds) {
            final project = dataService.getProjectById(projectId);
            
            if (project != null) {
              // 업적 수집
              for (final achievement in project.achievements) {
                if (achievement.isUnlocked && 
                    achievement.unlockedById == widget.character.id) {
                  achievements.add(achievement);
                }
              }
              
              // 완료한 미션 수 계산
              completedMissions += project.missions.where((m) => 
                  m.status == MissionStatus.completed && 
                  m.assignedToId == widget.character.id).length;
            }
          }
        }
      }
      
      setState(() {
        _unlockedAchievements = achievements;
        _completedMissions = completedMissions;
      });
      
      _debugPrint('캐릭터 데이터 로드 완료: ${achievements.length}개 업적, $_completedMissions개 미션');
    } catch (e) {
      _debugPrint('데이터 로드 오류: $e');
      
      setState(() {
        _errorMessage = '데이터를 불러오는 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    _debugPrint('로그아웃 시도');
    
    try {
      // 확인 다이얼로그
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        _debugPrint('로그아웃 취소됨');
        return;
      }
      
      // 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 로그아웃 처리
      await dataService.logout();
      
      _debugPrint('로그아웃 완료');
      
      // 로그인 화면으로 이동
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _debugPrint('로그아웃 오류: $e');
      
      // 에러 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그아웃 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// 전투 함성 변경
  Future<void> _changeBattleCry() async {
    _debugPrint('전투 함성 변경 시도');
    
    final controller = TextEditingController(text: widget.character.battleCry);
    
    try {
      // 입력 다이얼로그
      final newBattleCry = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('전투 함성 변경'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '새로운 전투 함성을 입력하세요',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('저장'),
            ),
          ],
        ),
      );
      
      if (newBattleCry == null || newBattleCry.trim().isEmpty) {
        _debugPrint('전투 함성 변경 취소됨');
        return;
      }
      
      // 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 전투 함성 업데이트
      widget.character.battleCry = newBattleCry.trim();
      await dataService.updateCharacter(widget.character);
      
      _debugPrint('전투 함성 변경 완료: $newBattleCry');
      
      // 알림 표시
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('전투 함성이 변경되었습니다'),
        ),
      );
      
      // 화면 갱신
      setState(() {});
    } catch (e) {
      _debugPrint('전투 함성 변경 오류: $e');
      
      // 에러 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('전투 함성 변경 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      controller.dispose();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('캐릭터 프로필'),
        centerTitle: true,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCharacterData,
            tooltip: '새로고침',
          ),
          
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildProfileContent(),
    );
  }
  
  /// 에러 화면 빌드
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _errorMessage ?? '알 수 없는 오류가 발생했습니다',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _loadCharacterData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 프로필 콘텐츠 빌드
  Widget _buildProfileContent() {
    return Column(
      children: [
        // 프로필 헤더
        _buildProfileHeader(),
        
        // 탭 바
        Container(
          color: AppTheme.cardColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: '정보'),
              Tab(text: '업적'),
              Tab(text: '통계'),
            ],
          ),
        ),
        
        // 탭 콘텐츠
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(),
              _buildAchievementsTab(),
              _buildStatsTab(),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 프로필 헤더 위젯
  Widget _buildProfileHeader() {
    // 레벨에 따른 직급 계산
    final level = widget.character.level;
    String rank;
    if (level >= 20) {
      rank = '전설적인 영웅';
    } else if (level >= 15) {
      rank = '위대한 영웅';
    } else if (level >= 10) {
      rank = '숙련된 모험가';
    } else if (level >= 5) {
      rank = '유망한 모험가';
    } else {
      rank = '견습 모험가';
    }
    
    // 다음 레벨까지 필요한 경험치 계산
    final currentExp = widget.character.experiencePoints;
    final nextLevelExp = widget.character.calculateNextLevelExp();
    final expProgress = currentExp / nextLevelExp;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardColor,
      child: Column(
        children: [
          // 캐릭터 아바타 및 이름
          Row(
            children: [
              // 캐릭터 아바타
              Hero(
                tag: 'character_avatar_${widget.character.id}',
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    widget.character.name.isNotEmpty ? widget.character.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 캐릭터 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름
                    Text(
                      widget.character.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 레벨과 직급
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv.${widget.character.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        Text(
                          rank,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 전문분야
                    Text(
                      '${widget.character.specialty}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 경험치 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '경험치',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '$currentExp / $nextLevelExp XP',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              LinearProgressIndicator(
                value: expProgress,
                backgroundColor: Colors.grey[300],
                color: AppTheme.primaryColor,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 전투 함성
          InkWell(
            onTap: _changeBattleCry,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '전투 함성',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    widget.character.battleCry.isEmpty 
                        ? '(전투 함성을 입력하려면 클릭하세요)' 
                        : '"${widget.character.battleCry}"',
                    style: TextStyle(
                      fontStyle: widget.character.battleCry.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: widget.character.battleCry.isEmpty
                          ? Colors.grey[500]
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 기본 정보 탭 콘텐츠
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '기본 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 아이디
                  _buildInfoRow('ID', widget.character.id),
                  
                  const Divider(),
                  
                  // 이메일
                  _buildInfoRow('이메일', widget.character.email),
                  
                  const Divider(),
                  
                  // 생성일
                  _buildInfoRow('가입일', _formatDate(widget.character.createdAt)),
                  
                  const Divider(),
                  
                  // 경험치
                  _buildInfoRow('경험치', '${widget.character.experiencePoints} XP'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 전문분야 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '전문분야',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 전문분야 정보
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getSpecialtyIcon(widget.character.specialty),
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.character.specialty}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Text(
                              _getSpecialtyDescription(widget.character.specialty),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 업적 탭 콘텐츠
  Widget _buildAchievementsTab() {
    return _unlockedAchievements.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  '아직 획득한 업적이 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '프로젝트의 미션을 완료하고 업적을 획득하세요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _unlockedAchievements.length,
            itemBuilder: (context, index) {
              final achievement = _unlockedAchievements[index];
              return _buildAchievementCard(achievement);
            },
          );
  }
  
  /// 통계 탭 콘텐츠
  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 활동 요약 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '활동 요약',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 통계 그리드
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        Icons.task_alt,
                        '$_completedMissions',
                        '완료한 미션',
                      ),
                      
                      _buildStatCard(
                        Icons.emoji_events,
                        '${_unlockedAchievements.length}',
                        '획득한 업적',
                      ),
                      
                      _buildStatCard(
                        Icons.star,
                        '${widget.character.level}',
                        '현재 레벨',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 레벨 진행도 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '레벨 진행도',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 다음 레벨 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '현재 레벨: ${widget.character.level}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      Text(
                        '다음 레벨: ${widget.character.level + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 경험치 정보 표시
                  Text(
                    '현재 경험치: ${widget.character.experiencePoints} / 다음 레벨까지: ${widget.character.calculateNextLevelExp() - widget.character.experiencePoints}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // 진행 상태 바
                  LinearProgressIndicator(
                    value: widget.character.experiencePoints / widget.character.calculateNextLevelExp(),
                    backgroundColor: Colors.grey[200],
                    color: AppTheme.primaryColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 남은 경험치 안내
                  Text(
                    '다음 레벨까지 ${widget.character.calculateNextLevelExp() - widget.character.experiencePoints} XP 남았습니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 업적 카드 위젯
  Widget _buildAchievementCard(Achievement achievement) {
    final Color backgroundColor = _getAchievementColor(achievement.tier);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      color: achievement.isUnlocked ? backgroundColor : Colors.grey.shade300,
      child: ListTile(
        leading: Icon(
          achievement.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
          color: achievement.isUnlocked ? Colors.white : Colors.grey.shade700,
          size: 32.0,
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            color: achievement.isUnlocked ? Colors.white : Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: TextStyle(
                color: achievement.isUnlocked ? Colors.white.withOpacity(0.9) : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${achievement.tier.name} (+${achievement.experienceReward} XP)',
              style: TextStyle(
                color: achievement.isUnlocked ? Colors.white70 : Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null)
              Text(
                '획득: ${_formatDate(achievement.unlockedAt!)}',
                style: TextStyle(
                  color: achievement.isUnlocked ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// 통계 카드 위젯
  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 28,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// 날짜 포맷 반환
  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy년 MM월 dd일');
    return formatter.format(date);
  }
  
  /// 업적 등급별 색상 가져오기
  Color _getAchievementColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Colors.brown.shade400;
      case AchievementTier.silver:
        return Colors.blueGrey.shade400;
      case AchievementTier.gold:
        return Colors.amber.shade600;
      case AchievementTier.platinum:
        return Colors.blueGrey.shade700;
      case AchievementTier.diamond:
        return Colors.lightBlue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
  
  // 전문분야별 아이콘 헬퍼 함수
  IconData _getSpecialtyIcon(CharacterSpecialty specialty) {
    switch (specialty) {
      case CharacterSpecialty.warrior:
        return Icons.shield;
      case CharacterSpecialty.mage:
        return Icons.auto_fix_high;
      case CharacterSpecialty.ranger:
        return Icons.gps_fixed;
      case CharacterSpecialty.rogue:
        return Icons.nights_stay;
      case CharacterSpecialty.cleric:
        return Icons.healing;
      case CharacterSpecialty.healer:
        return Icons.favorite;
      case CharacterSpecialty.scout:
        return Icons.explore;
      case CharacterSpecialty.leader:
        return Icons.emoji_events;
      default:
        return Icons.person;
    }
  }
  
  // 전문분야별 설명 헬퍼 함수
  String _getSpecialtyDescription(CharacterSpecialty specialty) {
    switch (specialty) {
      case CharacterSpecialty.warrior:
        return '어려운 과제를 정면으로 맞서 해결합니다';
      case CharacterSpecialty.mage:
        return '창의적인 방법으로 문제를 해결합니다';
      case CharacterSpecialty.healer:
        return '팀의 사기를 높이고 문제를 중재합니다';
      case CharacterSpecialty.scout:
        return '정보를 수집하고 미래를 예측합니다';
      case CharacterSpecialty.ranger:
        return '야생을 탐험하고 정보를 수집합니다';
      case CharacterSpecialty.rogue:
        return '전투 중에 무작정 도망치거나 적을 속이는 기술을 사용합니다';
      case CharacterSpecialty.cleric:
        return '팀원들을 치유하고 성스러운 힘을 부여합니다';
      case CharacterSpecialty.leader:
        return '클랜을 이끌고 방향성을 제시합니다';
      default:
        return '다양한 능력으로 문제를 해결합니다';
    }
  }

  /// 레벨 정보 그리기
  Widget _buildLevelInfo() {
    const double progressHeight = 12.0;
    final currentExp = widget.character.experiencePoints;
    final nextLevelExp = widget.character.calculateNextLevelExp();
    
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '레벨 ${widget.character.level}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  '${currentExp} / ${currentExp + nextLevelExp} XP',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                // 진행률 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(progressHeight / 2),
                  child: LinearProgressIndicator(
                    value: nextLevelExp > 0 ? (nextLevelExp - widget.character.experienceToNextLevel) / nextLevelExp : 0,
                    minHeight: progressHeight,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.experienceColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 