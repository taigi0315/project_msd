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
      title: 'Welcome to the Family Project App!',
      description: 'This app helps you manage family projects in a fun way. Like RPG games, complete missions to earn experience points and grow.',
      imagePath: 'assets/images/tutorial_welcome.png',
      icon: Icons.flight_takeoff,
    ),
    TutorialPage(
      title: 'Create Your Character',
      description: 'Create your own character and choose your specialty. Each specialty has different abilities that affect your play style.',
      imagePath: 'assets/images/tutorial_character.png',
      icon: Icons.person,
    ),
    TutorialPage(
      title: 'Join a Clan',
      description: 'Create or join a family clan. Work together with clan members on projects and create family history.',
      imagePath: 'assets/images/tutorial_clan.png',
      icon: Icons.people,
    ),
    TutorialPage(
      title: 'Create Projects',
      description: 'Create creative projects with AI assistance, and set missions and achievements. Each mission provides experience points.',
      imagePath: 'assets/images/tutorial_project.png',
      icon: Icons.assignment,
    ),
    TutorialPage(
      title: 'Complete Missions',
      description: 'Complete missions to earn experience points and level up. When you level up, your skills improve and you gain new abilities.',
      imagePath: 'assets/images/tutorial_mission.png',
      icon: Icons.task_alt,
    ),
    TutorialPage(
      title: 'Ready to Go!',
      description: 'Now you\'re ready to start Family Choi Chronicles. Embark on an exciting adventure with your family!',
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
    _debugPrint('Initializing...');
    
    // 튜토리얼 시작 로그
    _debugPrint('Tutorial started: ${_pages.length} pages total');
    
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
      _debugPrint('Error loading last page: $e');
    }
  }
  
  /// 마지막으로 본 페이지 인덱스 저장
  Future<void> _saveLastPage(int page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tutorial_last_page', page);
    } catch (e) {
      _debugPrint('Error saving last page: $e');
    }
  }
  
  /// 튜토리얼 완료
  void _completeTutorial() async {
    _debugPrint('Tutorial completed');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_completed', true);
      
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    } catch (e) {
      _debugPrint('Error saving tutorial completion status: $e');
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
    _debugPrint('Skipping tutorial');
    _completeTutorial();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _debugPrint('Resources released');
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
                      'Skip',
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
                      _currentPage < _pages.length - 1 ? 'Next' : 'Start',
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