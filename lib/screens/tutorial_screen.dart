import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// 앱 튜토리얼 화면
/// 앱의 주요 기능 사용법을 단계별로 안내합니다.
class TutorialScreen extends StatefulWidget {
  /// 튜토리얼 완료 후 콜백
  final VoidCallback? onComplete;
  
  const TutorialScreen({super.key, this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  // 현재 튜토리얼 페이지 인덱스
  int _currentPage = 0;
  
  // 페이지 컨트롤러
  final PageController _pageController = PageController();
  
  // 튜토리얼 페이지 데이터
  final List<TutorialPage> _pages = [
    TutorialPage(
      title: '가족 프로젝트 앱에 오신 것을 환영합니다!',
      description: '이 앱은 가족 프로젝트를 관리하고 재미있게 수행할 수 있도록 도와줍니다. RPG 게임처럼 미션을 완료하고 경험치를 얻어 성장해보세요.',
      imagePath: 'assets/images/tutorial_welcome.png',
      icon: Icons.flight_takeoff,
    ),
    TutorialPage(
      title: '캐릭터 생성하기',
      description: '자신만의 캐릭터를 만들고 특성을 선택하세요. 각 특성은 다른 능력을 가지고 있으며, 플레이 스타일에 영향을 줍니다.',
      imagePath: 'assets/images/tutorial_character.png',
      icon: Icons.person,
    ),
    TutorialPage(
      title: '클랜 가입하기',
      description: '가족 클랜을 만들거나 가입하세요. 클랜 멤버들과 함께 프로젝트를 수행하고 가족의 역사를 만들어갑니다.',
      imagePath: 'assets/images/tutorial_clan.png',
      icon: Icons.people,
    ),
    TutorialPage(
      title: '프로젝트 생성하기',
      description: 'AI의 도움을 받아 창의적인 프로젝트를 만들고, 미션과 업적을 설정하세요. 각 미션은 경험치를 제공합니다.',
      imagePath: 'assets/images/tutorial_project.png',
      icon: Icons.assignment,
    ),
    TutorialPage(
      title: '미션 완료하기',
      description: '미션을 완료하면 경험치를 얻고 레벨업할 수 있습니다. 레벨업하면 스킬이 향상되고 새로운 능력을 얻을 수 있습니다.',
      imagePath: 'assets/images/tutorial_mission.png',
      icon: Icons.task_alt,
    ),
    TutorialPage(
      title: '준비 완료!',
      description: '이제 Family Choi Chronicles를 시작할 준비가 되었습니다. 가족과 함께 재미있는 모험을 떠나보세요!',
      imagePath: 'assets/images/tutorial_ready.png',
      icon: Icons.celebration,
    ),
  ];
  
  // 디버깅을 위한 출력
  void _debugPrint(String message) {
    debugPrint('📚 TutorialScreen: $message');
  }

  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 튜토리얼 시작 로그
    _debugPrint('튜토리얼 시작: 총 ${_pages.length}개 페이지');
    
    // 마지막으로 본 페이지 인덱스 로드
    _loadLastPage();
  }
  
  /// 마지막으로 본 페이지 인덱스 로드
  Future<void> _loadLastPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt('tutorial_last_page') ?? 0;
      
      if (lastPage > 0 && lastPage < _pages.length) {
        setState(() {
          _currentPage = lastPage;
        });
        _pageController.jumpToPage(lastPage);
      }
    } catch (e) {
      _debugPrint('마지막 페이지 로드 중 오류 발생: $e');
    }
  }
  
  /// 마지막으로 본 페이지 인덱스 저장
  Future<void> _saveLastPage(int page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tutorial_last_page', page);
    } catch (e) {
      _debugPrint('마지막 페이지 저장 중 오류 발생: $e');
    }
  }
  
  /// 튜토리얼 완료
  void _completeTutorial() async {
    _debugPrint('튜토리얼 완료');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_completed', true);
      
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    } catch (e) {
      _debugPrint('튜토리얼 완료 상태 저장 중 오류 발생: $e');
    }
  }
  
  /// 다음 페이지로 이동
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }
  
  /// 이전 페이지로 이동
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// 건너뛰기
  void _skipTutorial() {
    _debugPrint('튜토리얼 건너뛰기');
    _completeTutorial();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 건너뛰기 버튼
                  TextButton(
                    onPressed: _skipTutorial,
                    child: const Text(
                      '건너뛰기',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // 페이지 인디케이터
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? AppTheme.primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 튜토리얼 페이지
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _saveLastPage(index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 아이콘
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 이미지
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                page.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      page.icon,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 제목
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 설명
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // 하단 네비게이션
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 이전 버튼
                  IconButton(
                    onPressed: _currentPage > 0 ? _previousPage : null,
                    icon: const Icon(Icons.arrow_back),
                    color: _currentPage > 0 ? AppTheme.primaryColor : Colors.grey,
                  ),
                  
                  // 다음/완료 버튼
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? '다음' : '시작하기',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
}

/// 튜토리얼 페이지 데이터 클래스
class TutorialPage {
  /// 페이지 제목
  final String title;
  
  /// 페이지 설명
  final String description;
  
  /// 이미지 경로
  final String imagePath;
  
  /// 아이콘
  final IconData icon;
  
  TutorialPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
} 