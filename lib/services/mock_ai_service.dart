import 'dart:math';
import '../models/character.dart';

/// OpenAI API를 대신하여 콘텐츠를 생성하는 모의 AI 서비스
/// 실제 애플리케이션에서는 OpenAI API로 교체될 예정입니다.
class MockAIService {
  // 싱글톤 인스턴스
  static final MockAIService _instance = MockAIService._internal();
  
  // 미션 이름 모음
  final List<String> _missionNameTemplates = [
    'Collect the magical [item]',
    'Find the hidden treasure of [place]',
    'Protect the village from the threat of [enemy]',
    'Make [number] [item]s',
    'Improve [skill] skill',
    'Get [item] from [place]',
    'Complete [task] within a week',
    'Complete [task] with [character]',
    'Master the use of the secret [item]',
    'Draw a secret map of [place]',
  ];
  
  // 미션 설명 모음
  final List<String> _missionDescriptionTemplates = [
    'This mission is very important for the glory of our clan. Plan and execute carefully!',
    'It\'s not an easy challenge, but our clan has always turned the impossible into possible!',
    'This mission will test our skills and wisdom. We must all work together.',
    'This is a secret mission. Success will bring great glory to the clan.',
    'Ancient wisdom is needed for this mission. Refer to ancient documents and legends.',
    'Quick action is needed! If you delay, you might miss the opportunity.',
    'This mission requires a creative approach. Think from a new perspective.',
    'This mission requires maximizing the strengths of our clan.',
    'This is a long-term mission that requires patience and perseverance. Don\'t give up!',
    'This is an important mission that can be fun and enjoyable!',
  ];
  
  // 업적 이름 모음
  final List<String> _achievementNameTemplates = [
    '[adjective] [noun] Conqueror',
    'Hero of [place]',
    '[skill] Master',
    '[adjective] [animal]',
    'Guardian of [element]',
    '[adjective] Knight',
    'Challenger of [number] Times',
    '[adjective] [profession]',
    'Ruler of [element]',
    'Legendary [noun]',
  ];
  
  // 업적 설명 모음
  final List<String> _achievementDescriptionTemplates = [
    'This achievement proves true courage and determination!',
    'An amazing achievement that can only be seen in legends.',
    'You have successfully completed an impossible challenge!',
    'This achievement shows your dedication and effort.',
    'An achievement that will go down in clan history!',
    'A great achievement that future generations will talk about.',
    'You have shown amazing skills that would surprise even wizards!',
    'This achievement proves your wisdom and insight.',
    'A rare achievement mentioned in ancient prophecies!',
    'An honorable achievement that only true champions can obtain.',
  ];
  
  // 업적 조건 모음
  final List<String> _achievementConditionTemplates = [
    'Complete [number] missions',
    'Participate in the project for [number] consecutive days',
    'Complete a mission with [number] team members',
    'Complete [number] missions within [timeframe]',
    'Have all team members complete at least one mission',
    'Be the first to complete [specific_mission]',
    'Complete all missions without delays',
    'Have all team roles participate in the project',
    'Participate in [number] different projects',
    'Earn [number] total experience points',
  ];
  
  // 단어 채우기용 명사
  final List<String> _nouns = [
    'Warrior', 'Hero', 'Fighter', 'Wizard', 'Archer', 'Knight', 'Sage', 'Explorer', 'Pioneer', 'Guardian',
    'Treasure', 'Dagger', 'Sword', 'Staff', 'Shield', 'Armor', 'Ring', 'Necklace', 'Scroll', 'Potion',
  ];
  
  // 단어 채우기용 형용사
  final List<String> _adjectives = [
    'Legendary', 'Mysterious', 'Brave', 'Wise', 'Powerful', 'Skilled', 'Noble', 'Great', 'Shining', 'Ancient',
    'Fast', 'Wise', 'Sharp', 'Holy', 'Dark', 'Golden', 'Fiery', 'Icy', 'Windy', 'Earthy',
  ];
  
  // 단어 채우기용 장소
  final List<String> _places = [
    'Forest', 'Mountain', 'Castle', 'Village', 'Cave', 'Temple', 'Tower', 'River', 'Sea', 'Island',
    'Plains', 'Wasteland', 'Snowy Mountains', 'Volcano', 'Labyrinth', 'Ancient Ruins', 'Secret Garden', 'Magic School', 'Underground City', 'Sky Island',
  ];
  
