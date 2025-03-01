import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/mock_data_service.dart';
import 'character_creation_screen.dart';
import 'clan_dashboard_screen.dart';

/// 로그인 화면
/// 사용자가 앱에 로그인하거나 회원가입할 수 있는 화면입니다.
/// 파이어베이스 연동 전까지는 임시 인증으로 구현합니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // 폼 키
  final _formKey = GlobalKey<FormState>();
  
  // 텍스트 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 애니메이션 컨트롤러
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  
  // 로그인 상태
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🔐 LoginScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    // 개발용 기본값
    _emailController.text = 'choi@familyquest.com';
    _passwordController.text = 'password123';
    
    // 애니메이션 설정
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 페이드인 애니메이션
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
  
  /// 로그인 처리
  Future<void> _login() async {
    _debugPrint('로그인 시도: ${_emailController.text}');
    
    // 폼 검증
    if (!_formKey.currentState!.validate()) {
      _debugPrint('폼 검증 실패');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 임시 로그인 처리 (Firebase 대체)
      await Future.delayed(const Duration(seconds: 1));
      
      // 테스트 이메일/비밀번호 확인
      if (_emailController.text == 'choi@familyquest.com' && 
          _passwordController.text == 'password123') {
        
        _debugPrint('로그인 성공');
        
        // 임시 사용자 ID 생성
        final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        
        // 데이터 서비스 가져오기
        final dataService = Provider.of<MockDataService>(context, listen: false);
        
        // 사용자 캐릭터 조회
        final character = dataService.getCharacterByUserId(userId);
        
        // 샘플 데이터 생성
        if (character == null) {
          await dataService.createSampleData();
          _debugPrint('샘플 데이터 생성됨');
        }
        
        // 캐릭터가 있으면 대시보드로, 없으면 캐릭터 생성 화면으로
        if (!mounted) return;
        
        if (character == null) {
          // 캐릭터 생성 화면으로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => CharacterCreationScreen(userId: userId),
            ),
          );
        } else {
          // 클랜 대시보드로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ClanDashboardScreen(character: character),
            ),
          );
        }
      } else {
        _debugPrint('로그인 실패: 잘못된 이메일 또는 비밀번호');
        setState(() {
          _errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
        });
      }
    } catch (e) {
      _debugPrint('로그인 오류: $e');
      setState(() {
        _errorMessage = '로그인 처리 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 비밀번호 가시성 전환
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    _debugPrint('빌드 중...');
    
    // 화면 크기 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              height: screenHeight - MediaQuery.of(context).padding.top - 24,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    
                    // 상단 로고 및 제목
                    Center(
                      child: Icon(
                        Icons.shield,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Family Choi Chronicles',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      '모험의 세계로 로그인하세요',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.08),
                    
                    // 에러 메시지
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 20),
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
                    
                    // 이메일 필드
                    _buildTextField(
                      controller: _emailController,
                      hintText: '이메일',
                      labelText: '이메일 주소',
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        if (!value.contains('@')) {
                          return '유효한 이메일 주소를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 비밀번호 필드
                    _buildTextField(
                      controller: _passwordController,
                      hintText: '비밀번호',
                      labelText: '비밀번호',
                      prefixIcon: Icons.lock,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        if (value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 비밀번호 찾기
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _debugPrint('비밀번호 찾기 클릭');
                        },
                        child: Text(
                          '비밀번호를 잊으셨나요?',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.05),
                    
                    // 로그인 버튼
                    _buildStyledButton(
                      text: '모험 시작하기',
                      onPressed: _isLoading ? null : _login,
                      isLoading: _isLoading,
                      primaryColor: AppTheme.primaryColor,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 회원가입 안내
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('계정이 없으신가요?', style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () {
                            _debugPrint('회원가입 클릭');
                            // TODO: 회원가입 화면으로 이동
                          },
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // 푸터 텍스트
                    Text(
                      '© 2023 Family Choi Chronicles',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 텍스트 필드 위젯 생성
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: AppTheme.primaryColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }
  
  /// 스타일된 버튼 생성
  Widget _buildStyledButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    required Color primaryColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
} 