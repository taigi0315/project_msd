import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/mock_data_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  // 앱 초기화 전 에러 캐치
  WidgetsFlutterBinding.ensureInitialized();
  
  // 앱의 시작을 알리는 디버그 메시지
  debugPrint('🚀 Family Choi Chronicles 앱 시작 중...');
  
  try {
    // Hive 초기화
    await Hive.initFlutter();
    debugPrint('📦 Hive 초기화 완료');
    
    // MockDataService 초기화
    final dataService = MockDataService();
    await dataService.initialize();
    debugPrint('🔄 MockDataService 초기화 완료');
    
    // 시스템 UI 설정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // 앱 실행
    runApp(
      MultiProvider(
        providers: [
          Provider<MockDataService>.value(value: dataService),
        ],
        child: const MyApp(),
      ),
    );
    
    debugPrint('🎮 앱이 성공적으로 시작되었습니다.');
  } catch (e, stackTrace) {
    debugPrint('❌ 앱 초기화 중 오류 발생: $e');
    debugPrint('스택 트레이스: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ 앱 기본 구조 빌드 중...');
    
    return MaterialApp(
      title: 'Family Choi Chronicles',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: const SplashScreen(),
    );
  }
}