  // 단어 채우기용 원소
  final List<String> _elements = [
    'Fire', 'Water', 'Wind', 'Earth', 'Light', 'Darkness', 'Lightning', 'Ice', 'Nature', 'Chaos',
    'Space', 'Time', 'Life', 'Death', 'Mind', 'Soul', 'Metal', 'Wood', 'Moon', 'Sun',
  ];
  
  // 단어 채우기용 적
  final List<String> _enemies = [
    'Dragon', 'Goblin', 'Troll', 'Orc', 'Skeleton', 'Zombie', 'Lich', 'Dark Knight', 'Witch', 'Demon',
    'Giant', 'Ghost', 'Vampire', 'Werewolf', 'Medusa', 'Kraken', 'Chimera', 'Griffin', 'Harpy', 'Basilisk',
  ];
  
  // 단어 채우기용 동물
  final List<String> _animals = [
    'Wolf', 'Lion', 'Eagle', 'Tiger', 'Bear', 'Hawk', 'Owl', 'Turtle', 'Snake', 'Shark',
    'Dragon', 'Unicorn', 'Griffin', 'Pegasus', 'Centaur', 'Phoenix', 'Kraken', 'Hydra', 'Sphinx', 'Manticore',
  ];
  
  // 단어 채우기용 스킬
  final List<String> _skills = [
    'Magic', 'Swordsmanship', 'Archery', 'Healing', 'Alchemy', 'Assassination', 'Cooking', 'Blacksmithing', 'Exploration', 'Survival',
    'Strategy', 'Diplomacy', 'Leadership', 'Stealth', 'Tracking', 'Trapping', 'Spell Breaking', 'History', 'Animal Training', 'Botany',
  ];
  
  // 단어 채우기용 아이템
  final List<String> _items = [
    'Sword', 'Shield', 'Bow', 'Staff', 'Potion', 'Scroll', 'Ring', 'Necklace', 'Helmet', 'Armor',
    'Book', 'Map', 'Key', 'Jewel', 'Seal', 'Amulet', 'Arrow', 'Dagger', 'Wand', 'Orb',
  ];
  
  // 단어 채우기용 직업
  final List<String> _professions = [
    'Warrior', 'Wizard', 'Archer', 'Rogue', 'Priest', 'Knight', 'Alchemist', 'Scholar', 'Blacksmith', 'Cook',
    'Merchant', 'Bard', 'Explorer', 'Pirate', 'Farmer', 'Doctor', 'Architect', 'Sailor', 'Miner', 'Carpenter',
  ];
  
  // 단어 채우기용 작업
  final List<String> _tasks = [
    'Planning', 'Data Collection', 'Analysis', 'Design', 'Implementation', 'Testing', 'Presentation', 'Evaluation', 'Improvement', 'Report Writing',
    'Meeting', 'Brainstorming', 'Survey', 'Interview', 'Market Research', 'Budget Management', 'Schedule Management', 'Quality Control', 'Risk Management', 'Team Building',
  ];
  
  // 단어 채우기용 캐릭터
  final List<String> _characters = [
    'Wise Elder', 'Brave Knight', 'Mysterious Wizard', 'Agile Rogue', 'Kind Priest', 'Strong Warrior', 'Accurate Archer', 'Witty Bard', 'Strict Teacher', 'Timid Apprentice',
    'Mischievous Fairy', 'Stubborn Dwarf', 'Elegant Elf', 'Rough Orc', 'Curious Child', 'Wise Druid', 'Cold Assassin', 'Loyal Guard', 'Cheerful Servant', 'Lonely Wanderer',
  ];
  
  // 단어 채우기용 숫자
  final List<String> _numbers = [
    'Three', 'Five', 'Seven', 'Ten', 'Twelve', 'Fifteen', 'Twenty', 'Thirty', 'Fifty', 'Hundred',
  ];
  
