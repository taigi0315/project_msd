import 'package:uuid/uuid.dart';

/// 캐릭터의 전문 역할을 나타내는 열거형
enum CharacterSpecialty {
  /// 리더십이 뛰어난 지도자
  leader('지도자', '클랜을 이끌고 방향성을 제시합니다'),
  
  /// 전투에 특화된 전사
  warrior('전사', '어려운 과제를 정면으로 맞서 해결합니다'),
  
  /// 마법을 다루는 마법사
  mage('마법사', '창의적인 방법으로 문제를 해결합니다'),
  
  /// 치유를 담당하는 힐러
  healer('힐러', '팀의 사기를 높이고 문제를 중재합니다'),
  
  /// 정찰과 탐색을 담당하는 스카우트
  scout('정찰병', '정보를 수집하고 미래를 예측합니다'),
  
  /// 레인저
  ranger('레인저', '야생을 탐험하고 정보를 수집합니다'),
  
  /// 도적
  rogue('도적', '전투 중에 무작정 도망치거나 적을 속이는 기술을 사용합니다'),
  
  /// 성직자
  cleric('성직자', '팀원들을 치유하고 성스러운 힘을 부여합니다');

  /// 역할명
  final String displayName;
  
  /// 역할 설명
  final String description;
  
  const CharacterSpecialty(this.displayName, this.description);
}

/// 캐릭터의 스킬 클래스
class Skill {
  /// 스킬 이름
  final String name;
  
  /// 스킬 설명
  final String description;
  
  /// 스킬 레벨
  int level;
  
  /// 다음 레벨까지 필요한 경험치
  int experienceToNextLevel;

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('⚔️ Skill ($name): $message');
  }
  
  /// 스킬 생성자
  Skill({
    required this.name,
    required this.description,
    this.level = 1,
    this.experienceToNextLevel = 100,
  }) {
    _debugPrint('새로운 스킬 생성: $name (Lv.$level)');
  }
  
  /// 경험치 획득
  void gainExperience(int amount) {
    if (amount <= 0) {
      _debugPrint('유효하지 않은 경험치 값: $amount');
      return;
    }
    
    _debugPrint('경험치 획득: +$amount');
    
    // 경험치 적용 및 레벨업 확인
    if (amount >= experienceToNextLevel) {
      int remainingExp = amount - experienceToNextLevel;
      levelUp();
      
      // 남은 경험치 처리
      if (remainingExp > 0) {
        gainExperience(remainingExp);
      }
    } else {
      experienceToNextLevel -= amount;
      _debugPrint('다음 레벨까지 필요 경험치: $experienceToNextLevel');
    }
  }
  
  /// 레벨업
  void levelUp() {
    level++;
    // 레벨이 올라갈수록 다음 레벨까지 필요한 경험치 증가
    experienceToNextLevel = level * 100;
    _debugPrint('레벨업! 현재 레벨: $level, 다음 레벨까지 필요 경험치: $experienceToNextLevel');
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'level': level,
      'experienceToNextLevel': experienceToNextLevel,
    };
  }
  
  /// JSON에서 변환
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] as String,
      description: json['description'] as String,
      level: json['level'] as int,
      experienceToNextLevel: json['experienceToNextLevel'] as int,
    );
  }
}

/// 캐릭터 모델 클래스
/// 사용자는 게임 내에서 고유한 캐릭터를 가지며, 이 캐릭터를 통해 활동합니다.
class Character {
  /// 캐릭터의 고유 ID
  final String id;
  
  /// 캐릭터 이름
  String name;
  
  /// 사용자 ID (Firebase Auth ID와 연결될 예정)
  final String userId;
  
  /// 이메일 주소
  final String email;
  
  /// 캐릭터의 전문 역할
  CharacterSpecialty specialty;
  
  /// 캐릭터의 전투 구호
  String battleCry;
  
  /// 캐릭터의 스킬 목록
  List<Skill> skills;
  
  /// 캐릭터의 레벨
  int level;
  
  /// 전체 경험치
  int totalExperience;
  
  /// 다음 레벨까지 필요한 경험치
  int experienceToNextLevel;

  /// 캐릭터가 속한 클랜 ID
  String? clanId;
  
  /// 캐릭터 생성 날짜
  final DateTime createdAt;
  
