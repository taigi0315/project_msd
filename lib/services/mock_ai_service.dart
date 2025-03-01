import 'dart:math';
import '../models/character.dart';

/// OpenAI API를 대신하여 콘텐츠를 생성하는 모의 AI 서비스
/// 실제 애플리케이션에서는 OpenAI API로 교체될 예정입니다.
class MockAIService {
  // 싱글톤 인스턴스
  static final MockAIService _instance = MockAIService._internal();
  
  // 미션 이름 모음
  final List<String> _missionNameTemplates = [
    '마법의 [item] 수집하기',
    '[place]의 숨겨진 보물 찾기',
    '[enemy]의 위협으로부터 마을 지키기',
    '[number]개의 [item] 만들기',
    '[skill] 기술 향상하기',
    '[place]에서 [item] 구하기',
    '[task]을(를) 일주일 안에 완료하기',
    '[character] 캐릭터와 함께 [task] 완료하기',
    '비밀 [item]의 사용법 터득하기',
    '[place]의 비밀 지도 그리기',
  ];
  
  // 미션 설명 모음
  final List<String> _missionDescriptionTemplates = [
    '이 임무는 우리 클랜의 영광을 위해 매우 중요합니다. 신중하게 계획하고 실행하세요!',
    '쉽지 않은 도전이지만, 우리 클랜은 항상 불가능을 가능으로 바꿔왔습니다!',
    '이 임무는 우리의 기술과 지혜를 시험할 것입니다. 모두 함께 협력해야 합니다.',
    '비밀스러운 임무입니다. 성공하면 클랜에 큰 영광을 가져다 줄 것입니다.',
    '고대의 지혜가 필요한 임무입니다. 고문서와 전설을 참고하세요.',
    '빠른 행동이 필요합니다! 지체하면 기회를 놓칠 수 있어요.',
    '창의적인 접근이 필요한 임무입니다. 새로운 관점으로 생각해보세요.',
    '우리 클랜의 강점을 최대한 활용해야 하는 임무입니다.',
    '인내와 끈기가 필요한 장기 미션입니다. 포기하지 마세요!',
    '재미있게 즐기면서 할 수 있는, 그러나 중요한 임무입니다!',
  ];
  
  // 업적 이름 모음
  final List<String> _achievementNameTemplates = [
    '[adjective] [noun] 정복자',
    '[place]의 영웅',
    '[skill] 마스터',
    '[adjective] [animal]',
    '[element]의 수호자',
    '[adjective] 기사',
    '[number]번의 도전자',
    '[adjective] [profession]',
    '[element]의 지배자',
    '전설의 [noun]',
  ];
  
  // 업적 설명 모음
  final List<String> _achievementDescriptionTemplates = [
    '이 업적은 진정한 용기와 결단력을 증명합니다!',
    '전설에서나 볼 수 있는 놀라운 업적입니다.',
    '불가능한 도전을 성공적으로 완료했습니다!',
    '이 업적은 당신의 헌신과 노력을 보여줍니다.',
    '클랜 역사에 길이 남을 업적입니다!',
    '미래 세대가 이야기할 위대한 업적입니다.',
    '마법사들도 놀랄 대단한 기술을 보여주었습니다!',
    '이 업적은 당신의 지혜와 통찰력을 증명합니다.',
    '고대 예언에 언급된 희귀한 업적입니다!',
    '진정한 챔피언만이 획득할 수 있는 영예로운 업적입니다.',
  ];
  
  // 업적 조건 모음
  final List<String> _achievementConditionTemplates = [
    '[number]개의 미션을 완료하세요',
    '연속으로 [number]일 동안 프로젝트에 참여하세요',
    '팀원 [number]명과 함께 미션을 완료하세요',
    '[timeframe] 내에 [number]개의 미션을 완료하세요',
    '모든 팀원이 적어도 하나의 미션을 완료하게 하세요',
    '[specific_mission]을(를) 가장 먼저 완료하세요',
    '모든 미션을 지연 없이 완료하세요',
    '팀의 모든 역할이 프로젝트에 참여하게 하세요',
    '[number]개의 다른 프로젝트에 참여하세요',
    '총 [number] 경험치를 획득하세요',
  ];
  
  // 단어 채우기용 명사
  final List<String> _nouns = [
    '용사', '영웅', '전사', '마법사', '궁수', '기사', '현자', '탐험가', '선구자', '수호자',
    '보물', '단검', '검', '지팡이', '방패', '갑옷', '반지', '목걸이', '두루마리', '물약',
  ];
  
  // 단어 채우기용 형용사
  final List<String> _adjectives = [
    '전설적인', '신비로운', '용감한', '현명한', '강력한', '숙련된', '고귀한', '위대한', '빛나는', '고대의',
    '빠른', '지혜로운', '날카로운', '신성한', '어둠의', '황금', '불꽃의', '얼음의', '바람의', '대지의',
  ];
  
