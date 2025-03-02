import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../theme/app_theme.dart';
import '../services/tutorial_manager.dart';
import 'login_screen.dart';

/// 스플래시 화면
/// 앱 시작 시 보여지는 첫 화면으로, 앱의 로딩을 담당하며 중세 판타지 테마로 앱의 분위기를 설정합니다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  
  // 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🌟 SplashScreen: $message');
  }

  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 애니메이션 컨트롤러 설정
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 불투명도 애니메이션
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    // 크기 애니메이션
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    _controller.forward();
    
    // 3초 후 다음 화면으로 이동
    Timer(const Duration(seconds: 3), () {
      _debugPrint('다음 화면으로 이동 중...');
      _checkTutorialStatus();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
  
  /// 튜토리얼 상태 확인
  Future<void> _checkTutorialStatus() async {
    final tutorialManager = TutorialManager.instance;
    await tutorialManager.initialize();
    
    final shouldShowTutorial = await tutorialManager.shouldShowAppTutorial();
    _debugPrint('튜토리얼 표시 여부: $shouldShowTutorial');
    
    if (shouldShowTutorial) {
      // 튜토리얼을 아직 완료하지 않았으면 튜토리얼 표시
      await tutorialManager.showAppTutorial(context);
      // 튜토리얼 완료 후 로그인 화면으로 이동
      _navigateToLogin();
    } else {
      // 이미 튜토리얼을 완료했으면 바로 로그인 화면으로 이동
      _navigateToLogin();
    }
  }
  
  /// 로그인 화면으로 이동
  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _debugPrint('빌드 중...');
    
    // 화면 비율 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 배경 장식 - 양피지 질감
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  // 여기에 실제 양피지 이미지를 넣을 수 있습니다
                ),
              ),
              
              // 중앙 콘텐츠
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 로고/아이콘 영역
                      Opacity(
                        opacity: _opacityAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: screenWidth * 0.4,
                            height: screenWidth * 0.4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shield_outlined,
                                size: screenWidth * 0.25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.03),
                      
                      // 앱 이름 텍스트
                      Opacity(
                        opacity: _opacityAnimation.value,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Family Choi Chronicles',
                              textStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.05,
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.02),
                      
                      // 부제목
                      Opacity(
                        opacity: _opacityAnimation.value,
                        child: Text(
                          '일상을 모험으로, 과제를 퀘스트로',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textColor,
                            fontStyle: FontStyle.italic,
                            fontSize: screenWidth * 0.03,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.05),
                      
                      // 로딩 인디케이터
                      Opacity(
                        opacity: _opacityAnimation.value,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
              
              // 하단 버전 정보
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Text(
                    'v1.0.0-alpha',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 