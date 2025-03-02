import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/mock_data_service.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
import 'clan_selection_screen.dart';

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
      _showDnDCharacterDialog(dndCharacterData);
      
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
  void _showDnDCharacterDialog(Map<String, dynamic> characterData) {
    // Save D&D character data
    _dndCharacterData = characterData;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Text(
                    'BEHOLD! Your Hero is Born!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Character class & specialty
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        characterData['class_name'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        characterData['specialty'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Skills list
                Text(
                  'Epic Skills',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                ...List.generate(
                  (characterData['skills'] as List).length,
                  (index) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.secondaryColor,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        characterData['skills'][index],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Battle cry
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.secondaryColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Battle Cry',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        characterData['battle_cry'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
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
                        side: BorderSide(color: AppTheme.primaryColor),
                      ),
                      child: const Text('Retry'),
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
                      ),
                      child: const Text('Continue'),
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
  
  /// Character save confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Your Character is Ready!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $_characterName', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Role: ${_characterSpecialty.displayName}'),
            const SizedBox(height: 8),
            Text('Battle Cry: "$_battleCry"'),
            const SizedBox(height: 16),
            const Text('Ready to begin your adventure with this character?'),
          ],
        ),
        actions: [
          TextButton(
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
            child: const Text('Start Over'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveCharacterAndNavigate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Begin Adventure!'),
          ),
        ],
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
        title: const Text('Create Character'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey[200],
                  color: AppTheme.primaryColor,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                
                const SizedBox(height: 8),
                
                // Question counter
                Center(
                  child: Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Question pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionPage(index);
                    },
                  ),
                ),
                
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button (if not on first page)
                    if (_currentIndex > 0)
                      OutlinedButton.icon(
                        onPressed: _prevQuestion,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      )
                    else
                      const SizedBox(width: 100),
                      
                    // Next/Complete button
                    ElevatedButton.icon(
                      onPressed: _nextQuestion,
                      icon: Icon(_currentIndex < _questions.length - 1 
                          ? Icons.arrow_forward 
                          : Icons.check_circle_outline),
                      label: Text(_currentIndex < _questions.length - 1 
                          ? 'Next' 
                          : 'Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Creating Your Character...\nRolling the dice! 🎲',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
  
  /// Build question page
  Widget _buildQuestionPage(int index) {
    final question = _questions[index];
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Guidance
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, 
                      color: AppTheme.secondaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Guidance:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(question.guidance),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Example
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_objects_outlined, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Example:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(question.example),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Input field
          TextField(
            controller: _controllers[index],
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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