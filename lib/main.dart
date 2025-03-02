import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/mock_data_service.dart';
import 'screens/splash_screen.dart';
import 'services/game_effects_service.dart';
import 'services/tutorial_manager.dart';

void main() async {
  // Catch errors before initialization
  WidgetsFlutterBinding.ensureInitialized();
  
  // Epic launch sequence debug message
  debugPrint('🚀 EPIC LAUNCH SEQUENCE INITIATED! Family Choi Chronicles is powering up...');
  
  try {
    // Hive initialization
    await Hive.initFlutter();
    debugPrint('📦 Treasure chests (Hive) loaded and ready for loot!');
    
    // MockDataService initialization
    final dataService = MockDataService();
    await dataService.initialize();
    debugPrint('🔄 Mock Data Service has entered the chat! Ready to serve fake goodies.');
    
    // GameEffectsService initialization
    await GameEffectsService().initialize();
    debugPrint('🔄 Game Effects Service is locked and loaded! Prepare for awesomeness!');
    
    // Tutorial manager initialization
    await TutorialManager.instance.initialize();
    
    // System UI configuration - portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Run the app
    runApp(
      MultiProvider(
        providers: [
          Provider<MockDataService>.value(value: dataService),
        ],
        child: const MyApp(),
      ),
    );
    
    debugPrint('🎮 App has successfully launched! Let the epic questing begin!');
  } catch (e, stackTrace) {
    debugPrint('❌ Oopsie woopsie! App crashed during startup: $e');
    debugPrint('Stack trace of doom: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ Building the most EPIC app structure ever...');
    
    return MaterialApp(
      title: 'Family Choi Chronicles',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: const SplashScreen(),
    );
  }
}
