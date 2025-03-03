import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../models/clan.dart';
import '../models/project.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'character_profile_screen.dart';
import 'project_detail_screen.dart';
import 'create_project_screen.dart';
import 'clan_members_screen.dart';
import 'settings_screen.dart';

/// 클랜 대시보드 화면
/// 클랜의 프로젝트 목록과 클랜 정보를 보여주는 메인 화면입니다.
class ClanDashboardScreen extends StatefulWidget {
  final Character character;
  
  const ClanDashboardScreen({
    super.key, 
    required this.character,
  });

  @override
  State<ClanDashboardScreen> createState() => _ClanDashboardScreenState();
}

class _ClanDashboardScreenState extends State<ClanDashboardScreen> {
  // 상태 관리
  bool _isLoading = true;
  String? _errorMessage;
  Clan? _clan;
  List<Project> _projects = [];
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  
  late MockDataService _mockDataService;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🏰 ClanDashboardScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 서비스 초기화
    _mockDataService = MockDataService();
    
    // 데이터 로드
    _loadData();
  }
  
  /// 클랜 및 프로젝트 데이터 로드
  Future<void> _loadData() async {
    _debugPrint('데이터 로드 중...');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 서비스 가져오기
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 캐릭터 정보 확인
      if (widget.character.clanId == null) {
        throw Exception('캐릭터가 클랜에 속해있지 않습니다');
      }
      
      // 클랜 정보 로드
      final clan = dataService.getClanById(widget.character.clanId!);
      if (clan == null) {
        throw Exception('클랜 정보를 찾을 수 없습니다');
      }
      
      // 프로젝트 목록 로드
      final projects = <Project>[];
      for (final projectId in clan.projectIds) {
        final project = dataService.getProjectById(projectId);
        if (project != null) {
          projects.add(project);
        }
      }
      
      setState(() {
        _clan = clan;
        _projects = projects;
      });
      
      _debugPrint('클랜 데이터 로드 완료: ${clan.name}, 프로젝트 ${projects.length}개');
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
  
  /// 프로젝트 생성 화면으로 이동
  void _navigateToCreateProject() {
    _debugPrint('프로젝트 생성 화면으로 이동');
    
    if (_clan == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateProjectScreen(
          character: widget.character,
          clan: _clan!,
        ),
      ),
    ).then((_) {
      // 화면이 돌아오면 데이터 다시 로드
      _loadData();
    });
  }
  
  /// 프로젝트 상세 화면으로 이동
  void _navigateToProjectDetail(Project project) {
    _debugPrint('프로젝트 상세 화면으로 이동: ${project.name}');
    
    if (_clan == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(
          character: widget.character,
          project: project,
          clan: _clan!,
        ),
      ),
    ).then((_) {
      // 화면이 돌아오면 데이터 다시 로드
      _loadData();
    });
  }
  
  /// 클랜 멤버 화면으로 이동
  void _navigateToClanMembers() {
    // 이 함수는 이제 PageView로 대체되어 사용하지 않습니다.
  }
  
  /// 캐릭터 프로필 화면으로 이동
  void _navigateToCharacterProfile(Character selectedCharacter) {
    if (selectedCharacter.id != widget.character.id) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CharacterProfileScreen(
            character: selectedCharacter,
            isUserCharacter: false,
          ),
        ),
      );
    }
  }
  
  /// 하단 탭 변경 처리
  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // 설정 페이지는 별도 화면으로 이동
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      ).then((_) {
        // 설정 화면에서 돌아오면 이전 탭으로 복원
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading 
            ? const Text('로딩 중...') 
            : Text('${_clan?.name ?? '대시보드'}'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _errorMessage != null
              ? _buildErrorView()
              : _clan == null
                  ? const Center(child: Text('클랜 정보를 찾을 수 없습니다'))
                  : PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      children: [
                        _buildClanDashboard(),
                        _buildClanMembersScreen(),
                        _buildProfileScreen(),
                      ],
                    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '멤버',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
      floatingActionButton: _clan != null && _selectedIndex == 0 ? FloatingActionButton(
        onPressed: _navigateToCreateProject,
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.secondaryColor,
      ) : null,
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
              onPressed: _loadData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 클랜 대시보드 화면 빌드
  Widget _buildClanDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // 클랜 정보 헤더
          SliverToBoxAdapter(
            child: _buildClanHeader(),
          ),
          
          // 프로젝트 목록 헤더
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Projects (${_projects.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // 정렬 버튼 (기능 확장 시 추가)
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () {
                      // 정렬 기능 (차후 구현)
                    },
                    tooltip: 'Sort',
                  ),
                ],
              ),
            ),
          ),
          
          // 프로젝트 목록 또는 빈 상태
          _projects.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyProjectsView(),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = _projects[index];
                        return _buildProjectCard(project);
                      },
                      childCount: _projects.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
  
  /// 클랜 정보 헤더 위젯
  Widget _buildClanHeader() {
    if (_clan == null) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 클랜 이름과 아이콘
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _clan!.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        'Founded: ${_formatDate(_clan!.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 초대 코드 복사 버튼
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // 초대 코드 복사 기능 (클립보드 액세스 필요)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invite code copied: ${_clan!.inviteCode}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Copy Invite Code',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 클랜 설명
            Text(
              _clan!.description,
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 16),
            
            // 클랜 통계
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.people,
                  '${_clan!.memberIds.length}',
                  'Members',
                ),
                
                _buildStatItem(
                  Icons.folder,
                  '${_clan!.projectIds.length}',
                  'Projects',
                ),
                
                _buildStatItem(
                  Icons.task_alt,
                  '0',
                  'Completed Missions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 통계 아이템 위젯
  Widget _buildStatItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        
        const SizedBox(height: 4),
        
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  /// 프로젝트 카드 위젯
  Widget _buildProjectCard(Project project) {
    // 미션 진행 상황 계산
    final completedMissions = project.missions.where((m) => m.status == MissionStatus.completed).length;
    final totalMissions = project.missions.length;
    final progress = totalMissions > 0 ? completedMissions / totalMissions : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToProjectDetail(project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로젝트 이름
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // 프로젝트 생성일
                  Text(
                    _formatDate(project.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 프로젝트 설명
              Text(
                project.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // 미션 진행도
              Row(
                children: [
                  const Icon(
                    Icons.assignment,
                    size: 16,
                    color: Colors.grey,
                  ),
                  
                  const SizedBox(width: 4),
                  
                  Text(
                    'Missions: $completedMissions/$totalMissions',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 진행 상태 바
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: AppTheme.primaryColor,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 프로젝트가 없을 때 표시할 화면
  Widget _buildEmptyProjectsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 72,
              color: Colors.grey[400],
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Create your first project to start your adventure!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _navigateToCreateProject,
              icon: const Icon(Icons.add),
              label: const Text('Add New Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 프로필 화면 위젯 구성
  Widget _buildProfileScreen() {
    return CharacterProfileScreen(
      character: widget.character,
      isUserCharacter: true,
    );
  }
  
  /// 클랜 멤버 화면 위젯 구성
  Widget _buildClanMembersScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clan Members',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_clan!.memberIds.isEmpty)
              const Center(
                child: Text('No members in the clan.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _clan!.memberIds.length,
                itemBuilder: (context, index) {
                  final characterId = _clan!.memberIds[index];
                  // 캐릭터 정보 가져오기
                  final character = _mockDataService.getCharacterById(characterId);
                  if (character == null) {
                    return const ListTile(
                      title: Text('Unknown character'),
                    );
                  }
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(character.name),
                      subtitle: Text('Level ${character.level} ${character.specialty.displayName}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToCharacterProfile(character),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  // 날짜 포맷 지원 함수
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
} 