  // 단어 채우기용 시간 단위
  final List<String> _timeframes = [
    'One Day', 'One Week', 'One Month', 'Three Months', 'One Year', 'Three Years', 'One Season', 'A Day and a Half', 'Two Days', 'Ten Days',
  ];

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🧠 MockAIService: $message');
  }
  
  /// 팩토리 생성자
  factory MockAIService() {
    return _instance;
  }
  
  /// 내부 생성자
  MockAIService._internal() {
    _debugPrint('MockAIService initialized');
  }
  
  /// 문자열 내의 플레이스홀더를 실제 값으로 대체
  String _replacePlaceholders(String template) {
    final random = Random();
    String result = template;
    
    // 플레이스홀더 대체
    if (result.contains('[noun]')) {
      result = result.replaceAll('[noun]', _nouns[random.nextInt(_nouns.length)]);
    }
    
    if (result.contains('[adjective]')) {
      result = result.replaceAll('[adjective]', _adjectives[random.nextInt(_adjectives.length)]);
    }
    
    if (result.contains('[place]')) {
      result = result.replaceAll('[place]', _places[random.nextInt(_places.length)]);
    }
    
    if (result.contains('[element]')) {
      result = result.replaceAll('[element]', _elements[random.nextInt(_elements.length)]);
    }
    
    if (result.contains('[enemy]')) {
      result = result.replaceAll('[enemy]', _enemies[random.nextInt(_enemies.length)]);
    }
    
    if (result.contains('[animal]')) {
      result = result.replaceAll('[animal]', _animals[random.nextInt(_animals.length)]);
    }
    
    if (result.contains('[skill]')) {
      result = result.replaceAll('[skill]', _skills[random.nextInt(_skills.length)]);
    }
    
    if (result.contains('[item]')) {
      result = result.replaceAll('[item]', _items[random.nextInt(_items.length)]);
    }
    
    if (result.contains('[profession]')) {
      result = result.replaceAll('[profession]', _professions[random.nextInt(_professions.length)]);
    }
    
    if (result.contains('[task]')) {
      result = result.replaceAll('[task]', _tasks[random.nextInt(_tasks.length)]);
    }
    
    if (result.contains('[character]')) {
      result = result.replaceAll('[character]', _characters[random.nextInt(_characters.length)]);
    }
    
    if (result.contains('[number]')) {
      result = result.replaceAll('[number]', _numbers[random.nextInt(_numbers.length)]);
    }
    
    if (result.contains('[timeframe]')) {
      result = result.replaceAll('[timeframe]', _timeframes[random.nextInt(_timeframes.length)]);
    }
    
    if (result.contains('[specific_mission]')) {
      final missionTemplate = _missionNameTemplates[random.nextInt(_missionNameTemplates.length)];
      final missionName = _replacePlaceholders(missionTemplate);
      result = result.replaceAll('[specific_mission]', missionName);
    }
    
    return result;
  }
  
  /// 프로젝트 이름 생성
  String generateProjectName({String? type}) {
    _debugPrint('Generating project name... (type: ${type ?? "project"})');
    
    final random = Random();
    
    // 프로젝트 이름 템플릿
    final List<String> templates;
    
    // 타입에 따른 템플릿 선택
    if (type == 'clan') {
      templates = [
        'House of [adjective] [noun]',
        '[adjective] Clan of [place]',
        '[noun] Clan of [element]',
        '[adjective] Bloodline of [noun]',
        'House of [adjective] [animal]',
        'Guardians of [element]: [adjective] [noun]',
        'Alliance of [adjective] [profession]',
        'Secret of [place]: Blood Pact of [noun]',
      ];
    } else {
      templates = [
        'Journey of [adjective] [noun]',
        '[adjective] Legend of [place]',
        '[noun] Project of [element]',
        '[adjective] Adventure of [noun]',
        'Exploration of [adjective] [animal]',
        'Call of [element]: [adjective] [noun]',
        'Challenge of [adjective] [profession]',
        'Secret of [place]: Awakening of [noun]',
      ];
    }
    
    // 랜덤으로 템플릿 선택
    final selectedTemplate = templates[random.nextInt(templates.length)];
    
    // 플레이스홀더 대체
    final projectName = _replacePlaceholders(selectedTemplate);
    
    _debugPrint('Generated project name: $projectName');
    
    return projectName;
  }
  
  /// 미션 이름 생성
  String generateMissionName() {
    final random = Random();
    final template = _missionNameTemplates[random.nextInt(_missionNameTemplates.length)];
    final missionName = _replacePlaceholders(template);
    
    _debugPrint('Mission name generated: $missionName');
    return missionName;
  }
  
  /// 미션 설명 생성
  String generateMissionDescription() {
    final random = Random();
    final template = _missionDescriptionTemplates[random.nextInt(_missionDescriptionTemplates.length)];
    final missionDescription = _replacePlaceholders(template);
    
    _debugPrint('Mission description generated: $missionDescription');
    return missionDescription;
  }
  
  /// 새 미션 목록 생성
  List<Map<String, String>> generateMissions(int count) {
    _debugPrint('Generating $count missions...');
    final List<Map<String, String>> missions = [];
    
    for (int i = 0; i < count; i++) {
      missions.add({
        'name': generateMissionName(),
        'description': generateMissionDescription(),
      });
    }
    
    return missions;
  }
  
  /// 업적 이름 생성
  String generateAchievementName() {
    final random = Random();
    final template = _achievementNameTemplates[random.nextInt(_achievementNameTemplates.length)];
    final achievementName = _replacePlaceholders(template);
    
    _debugPrint('Achievement name generated: $achievementName');
    return achievementName;
  }
  
  /// 업적 설명 생성
  String generateAchievementDescription() {
    final random = Random();
    final template = _achievementDescriptionTemplates[random.nextInt(_achievementDescriptionTemplates.length)];
    final achievementDescription = _replacePlaceholders(template);
    
    _debugPrint('Achievement description generated: $achievementDescription');
    return achievementDescription;
  }
  
  /// 업적 조건 생성
  String generateAchievementCondition() {
    final random = Random();
    final template = _achievementConditionTemplates[random.nextInt(_achievementConditionTemplates.length)];
    final achievementCondition = _replacePlaceholders(template);
    
    _debugPrint('Achievement condition generated: $achievementCondition');
    return achievementCondition;
  }
  
  /// 새 업적 목록 생성
  List<Map<String, String>> generateAchievements(int count) {
    _debugPrint('Generating $count achievements...');
    final List<Map<String, String>> achievements = [];
    
    for (int i = 0; i < count; i++) {
      achievements.add({
        'name': generateAchievementName(),
        'description': generateAchievementDescription(),
        'condition': generateAchievementCondition(),
      });
    }
    
    return achievements;
  }
  
  /// 캐릭터 배틀 크라이 생성
  String generateBattleCry(CharacterSpecialty specialty, String characterName) {
    _debugPrint('Generating battle cry... ($specialty, $characterName)');
    
    List<String> templates;
    
    // 전문 분야에 따른 템플릿 선택
    switch (specialty) {
      case CharacterSpecialty.leader:
        templates = [
          "In our name, to victory!",
          "With $characterName leading, there is no fear!",
          "Under my command, we are one!",
          "With wisdom and courage, forward!",
          "Together, nothing is impossible!",
        ];
        break;
        
      case CharacterSpecialty.warrior:
        templates = [
          "Without fear, forward!",
          "When $characterName's sword shines, enemies flee!",
          "For strength and honor!",
          "With iron will, to the end!",
          "Obstacles are just my nourishment!",
        ];
        break;
        
      case CharacterSpecialty.mage:
        templates = [
          "Knowledge is power, magic is its expression!",
          "$characterName's wisdom will guide you!",
          "The wisdom of the stars in my hands!",
          "The waves of magic follow me!",
          "Where thoughts become reality!",
        ];
        break;
        
      case CharacterSpecialty.healer:
        templates = [
          "With the light of healing, I dispel the darkness!",
          "$characterName's blessing be with you!",
          "As a guardian of life, I protect!",
          "I soothe pain and restore strength!",
          "The light within me shall protect us!",
        ];
        break;
        
      case CharacterSpecialty.scout:
        templates = [
          "From the shadows, I watch!",
          "$characterName always stays one step ahead!",
          "From unseen places, I protect!",
          "First to see, last to leave!",
          "Darkness is my ally, speed is my weapon!",
        ];
        break;
        
      default:
        templates = [
          "Working together, we grow stronger!",
          "$characterName, moving forward to victory!",
          "Challenges are just opportunities to grow!",
          "There is no failure, only learning!",
          "Beginning is half the battle, perseverance is the other half!",
        ];
    }
    
    // 랜덤으로 하나 선택
    final randomIndex = DateTime.now().millisecondsSinceEpoch % templates.length;
    final selectedTemplate = templates[randomIndex];
    
    _debugPrint('Generated battle cry: $selectedTemplate');
    
    return selectedTemplate;
  }
} 