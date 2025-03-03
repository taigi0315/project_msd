import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/mock_data_service.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
import 'clan_selection_screen.dart';
import '../services/game_effects_service.dart';
import '../models/game_sound.dart';

/// Character Questionnaire Screen
/// This screen presents 7 fun questions to the user, collects their responses,
/// and creates an AI-generated D&D-style character profile!
class CharacterQuestionnaireScreen extends StatefulWidget {
  final String userId;
  
  const CharacterQuestionnaireScreen({
    super.key, 
    required this.userId,
  });

  @override
  State<CharacterQuestionnaireScreen> createState() => _CharacterQuestionnaireScreenState();
}

class _CharacterQuestionnaireScreenState extends State<CharacterQuestionnaireScreen> {
  // Page controller
  final PageController _pageController = PageController();
  
  // Current question index
  int _currentIndex = 0;
  
  // User responses storage
  final List<String> _responses = List.filled(7, '');
  
  // Question controllers
  final List<TextEditingController> _controllers = 
      List.generate(7, (_) => TextEditingController());
  
  // Loading states
  bool _isLoading = false;
  bool _isGeneratingCharacter = false;
  
  // Generated character info
  String _characterName = '';
  CharacterSpecialty _characterSpecialty = CharacterSpecialty.leader;
  String _battleCry = '';
  
  // D&D character data
  Map<String, dynamic>? _dndCharacterData;
  
  // Debug output helper
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('📝 CharacterQuestionnaireScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('Initializing questionnaire...');
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    _debugPrint('Resources released');
    super.dispose();
  }
  