  // 단어 채우기용 장소
  final List<String> _places = [
    '숲', '산', '성', '마을', '동굴', '사원', '탑', '강', '바다', '섬',
    '평원', '황무지', '설산', '화산', '미궁', '고대 유적', '비밀 정원', '마법 학교', '지하 도시', '하늘 섬',
  ];
  
  // 단어 채우기용 원소
  final List<String> _elements = [
    '불', '물', '바람', '대지', '빛', '어둠', '번개', '얼음', '자연', '혼돈',
    '우주', '시간', '생명', '죽음', '정신', '영혼', '금속', '나무', '달', '태양',
  ];
  
  // 단어 채우기용 적
  final List<String> _enemies = [
    '드래곤', '고블린', '트롤', '오크', '스켈레톤', '좀비', '리치', '암흑 기사', '마녀', '악마',
    '거인', '유령', '뱀파이어', '늑대인간', '메두사', '크라켄', '키메라', '그리핀', '하피', '바실리스크',
  ];
  
  // 단어 채우기용 동물
  final List<String> _animals = [
    '늑대', '사자', '독수리', '호랑이', '곰', '매', '올빼미', '거북이', '뱀', '상어',
    '용', '유니콘', '그리핀', '페가수스', '켄타우로스', '피닉스', '크라켄', '히드라', '스핑크스', '만티코어',
  ];
  
  // 단어 채우기용 스킬
  final List<String> _skills = [
    '마법', '검술', '궁술', '치유', '연금술', '암살', '요리', '대장장이', '탐험', '생존',
    '전략', '외교', '통솔', '은신', '추적', '함정', '주문 해독', '역사학', '동물 조련', '식물학',
  ];
  
  // 단어 채우기용 아이템
  final List<String> _items = [
    '검', '방패', '활', '지팡이', '물약', '두루마리', '반지', '목걸이', '투구', '갑옷',
    '책', '지도', '열쇠', '보석', '인장', '부적', '화살', '단검', '완드', '구슬',
  ];
  
  // 단어 채우기용 직업
  final List<String> _professions = [
    '전사', '마법사', '궁수', '도적', '사제', '기사', '연금술사', '학자', '대장장이', '요리사',
    '상인', '음유시인', '탐험가', '해적', '농부', '의사', '건축가', '선원', '광부', '목수',
  ];
  
  // 단어 채우기용 작업
  final List<String> _tasks = [
    '계획 수립', '자료 수집', '분석', '디자인', '구현', '테스트', '발표', '평가', '개선', '보고서 작성',
    '회의 진행', '브레인스토밍', '설문 조사', '인터뷰', '시장 조사', '예산 관리', '일정 관리', '품질 관리', '리스크 관리', '팀 빌딩',
  ];
  
  // 단어 채우기용 캐릭터
  final List<String> _characters = [
    '현명한 노인', '용감한 기사', '신비로운 마법사', '민첩한 도적', '친절한 사제', '강인한 전사', '정확한 궁수', '재치있는 음유시인', '엄격한 선생', '소심한 견습생',
    '장난꾸러기 요정', '고집스러운 드워프', '우아한 엘프', '거칠은 오크', '호기심 많은 아이', '지혜로운 드루이드', '냉정한 암살자', '충직한 호위병', '명랑한 시종', '고독한 방랑자',
  ];
  
  // 단어 채우기용 숫자
  final List<String> _numbers = [
    '세', '다섯', '일곱', '열', '열둘', '열다섯', '스무', '서른', '오십', '백',
  ];
  
  // 단어 채우기용 시간 단위
  final List<String> _timeframes = [
    '하루', '일주일', '한 달', '세 달', '일 년', '삼 년', '한 계절', '하루 반', '이틀', '열흘',
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
    _debugPrint('MockAIService 초기화됨');
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
    _debugPrint('프로젝트 이름 생성 중... (type: ${type ?? "프로젝트"})');
    
    final random = Random();
    
    // 프로젝트 이름 템플릿
    final List<String> templates;
    
    // 타입에 따른 템플릿 선택
    if (type == 'clan') {
      templates = [
        '[adjective] [noun]의 가문',
        '[place]의 [adjective] 일족',
        '[element]의 [noun] 클랜',
        '[noun]의 [adjective] 혈통',
        '[adjective] [animal]의 가문',
        '[element]의 수호자: [adjective] [noun]',
        '[adjective] [profession]의 동맹',
        '[place]의 비밀: [noun]의 혈맹',
      ];
    } else {
      templates = [
        '[adjective] [noun]의 여정',
        '[place]의 [adjective] 전설',
        '[element]의 [noun] 프로젝트',
        '[noun]의 [adjective] 모험',
        '[adjective] [animal]의 탐험',
        '[element]의 부름: [adjective] [noun]',
        '[adjective] [profession]의 도전',
        '[place]의 비밀: [noun]의 각성',
      ];
    }
    
    // 랜덤으로 템플릿 선택
    final selectedTemplate = templates[random.nextInt(templates.length)];
    
    // 플레이스홀더 대체
    final projectName = _replacePlaceholders(selectedTemplate);
    
    _debugPrint('생성된 프로젝트 이름: $projectName');
    
    return projectName;
  }
  
