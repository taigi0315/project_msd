import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import '../models/project.dart';
import '../models/mission.dart' as app_mission;

/// OpenAI API service for generating project, mission, achievement content,
/// and epic D&D character profiles in our family quest RPG app!
class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  
  factory OpenAIService() {
    return _instance;
  }
  
  OpenAIService._internal();
  
  // OpenAI API settings
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  late String _apiKey;
  bool _isInitialized = false;
  bool _useMockData = false;
  
  // Debug output
  void _debugPrint(String message) {
    debugPrint('🤖 OpenAIService: $message');
  }
  
  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Try to load API key from environment
      var env = DotEnv();
      try {
        env.load();
        _apiKey = env['OPENAI_API_KEY'] ?? '';
      } catch (e) {
        _debugPrint('Failed to load environment variables: $e');
        _apiKey = '';
      }
      
      // Hardcoded API key (don't use in production)
      if (_apiKey.isEmpty) {
        _apiKey = 'sk-your-api-key'; // Replace with actual key or leave empty
      }
      
      if (_apiKey.isEmpty || _apiKey == 'sk-your-api-key') {
        _debugPrint('No valid API key found! Switching to MOCK DATA MODE! 🎭');
        _useMockData = true;
      }
      
      _isInitialized = true;
      _debugPrint('OpenAI service initialized! (Mock mode: $_useMockData)');
    } catch (e) {
      _debugPrint('Oops! OpenAI service failed to initialize: $e');
      _useMockData = true;
      _isInitialized = true; // Consider as initialized anyway
      _debugPrint('Switched to mock mode - fake it till you make it!');
    }
  }
  
  /// Send request to OpenAI API
  Future<Map<String, dynamic>> _sendRequest(String prompt, {String model = 'gpt-3.5-turbo'}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_useMockData) {
      return _getMockResponse(prompt);
    }
    
    _debugPrint('Sending request to OpenAI API... 🚀');
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': 'You are a creative assistant that generates content for a family project management app with RPG elements.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _debugPrint('OpenAI API response received! 📩');
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('OpenAI API call failed: ${error['error']['message']}');
      }
    } catch (e) {
      _debugPrint('Uh-oh! OpenAI API error: $e');
      rethrow;
    }
  }
  
  /// Generate mock response
  Map<String, dynamic> _getMockResponse(String prompt) {
    _debugPrint('Creating super awesome mock response! 🎭');
    
    // Return different responses based on keywords
    if (prompt.contains('project name')) {
      return {
        'choices': [
          {
            'message': {
              'content': 'Epic Family Chronicle Adventure'
            }
          }
        ]
      };
    } else if (prompt.contains('mission')) {
      return {
        'choices': [
          {
            'message': {
              'content': '''
[
  {
    "name": "Interview the Elders",
    "description": "Conduct 30+ minute interviews with family members and record their legendary tales!",
    "experienceReward": 100
  },
  {
    "name": "Digital Time Capsule",
    "description": "Digitize those dusty old family photos and organize them by timeline and epic events!",
    "experienceReward": 150
  },
  {
    "name": "Family Timeline Creator",
    "description": "Create an epic timeline of major family events in chronological order!",
    "experienceReward": 120
  }
]
              '''
            }
          }
        ]
      };
    } else if (prompt.contains('achievement')) {
      return {
        'choices': [
          {
            'message': {
              'content': '''
[
  {
    "name": "Family Historian",
    "description": "Collect 10+ family history episodes like you're gathering infinity stones!",
    "experienceReward": 200
  },
  {
    "name": "Photo Collector",
    "description": "Digitize and organize 50+ family photos - gotta catch 'em all!",
    "experienceReward": 250
  },
  {
    "name": "Family Chronicle Writer",
    "description": "Write a 20-page document about your family history - basically, you're the family's J.R.R. Tolkien!",
    "experienceReward": 300
  }
]
              '''
            }
          }
        ]
      };
    } else {
      return {
        'choices': [
          {
            'message': {
              'content': 'This is mock data! Want real AI magic? Add a valid OpenAI API key! ✨'
            }
          }
        ]
      };
    }
  }
  
  /// Generate project name
  Future<String> generateProjectName(String goal) async {
    _debugPrint('Cooking up an epic project name... 🧙‍♂️');
    
    final prompt = '''
Create a super creative project name for this goal: "$goal"
Make it fun, catchy, and fit for an RPG game theme.
Just return the name, please!
''';
    
    try {
      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'];
      final projectName = content.trim().replaceAll('"', '');
      
      _debugPrint('Epic project name created: $projectName ✨');
      return projectName;
    } catch (e) {
      _debugPrint('Failed to create project name: $e');
      throw Exception('Error generating project name: $e');
    }
  }
  
  /// Generate mission list
  Future<List<app_mission.Mission>> generateMissions(String goal, String projectName, int count) async {
    _debugPrint('Crafting epic quest missions... ($count quests incoming!) 📜');
    
    final prompt = '''
Create $count missions for this goal and project name:
Goal: "$goal"
Project Name: "$projectName"

Return each mission in this JSON format:
[
  {
    "name": "Mission Name",
    "description": "Mission description (1-2 sentences)",
    "experienceReward": XP reward (number between 50-100)
  }
]

Missions should be steps to achieve the project goal.
Mission names should be short, catchy, and action-oriented!
''';
    
    try {
      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'];
      
      // Extract JSON string (text might have additional content)
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;
      final jsonStr = content.substring(jsonStart, jsonEnd);
      
      final List<dynamic> missionData = jsonDecode(jsonStr);
      final missions = missionData.map((data) {
        return app_mission.Mission(
          name: data['name'],
          description: data['description'],
          experienceReward: data['experienceReward'],
          status: app_mission.MissionStatus.todo,
          assignedCharacterIds: [],
          creatorCharacterId: 'ai_generated', // Mark as OpenAI generated
        );
      }).toList();
      
      _debugPrint('Created ${missions.length} epic missions! 🎯');
      return missions;
    } catch (e) {
      _debugPrint('Mission generation failed: $e');
      throw Exception('Error generating missions: $e');
    }
  }
  
  /// Generate achievement list
  Future<List<Achievement>> generateAchievements(String goal, String projectName) async {
    _debugPrint('Crafting legendary achievements... 🏆');
    
    final prompt = '''
Create 3 achievements for this goal and project name:
Goal: "$goal"
Project Name: "$projectName"

Return achievements in this JSON format:
[
  {
    "name": "Achievement Name",
    "description": "Achievement description",
    "condition": "Achievement unlock condition",
    "experienceReward": XP reward (number between 100-500),
    "tier": "achievement tier (bronze, silver, gold, platinum, diamond)"
  }
]

First achievement should be bronze tier - easy to unlock.
Second achievement should be silver tier - moderate effort required.
Third achievement should be gold tier - a significant challenge!
''';
    
    try {
      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'];
      
      // Extract JSON string
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;
      final jsonStr = content.substring(jsonStart, jsonEnd);
      
      final List<dynamic> achievementData = jsonDecode(jsonStr);
      final achievements = achievementData.map((data) {
        return Achievement(
          name: data['name'],
          description: data['description'],
          condition: data['condition'],
          experienceReward: data['experienceReward'],
          tier: _parseAchievementTier(data['tier']),
          isUnlocked: false,
        );
      }).toList();
      
      // First achievement is automatically unlocked (project creation reward)
      if (achievements.isNotEmpty) {
        achievements[0] = achievements[0].copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
      
      _debugPrint('Created ${achievements.length} legendary achievements! 🎖️');
      return achievements;
    } catch (e) {
      _debugPrint('Achievement generation failed: $e');
      throw Exception('Error generating achievements: $e');
    }
  }
  
  /// Convert string to AchievementTier
  AchievementTier _parseAchievementTier(String tierStr) {
    switch (tierStr.toLowerCase()) {
      case 'bronze': return AchievementTier.bronze;
      case 'silver': return AchievementTier.silver;
      case 'gold': return AchievementTier.gold;
      case 'platinum': return AchievementTier.platinum;
      case 'diamond': return AchievementTier.diamond;
      default: return AchievementTier.bronze;
    }
  }
  
  /// Generate additional missions
  Future<List<app_mission.Mission>> generateAdditionalMissions(
    String goal, 
    String projectName, 
    List<app_mission.Mission> existingMissions,
    int count
  ) async {
    _debugPrint('Creating bonus mission DLC... ($count new quests!) 📜');
    
    // Create list of existing mission names
    final existingMissionNames = existingMissions.map((m) => (m as app_mission.Mission).name).join(', ');
    
    final prompt = '''
Create $count NEW missions for this goal and project:
Goal: "$goal"
Project Name: "$projectName"

These missions already exist:
$existingMissionNames

Create missions that complement and extend the existing ones.
Each mission in this JSON format:
[
  {
    "name": "Mission Name",
    "description": "Mission description (1-2 sentences)",
    "experienceReward": XP reward (between 50-100)
  }
]

New missions should NOT duplicate existing ones and should be more challenging and advanced!
''';
    
    try {
      final response = await _sendRequest(prompt);
      final content = response['choices'][0]['message']['content'];
      
      // Extract JSON string
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;
      final jsonStr = content.substring(jsonStart, jsonEnd);
      
      final List<dynamic> missionData = jsonDecode(jsonStr);
      final missions = missionData.map((data) {
        return app_mission.Mission(
          name: data['name'],
          description: data['description'],
          experienceReward: data['experienceReward'],
          status: app_mission.MissionStatus.todo,
          assignedCharacterIds: [],
          creatorCharacterId: 'ai_generated', // Mark as OpenAI generated
        );
      }).toList();
      
      _debugPrint('Created ${missions.length} bonus missions! 🎯');
      return missions;
    } catch (e) {
      _debugPrint('Additional mission generation failed: $e');
      throw Exception('Error generating additional missions: $e');
    }
  }
  
  /// Generate text
  /// 
  /// Generates text based on the given prompt.
  Future<String> generateText(String prompt, {int maxTokens = 500}) async {
    if (!_isInitialized) await initialize();
    
    if (_useMockData) {
      // Return virtual response in mock mode
      return _generateMockTextResponse(prompt);
    }
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are an AI that helps create creative RPG characters.'},
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': maxTokens,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final choices = jsonResponse['choices'] as List;
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'];
        } else {
          throw Exception('Response contains no choices');
        }
      } else {
        _debugPrint('API error: ${response.statusCode}, ${response.body}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      _debugPrint('Text generation error: $e');
      // Provide mock response in case of error
      return _generateMockTextResponse(prompt);
    }
  }
  
  /// Generate mock text response
  String _generateMockTextResponse(String prompt) {
    // For character creation prompts
    if (prompt.contains('character info') || prompt.contains('create a character')) {
      return '''
Name: Sparkles McWizardface
Specialty: Mage
BattleCry: Knowledge is power, creativity is magic!
''';
    }
    
    // For general prompts
    return 'This is a mock text response. For real AI magic, set a valid API key!';
  }
  
  /// Generate character from responses
  /// 
  /// Creates an appropriate character based on user survey responses.
  Future<String> generateCharacterFromResponses(String prompt) async {
    // Use general text generation method with more specific instructions
    final systemPrompt = '''You are a fantasy RPG character creation expert. 
    Analyze the user's personality, strengths, weaknesses, and values to create an appropriate character.
    
    Choose one of these character classes:
    - leader: A leader with excellent leadership skills
    - warrior: A warrior specialized in combat
    - mage: A wizard who solves problems creatively
    - healer: A healer who boosts team morale and mediates problems
    - scout: A scout who gathers information and predicts the future
    - ranger: A ranger who explores the wild and gathers information
    - rogue: A rogue who uses skills to flee combat or deceive enemies
    - cleric: A cleric who heals teammates and grants holy power
    
    Respond in this format:
    Name: [Character Name]
    Specialty: [Character Class]
    BattleCry: [Character's battle cry or motto]
    ''';
    
    if (_useMockData) {
      // Return mock response in mock mode
      await Future.delayed(const Duration(seconds: 2)); // Intentional delay
      return _generateMockCharacterResponse(prompt);
    }
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final choices = jsonResponse['choices'] as List;
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'];
        } else {
          throw Exception('Response contains no choices');
        }
      } else {
        _debugPrint('API error: ${response.statusCode}, ${response.body}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      _debugPrint('Character generation error: $e');
      // Provide mock response in case of error
      return _generateMockCharacterResponse(prompt);
    }
  }
  
  /// Generate mock character response
  String _generateMockCharacterResponse(String prompt) {
    // Generate different characters based on keywords in the prompt
    final promptLower = prompt.toLowerCase();
    
    if (promptLower.contains('leadership') || promptLower.contains('guide') || promptLower.contains('manage')) {
      return '''
Name: Arthur Kingsley
Specialty: leader
BattleCry: Together, we can overcome any challenge!
''';
    } else if (promptLower.contains('combat') || promptLower.contains('strength') || promptLower.contains('challenge')) {
      return '''
Name: Brute Stonehammer
Specialty: warrior
BattleCry: Any obstacle shall crumble before my will!
''';
    } else if (promptLower.contains('creativity') || promptLower.contains('knowledge') || promptLower.contains('analyze')) {
      return '''
Name: Luna Starweave
Specialty: mage
BattleCry: Knowledge is the most powerful magic!
''';
    } else if (promptLower.contains('empathy') || promptLower.contains('help') || promptLower.contains('heal')) {
      return '''
Name: Serena Lightheart
Specialty: healer
BattleCry: I shall be the light that heals all wounds!
''';
    } else if (promptLower.contains('observe') || promptLower.contains('information') || promptLower.contains('plan')) {
      return '''
Name: Shadow Nightwalker
Specialty: scout
BattleCry: See first, act first!
''';
    } else {
      // Default response
      final nameOptions = [
        'Elia Windrummer',
        'Thor Thundersmith',
        'Ariel Stargaze',
        'Garen Trueheart',
        'Lily Springfield'
      ];
      
      final specialtyOptions = [
        'ranger',
        'warrior',
        'mage',
        'cleric',
        'healer'
      ];
      
      final battleCryOptions = [
        'Adventure is life\'s greatest gift!',
        'Beyond limits!',
        'I forge my own destiny!',
        'May light shine through darkness!',
        'Blazing new trails is my calling!'
      ];
      
      // Random index based on current time
      final random = DateTime.now().millisecondsSinceEpoch;
      final nameIndex = random % nameOptions.length;
      final specialtyIndex = (random ~/ 10) % specialtyOptions.length;
      final battleCryIndex = (random ~/ 100) % battleCryOptions.length;
      
      return '''
Name: ${nameOptions[nameIndex]}
Specialty: ${specialtyOptions[specialtyIndex]}
BattleCry: ${battleCryOptions[battleCryIndex]}
''';
    }
  }
  
  /// Generate D&D-style character profile based on user survey responses
  Future<Map<String, dynamic>> generateDnDCharacter(List<String> responses) async {
    _debugPrint('Summoning a D&D character from the digital realm... 🎲');
    
    if (!_isInitialized) await initialize();
    
    if (_useMockData) {
      // Return mock data during development
      await Future.delayed(const Duration(seconds: 1)); // Intentional delay
      return _generateMockDnDCharacter(responses);
    }
    
    try {
      // Construct prompt
      final prompt = _buildDnDCharacterPrompt(responses);
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': '''
You are a legendary Dungeon Master tasked with crafting a heroic character straight out of Dungeons & Dragons! 
Your mission is to take the user's answers to the questions provided and transform them into a game-like character profile 
that reflects their personality and skills. Keep the tone fun, playful, and dripping with humor—think quirky heroes and epic adventures.
Return ONLY valid JSON in the following format:
{
  "class_name": "Character's class name",
  "specialty": "Character's unique specialty",
  "skills": ["Skill 1", "Skill 2", "Skill 3", "Skill 4", "Skill 5"],
  "battle_cry": "Character's battle cry"
}
'''},
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        
        // Extract actual JSON from content
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;
        final jsonStr = content.substring(jsonStart, jsonEnd);
        
        final characterData = jsonDecode(jsonStr);
        _debugPrint('D&D character summoned: ${characterData['class_name']} 🧙‍♂️');
        
        return characterData;
      } else {
        _debugPrint('API error: ${response.statusCode}, ${response.body}');
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      _debugPrint('D&D character generation error: $e');
      // Provide mock data in case of error
      return _generateMockDnDCharacter(responses);
    }
  }
  
  /// Build D&D character creation prompt
  String _buildDnDCharacterPrompt(List<String> responses) {
    final buffer = StringBuffer();
    
    buffer.writeln('Character Creation Prompt:');
    buffer.writeln('You are a legendary Dungeon Master tasked with crafting a heroic character straight out of Dungeons & Dragons!');
    buffer.writeln('Your mission is to take the user\'s answers to the questions provided below and transform them into a game-like character profile that reflects their personality and skills.');
    buffer.writeln('');
    buffer.writeln('User\'s Questions and Answers:');
    
    // Question list
    final questions = [
      'What makes you feel ALL the feels, and why does it matter so much?',
      'What\'s your go-to fun activity when you\'re not adulting?',
      'How do you tackle super tough problems when they pop up?',
      'In the squad, are you the talker or the listener?',
      'What\'s your superpower skill and how did you level it up?',
      'If you could live ANYWHERE in any made-up world, where would you choose and why?',
      'What\'s something totally random about you?'
    ];
    
    // Add questions and responses
    for (int i = 0; i < questions.length && i < responses.length; i++) {
      buffer.writeln('Question ${i + 1}: ${questions[i]}');
      buffer.writeln('Answer: "${responses[i]}"');
      buffer.writeln('');
    }
    
    return buffer.toString();
  }
  
  /// Generate mock D&D character response
  Map<String, dynamic> _generateMockDnDCharacter(List<String> responses) {
    _debugPrint('Rolling dice for mock D&D character... 🎲');
    
    // Use provided mock data during development
    final mockData = {
      "class_name": "Artificer",
      "specialty": "Gear-Tickling Gadgeteer",
      "skills": ["Tinker's Touch", "Puzzle Pulverizer", "Gamer's Grit", "Stubborn Stand", "Rock Hoarder"],
      "battle_cry": "By the gears and stones, I'll outwit you all!"
    };
    
    // Optionally add variations based on responses (optional)
    if (responses.isNotEmpty) {
      // If first response contains certain keywords, use different class
      final firstResponse = responses[0].toLowerCase();
      
      if (firstResponse.contains('justice') || firstResponse.contains('protect') || firstResponse.contains('defend')) {
        mockData["class_name"] = "Paladin";
        mockData["specialty"] = "Defender of Justice";
        mockData["battle_cry"] = "For honor and the light!";
      } else if (firstResponse.contains('magic') || firstResponse.contains('knowledge') || firstResponse.contains('learn')) {
        mockData["class_name"] = "Wizard";
        mockData["specialty"] = "Scholar of Arcane Secrets";
        mockData["battle_cry"] = "Knowledge is the greatest power!";
      }
    }
    
    return mockData;
  }
} 