  /// Move to next question
  void _nextQuestion() {
    _debugPrint('Moving to next question: ${_currentIndex + 1}');
    
    // Save current response
    _responses[_currentIndex] = _controllers[_currentIndex].text;
    
    if (_responses[_currentIndex].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! Please answer the question before continuing!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_currentIndex < _questions.length - 1) {
      // Move to next question
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex++;
      });
    } else {
      // All questions completed, generate character
      _generateCharacter();
    }
  }
  
  /// Move to previous question
  void _prevQuestion() {
    _debugPrint('Moving to previous question: ${_currentIndex - 1}');
    
    // Save current response
    _responses[_currentIndex] = _controllers[_currentIndex].text;
    
    if (_currentIndex > 0) {
      // Move to previous question
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex--;
      });
    }
  }
  
  /// Generate character using AI
  Future<void> _generateCharacter() async {
    _debugPrint('Summoning your character from the digital realm...');
    
    // Check all responses
    for (int i = 0; i < _responses.length; i++) {
      _responses[i] = _controllers[i].text;
      if (_responses[i].isEmpty) {
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hold up! You need to answer ALL the questions!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    setState(() {
      _isGeneratingCharacter = true;
    });
    
    try {
      // Initialize OpenAI service
      final openAIService = OpenAIService();
      await openAIService.initialize();
      
      // Generate basic character info
      final prompt = _buildPrompt();
      _debugPrint('AI prompt created');
      
      // Use AI to generate character info
      final result = await openAIService.generateCharacterFromResponses(prompt);
      _debugPrint('AI response received: $result');
      
      // Parse results
      final parsedResult = _parseAIResult(result);
      
      setState(() {
        _characterName = parsedResult['name'] ?? 'Adventurer';
        _characterSpecialty = _parseSpecialty(parsedResult['specialty'] ?? 'leader');
        _battleCry = parsedResult['battleCry'] ?? 'Let the adventure begin!';
      });
      
      // Try to generate D&D style character
      final dndCharacterData = await openAIService.generateDnDCharacter(_responses);
      _debugPrint('D&D character generated: ${dndCharacterData['class_name']}');
      
      setState(() {
        _isGeneratingCharacter = false;
      });
      
      // Show D&D character confirmation dialog
      _showCharacterDialog(dndCharacterData);
      
    } catch (e) {
      _debugPrint('Character generation error: $e');
      
      setState(() {
        _isGeneratingCharacter = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops! Something went wrong: $e'),
          backgroundColor: Colors.red,
        ), 
      );
    }
  }
  
  /// Parse AI response
  Map<String, String> _parseAIResult(String result) {
    final Map<String, String> parsedResult = {};
    
    try {
      final lines = result.split('\n');
      for (final line in lines) {
        if (line.contains(':')) {
          final parts = line.split(':');
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join(':').trim();
          
          if (key == 'name' || key == 'charactername') {
            parsedResult['name'] = value;
          } else if (key == 'specialty' || key == 'class') {
            parsedResult['specialty'] = value;
          } else if (key == 'battlecry' || key == 'motto') {
            parsedResult['battleCry'] = value;
          }
        }
      }
    } catch (e) {
      _debugPrint('AI response parsing error: $e');
    }
    
    return parsedResult;
  }
  
  /// Convert specialty string to enum
  CharacterSpecialty _parseSpecialty(String specialtyStr) {
    final normalizedStr = specialtyStr.toLowerCase();
    
    if (normalizedStr.contains('leader') || normalizedStr.contains('leader')) {
      return CharacterSpecialty.leader;
    } else if (normalizedStr.contains('warrior') || normalizedStr.contains('warrior')) {
      return CharacterSpecialty.warrior;
    } else if (normalizedStr.contains('mage') || normalizedStr.contains('mage')) {
      return CharacterSpecialty.mage;
    } else if (normalizedStr.contains('healer') || normalizedStr.contains('healer')) {
      return CharacterSpecialty.healer;
    } else if (normalizedStr.contains('scout') || normalizedStr.contains('scout')) {
      return CharacterSpecialty.scout;
    } else if (normalizedStr.contains('ranger') || normalizedStr.contains('ranger')) {
      return CharacterSpecialty.ranger;
    } else if (normalizedStr.contains('rogue') || normalizedStr.contains('rogue')) {
      return CharacterSpecialty.rogue;
    } else if (normalizedStr.contains('cleric') || normalizedStr.contains('cleric')) {
      return CharacterSpecialty.cleric;
    } else {
      // Default value
      return CharacterSpecialty.leader;
    }
  }
  
  /// Build prompt
  String _buildPrompt() {
    final buffer = StringBuffer();
    
    buffer.writeln('Create a fantasy RPG character based on the user\'s responses to the following questions:');
    buffer.writeln('');
    
    for (int i = 0; i < _questions.length; i++) {
      buffer.writeln('Question ${i + 1}: ${_questions[i].question}');
      buffer.writeln('Response: ${_responses[i]}');
      buffer.writeln('');
    }
    
    buffer.writeln('Analyze the responses and generate character info in this format:');
    buffer.writeln('1. Character Name: [fantasy name reflecting personality and values]');
    buffer.writeln('2. Specialty: [leader, warrior, mage, healer, scout, ranger, rogue, or cleric]');
    buffer.writeln('3. Battle Cry: [a short battle cry or motto reflecting the character\'s personality]');
    
    return buffer.toString();
  }
  
  /// D&D character confirmation dialog
  void _showCharacterDialog(Map<String, dynamic> characterData) {
    // Save D&D character data
    _dndCharacterData = characterData;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A3A65),
                Color(0xFF14213D),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sparkling effects at top
                  SizedBox(
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                        Positioned(
                          left: 50,
                          top: 10,
                          child: Icon(Icons.star, color: Colors.amberAccent, size: 18),
                        ),
                        Positioned(
                          right: 60,
                          top: 5,
                          child: Icon(Icons.star, color: Colors.amber[200], size: 14),
                        ),
                        Positioned(
                          right: 40,
                          bottom: 10,
                          child: Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 16),
                        ),
                      ],
                    ),
                  ),
                  
                  // Header
                  Center(
                    child: Text(
                      'BEHOLD! YOUR HERO IS BORN!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Character class & specialty
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.4),
                          AppTheme.primaryColor.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Character class icon based on class name
                        _buildClassIcon(characterData['class_name']),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          characterData['class_name'].toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          characterData['specialty'],
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Skills header with icon
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'EPIC SKILLS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Skills list
                  ...List.generate(
                    (characterData['skills'] as List).length,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.secondaryColor,
                                Color(0xFFF3B02D),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.secondaryColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          characterData['skills'][index],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Battle cry
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFC9912E).withOpacity(0.4),
                          Color(0xFFE2A82F).withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.secondaryColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.record_voice_over, color: AppTheme.secondaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'BATTLE CRY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${characterData['battle_cry']}",
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Start over
                          _pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          setState(() {
                            _currentIndex = 0;
                            for (var controller in _controllers) {
                              controller.clear();
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white60),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'RETRY',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Go to character confirmation dialog
                          _showConfirmationDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 8,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Character save confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A3A65),
                Color(0xFF14213D),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with icon
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 36,
                      color: Colors.amber,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Center(
                  child: Text(
                    'YOUR CHARACTER IS READY!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Character details in stylized cards
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Name
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.amber, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'NAME:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _characterName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      
                      Divider(color: Colors.white12, height: 24),
                      
                      // Role
                      Row(
                        children: [
                          Icon(Icons.style, color: Colors.amber, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'ROLE:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _characterSpecialty.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      
                      Divider(color: Colors.white12, height: 24),
                      
                      // Battle Cry
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.record_voice_over, color: Colors.amber, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'BATTLE CRY:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "$_battleCry",
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Message
                Center(
                  child: Text(
                    'Ready to begin your epic adventure?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Start Over button
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Start over
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          _currentIndex = 0;
                          for (var controller in _controllers) {
                            controller.clear();
                          }
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white60),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'START OVER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Begin Adventure button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _saveCharacterAndNavigate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 8,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'BEGIN ADVENTURE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.map, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 캐릭터 클래스에 기반한 아이콘 생성
  Widget _buildClassIcon(String className) {
    IconData iconData;
    Color iconColor;
    
    // 클래스 이름에 따라 적절한 아이콘 선택
    final lowerClassName = className.toLowerCase();
    if (lowerClassName.contains('wizard') || lowerClassName.contains('mage')) {
      iconData = Icons.auto_fix_high;
      iconColor = Colors.lightBlue;
    } else if (lowerClassName.contains('warrior') || lowerClassName.contains('fighter')) {
      iconData = Icons.security;
      iconColor = Colors.redAccent;
    } else if (lowerClassName.contains('rogue') || lowerClassName.contains('thief')) {
      iconData = Icons.flash_on;
      iconColor = Colors.purpleAccent;
    } else if (lowerClassName.contains('ranger') || lowerClassName.contains('hunter')) {
      iconData = Icons.track_changes;
      iconColor = Colors.green;
    } else if (lowerClassName.contains('cleric') || lowerClassName.contains('priest')) {
      iconData = Icons.healing;
      iconColor = Colors.amber;
    } else if (lowerClassName.contains('bard') || lowerClassName.contains('singer')) {
      iconData = Icons.music_note;
      iconColor = Colors.pinkAccent;
    } else {
      iconData = Icons.stars;
      iconColor = Colors.amber;
    }
    
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          size: 36,
          color: iconColor,
        ),
      ),
    );
  }
  
  /// Save generated character and navigate
  Future<void> _saveCharacterAndNavigate() async {
    _debugPrint('Saving character and moving to next screen');
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get data service
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // Create new character
      final character = Character(
        name: _characterName,
        userId: widget.userId,
        specialty: _characterSpecialty,
        battleCry: _battleCry,
      );
      
      // Save D&D character data
      if (_dndCharacterData != null) {
        character.setDnDCharacterInfo(_dndCharacterData!);
      }
      
      // Save character
      await dataService.addCharacter(character);
      _debugPrint('Character created: ${character.name}');
      
      // 캐릭터 생성 완료 시 효과음 재생
      GameEffectsService().playSound(GameSound.swordClash);
      
      // Always navigate to clan selection screen
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ClanSelectionScreen(character: character),
        ),
      );
    } catch (e) {
      _debugPrint('Character save error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving character: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHARACTER CREATION',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[100]!,
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / _questions.length,
                            backgroundColor: Colors.grey[200],
                            color: AppTheme.primaryColor,
                            minHeight: 12,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Progress text
                        Text(
                          '${_currentIndex + 1} of ${_questions.length} Questions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Question pages
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          return _buildQuestionPage(index);
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button (if not on first page)
                      if (_currentIndex > 0)
                        ElevatedButton.icon(
                          onPressed: _prevQuestion,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text(
                            'PREVIOUS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            backgroundColor: Colors.white,
                            elevation: 4,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 100),
                        
                      // Next/Complete button
                      ElevatedButton.icon(
                        onPressed: _nextQuestion,
                        icon: Icon(
                          _currentIndex < _questions.length - 1 
                              ? Icons.arrow_forward 
                              : Icons.check_circle_outline,
                          size: 18,
                        ),
                        label: Text(
                          _currentIndex < _questions.length - 1 
                              ? 'NEXT' 
                              : 'COMPLETE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Loading overlay
            if (_isGeneratingCharacter)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color(0xFF14213D),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Creating Your Character...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rolling the dice! 🎲',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build question page
  Widget _buildQuestionPage(int index) {
    final question = _questions[index];
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF3D5EA4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'QUESTION ${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Question text
          Text(
            question.question,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Guidance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline, 
                        color: AppTheme.secondaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GUIDANCE:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.guidance,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Example
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_objects_outlined, 
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'EXAMPLE:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.example,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Input field
          TextField(
            controller: _controllers[index],
            maxLines: 5,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
  
  // Question list
  final List<Question> _questions = [
    Question(
      question: 'What makes you feel ALL the feels, and why does it matter so much?',
      guidance: 'Choose a value, cause, or idea that lights your fire. Tell us what drives your passion for it!',
      example: '"I feel SUPER strongly about kindness! Small acts can totally flip someone\'s day around. Once I helped a stranger with their groceries, and their smile? Unforgettable!"',
    ),
    Question(
      question: 'What\'s your go-to fun activity when you\'re not adulting?',
      guidance: 'Share a hobby or activity that brings you joy. Why does it vibe with you?',
      example: '"I rock out on my guitar! It helps me chill and express feelings that words just can\'t handle."',
    ),
    Question(
      question: 'How do you tackle super tough problems when they pop up?',
      guidance: 'Think about a challenging situation you faced. How did you boss it?',
      example: '"When my laptop crashed right before a deadline, I kept my cool. Googled solutions on my phone and texted a friend for help. Made the deadline with minutes to spare!"',
    ),
    Question(
      question: 'In the squad, are you the talker or the listener?',
      guidance: 'Describe how you roll in social situations. Do you lead the convo or prefer to absorb others\' thoughts?',
      example: '"I\'m definitely a listener! I like to understand everyone\'s thoughts before dropping my own hot takes."',
    ),
    Question(
      question: 'What\'s your superpower skill and how did you level it up?',
      guidance: 'Highlight a talent or ability you\'re proud of. Share how you developed it!',
      example: '"I\'m a baking wizard! Spent every weekend experimenting with recipes until I could make the PERFECT chocolate chip cookie!"',
    ),
    Question(
      question: 'If you could live ANYWHERE in any made-up world, where would you choose and why?',
      guidance: 'Pick a place from books, movies, or your imagination. Why is it so amazing?',
      example: '"Definitely Hogwarts from Harry Potter! A world centered on magic and learning? Yes please!"',
    ),
    Question(
      question: 'What\'s something totally random about you?',
      guidance: 'Share a fun or quirky fact that makes you uniquely YOU!',
      example: '"I\'m obsessed with collecting colorful socks! I have over 50 pairs and counting!"',
    ),
  ];
}

/// Question class
class Question {
  final String question;
  final String guidance;
  final String example;
  
  Question({
    required this.question,
    required this.guidance,
    required this.example,
  });
} 