  /// 미션 이름 생성
  String generateMissionName() {
    final random = Random();
    final template = _missionNameTemplates[random.nextInt(_missionNameTemplates.length)];
    final missionName = _replacePlaceholders(template);
    
    _debugPrint('미션 이름 생성됨: $missionName');
    return missionName;
  }
  
  /// 미션 설명 생성
  String generateMissionDescription() {
    final random = Random();
    final template = _missionDescriptionTemplates[random.nextInt(_missionDescriptionTemplates.length)];
    final missionDescription = _replacePlaceholders(template);
    
    _debugPrint('미션 설명 생성됨: $missionDescription');
    return missionDescription;
  }
  
  /// 새 미션 목록 생성
  List<Map<String, String>> generateMissions(int count) {
    _debugPrint('$count개의 미션 생성 중...');
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
    
    _debugPrint('업적 이름 생성됨: $achievementName');
    return achievementName;
  }
  
  /// 업적 설명 생성
  String generateAchievementDescription() {
    final random = Random();
    final template = _achievementDescriptionTemplates[random.nextInt(_achievementDescriptionTemplates.length)];
    final achievementDescription = _replacePlaceholders(template);
    
    _debugPrint('업적 설명 생성됨: $achievementDescription');
    return achievementDescription;
  }
  
  /// 업적 조건 생성
  String generateAchievementCondition() {
    final random = Random();
    final template = _achievementConditionTemplates[random.nextInt(_achievementConditionTemplates.length)];
    final achievementCondition = _replacePlaceholders(template);
    
    _debugPrint('업적 조건 생성됨: $achievementCondition');
    return achievementCondition;
  }
  
  /// 새 업적 목록 생성
  List<Map<String, String>> generateAchievements(int count) {
    _debugPrint('$count개의 업적 생성 중...');
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
    _debugPrint('배틀 크라이 생성 중... ($specialty, $characterName)');
    
    List<String> templates;
    
    // 전문 분야에 따른 템플릿 선택
    switch (specialty) {
      case CharacterSpecialty.leader:
        templates = [
          "우리의 이름으로, 승리를 향해!",
          "$characterName(이)가 이끌어, 두려움은 없다!",
          "내 명령 아래, 우리는 하나!",
          "지혜와 용기로, 앞으로!",
          "함께라면, 불가능은 없다!",
        ];
        break;
        
      case CharacterSpecialty.warrior:
        templates = [
          "두려움 없이, 앞으로!",
          "$characterName의 검이 빛날 때, 적은 도망친다!",
          "힘과 명예를 위해!",
          "강철같은 의지로, 끝까지!",
          "난관은 나의 양식일 뿐!",
        ];
        break;
        
      case CharacterSpecialty.mage:
        templates = [
          "지식은 힘, 마법은 그 표현!",
          "$characterName의 지혜가 너를 인도하리라!",
          "별들의 지혜를 나의 손에!",
          "마력의 물결이 나를 따른다!",
          "생각이 현실이 되는 곳!",
        ];
        break;
        
      case CharacterSpecialty.healer:
        templates = [
          "치유의 빛으로, 어둠을 물리친다!",
          "$characterName의 축복이 너희와 함께!",
          "생명의 수호자로서, 나는 지킨다!",
          "고통을 가라앉히고, 힘을 돌려주마!",
          "내 안의 빛이 우리를 보호하리라!",
        ];
        break;
        
      case CharacterSpecialty.scout:
        templates = [
          "그림자 속에서, 나는 감시한다!",
          "$characterName은(는) 언제나 한 발 앞서 간다!",
          "보이지 않는 곳에서, 나는 지킨다!",
          "첫 번째로 보고, 마지막으로 떠난다!",
          "어둠은 나의 동맹, 속도는 나의 무기!",
        ];
        break;
        
      default:
        templates = [
          "함께 일하면, 더 강해진다!",
          "$characterName, 승리를 향해 나아간다!",
          "도전은 성장의 기회일 뿐!",
          "실패는 없다, 오직 배움만 있을 뿐!",
          "시작이 반이다, 나머지 반은 끈기다!",
        ];
    }
    
    // 랜덤으로 하나 선택
    final randomIndex = DateTime.now().millisecondsSinceEpoch % templates.length;
    final selectedTemplate = templates[randomIndex];
    
    _debugPrint('생성된 배틀 크라이: $selectedTemplate');
    
    return selectedTemplate;
  }
} 