  /// 경험치 getter (다른 클래스에서 사용하던 프로퍼티명과 호환)
  int get experiencePoints => totalExperience;

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('👤 Character ($name): $message');
  }
  
  /// 캐릭터 생성자
  Character({
    String? id,
    required this.name,
    required this.userId,
    String? email,
    required this.specialty,
    required this.battleCry,
    List<Skill>? skills,
    this.level = 1,
    this.totalExperience = 0,
    int? experienceToNextLevel,
    this.clanId,
    DateTime? createdAt,
  }) : 
    id = id ?? const Uuid().v4(),
    email = email ?? '$userId@example.com',
    skills = skills ?? _generateDefaultSkills(specialty),
    experienceToNextLevel = experienceToNextLevel ?? (level * 100),
    createdAt = createdAt ?? DateTime.now() {
    _debugPrint('새로운 캐릭터 생성: $name (ID: $id)');
  }
  
  /// 기본 스킬 생성
  static List<Skill> _generateDefaultSkills(CharacterSpecialty specialty) {
    // 각 역할에 맞는 기본 스킬 생성
    List<Skill> defaultSkills = [];
    
    switch (specialty) {
      case CharacterSpecialty.leader:
        defaultSkills = [
          Skill(name: '지휘 능력', description: '팀의 효율성을 높입니다'),
          Skill(name: '선견지명', description: '미래의 장애물을 예측합니다'),
          Skill(name: '영감', description: '팀에게 동기부여를 제공합니다'),
        ];
        break;
        
      case CharacterSpecialty.warrior:
        defaultSkills = [
          Skill(name: '문제 해결', description: '어려운 문제를 빠르게 해결합니다'),
          Skill(name: '인내력', description: '장기 과제에 대한 인내심을 발휘합니다'),
          Skill(name: '집중력', description: '중요한 세부사항에 집중합니다'),
        ];
        break;
        
      case CharacterSpecialty.mage:
        defaultSkills = [
          Skill(name: '창의적 사고', description: '새로운 아이디어를 생각해냅니다'),
          Skill(name: '혁신', description: '전통적인 방법을 개선합니다'),
          Skill(name: '지식 탐구', description: '새로운 지식을 습득합니다'),
        ];
        break;
        
      case CharacterSpecialty.healer:
        defaultSkills = [
          Skill(name: '소통 능력', description: '팀원 간의 소통을 원활하게 합니다'),
          Skill(name: '공감', description: '타인의 관점을 이해합니다'),
          Skill(name: '화합', description: '팀 내 갈등을 해결합니다'),
        ];
        break;
        
      case CharacterSpecialty.scout:
        defaultSkills = [
          Skill(name: '정보 수집', description: '유용한 정보를 찾아냅니다'),
          Skill(name: '분석력', description: '복잡한 데이터를 분석합니다'),
          Skill(name: '전략적 사고', description: '장기적인 전략을 수립합니다'),
        ];
        break;
        
      default:
        defaultSkills = [
          Skill(name: '적응력', description: '다양한 상황에 적응합니다'),
          Skill(name: '문제 해결', description: '문제를 창의적으로 해결합니다'),
          Skill(name: '협업 능력', description: '팀원들과 효과적으로 협력합니다'),
        ];
        break;
    }
    
    return defaultSkills;
  }
  
  /// 경험치 획득
  void gainExperience(int amount) {
    if (amount <= 0) {
      _debugPrint('유효하지 않은 경험치 값: $amount');
      return;
    }
    
    _debugPrint('경험치 획득: +$amount');
    totalExperience += amount;
    
    // 경험치 적용 및 레벨업 확인
    if (amount >= experienceToNextLevel) {
      int remainingExp = amount - experienceToNextLevel;
      levelUp();
      
      // 남은 경험치 처리
      if (remainingExp > 0) {
        gainExperience(remainingExp);
      }
    } else {
      experienceToNextLevel -= amount;
      _debugPrint('다음 레벨까지 필요 경험치: $experienceToNextLevel');
    }
  }
  
  /// addExperience는 gainExperience와 동일 (호환성 유지를 위한 alias)
  void addExperience(int amount) {
    gainExperience(amount);
  }
  
  /// 다음 레벨까지 필요한 경험치 계산
  int calculateNextLevelExp() {
    return experienceToNextLevel;
  }
  
  /// 레벨업
  void levelUp() {
    level++;
    // 레벨이 올라갈수록 다음 레벨까지 필요한 경험치 증가
    experienceToNextLevel = level * 100;
    _debugPrint('레벨업! 현재 레벨: $level, 다음 레벨까지 필요 경험치: $experienceToNextLevel');
    
    // 랜덤으로 스킬 중 하나를 레벨업
    if (skills.isNotEmpty) {
      final random = DateTime.now().millisecondsSinceEpoch % skills.length;
      final skill = skills[random];
      skill.levelUp();
      _debugPrint('스킬 레벨업: ${skill.name} (Lv.${skill.level})');
    }
  }
  
  /// 스킬 추가
  void addSkill(Skill skill) {
    if (skills.any((s) => s.name == skill.name)) {
      _debugPrint('해당 스킬이 이미 존재합니다: ${skill.name}');
      return;
    }
    
    skills.add(skill);
    _debugPrint('새로운 스킬 추가됨: ${skill.name}');
  }
  
  /// 스킬 업그레이드
  void upgradeSkill(String skillName, int experienceAmount) {
    final skillIndex = skills.indexWhere((s) => s.name == skillName);
    if (skillIndex == -1) {
      _debugPrint('스킬을 찾을 수 없음: $skillName');
      return;
    }
    
    skills[skillIndex].gainExperience(experienceAmount);
    _debugPrint('스킬 경험치 추가: $skillName +$experienceAmount');
  }
  
  /// 클랜 가입
  void joinClan(String newClanId) {
    clanId = newClanId;
    _debugPrint('클랜 가입: $newClanId');
  }
  
  /// 클랜 탈퇴
  void leaveClan() {
    if (clanId == null) {
      _debugPrint('가입된 클랜이 없습니다');
      return;
    }
    
    String oldClanId = clanId!;
    clanId = null;
    _debugPrint('클랜 탈퇴: $oldClanId');
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'email': email,
      'specialty': specialty.name,
      'battleCry': battleCry,
      'skills': skills.map((skill) => skill.toJson()).toList(),
      'level': level,
      'totalExperience': totalExperience,
      'experienceToNextLevel': experienceToNextLevel,
      'clanId': clanId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// JSON에서 변환
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String?,
      specialty: CharacterSpecialty.values.firstWhere((e) => e.name == json['specialty']),
      battleCry: json['battleCry'] as String,
      skills: (json['skills'] as List).map((skillJson) => Skill.fromJson(skillJson)).toList(),
      level: json['level'] as int,
      totalExperience: json['totalExperience'] as int,
      experienceToNextLevel: json['experienceToNextLevel'] as int,
      clanId: json['clanId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
} 