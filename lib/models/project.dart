import 'package:uuid/uuid.dart';
import 'mission.dart';

/// 미션의 상태를 나타내는 열거형
enum MissionStatus {
  /// 미시작 상태
  todo('할 일'),
  
  /// 진행 중인 상태
  inProgress('진행 중'),
  
  /// 완료된 상태
  completed('완료됨'),
  
  /// 지연된 상태
  delayed('지연됨');

  /// 상태 표시 이름
  final String displayName;
  
  const MissionStatus(this.displayName);
}

/// 업적 등급 열거형
enum AchievementTier {
  /// 브론즈 등급 (기본)
  bronze,
  
  /// 실버 등급 (중급)
  silver,
  
  /// 골드 등급 (상급)
  gold,
  
  /// 플래티넘 등급 (최상급)
  platinum,
  
  /// 다이아몬드 등급 (전설급)
  diamond,
}

/// 미션 모델 클래스
/// 프로젝트는 여러 개의 미션으로 구성됩니다.
class Mission {
  /// 미션의 고유 ID
  final String id;
  
  /// 미션 이름
  String name;
  
  /// 미션 설명
  String description;
  
  /// 미션 상태
  MissionStatus status;
  
  /// 담당자 ID (캐릭터 ID)
  String? assignedToId;
  
  /// 미션 생성 날짜
  final DateTime createdAt;
  
  /// 미션 완료 날짜
  DateTime? completedAt;
  
  /// 미션 완료 시 보상 경험치
  final int experienceReward;

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🎯 Mission ($name): $message');
  }
  
  /// 미션 생성자
  Mission({
    String? id,
    required this.name,
    required this.description,
    this.status = MissionStatus.todo,
    this.assignedToId,
    DateTime? createdAt,
    this.completedAt,
    this.experienceReward = 100,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now() {
    _debugPrint('새로운 미션 생성: $name (ID: $id)');
  }
  
  /// 미션 담당자 할당
  void assignTo(String characterId) {
    assignedToId = characterId;
    _debugPrint('미션 담당자 할당: $characterId');
  }
  
  /// 미션 상태 변경
  void updateStatus(MissionStatus newStatus) {
    if (status == newStatus) {
      _debugPrint('이미 $newStatus 상태입니다');
      return;
    }
    
    status = newStatus;
    _debugPrint('상태 업데이트: ${status.displayName}');
    
    // 완료 상태로 변경된 경우 완료 시간 기록
    if (status == MissionStatus.completed) {
      completedAt = DateTime.now();
      _debugPrint('미션 완료 시간 기록: $completedAt');
    } else {
      completedAt = null;  // 완료가 아닌 상태로 변경되면 완료 시간 초기화
    }
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'assignedToId': assignedToId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'experienceReward': experienceReward,
    };
  }
  
  /// JSON에서 변환
  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: MissionStatus.values.firstWhere((e) => e.name == json['status']),
      assignedToId: json['assignedToId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      experienceReward: json['experienceReward'] as int,
    );
  }
}

/// 프로젝트 업적 클래스
class Achievement {
  /// 업적 ID
  final String id;
  
  /// 업적 이름
  final String name;
  
  /// 업적 설명
  final String description;
  
  /// 업적 획득 조건
  final String condition;
  
  /// 업적 달성 여부
  bool isUnlocked;
  
  /// 업적 획득시 보상 경험치
  final int experienceReward;
  
  /// 업적 획득 날짜
  DateTime? unlockedAt;
  
  /// 업적 획득한 캐릭터 ID
  String? unlockedById;
  
  /// 업적 등급
  final AchievementTier tier;

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🏆 Achievement ($name): $message');
  }
  
  /// 업적 생성자
  Achievement({
    String? id,
    required this.name,
    required this.description,
    required this.condition,
    required this.experienceReward,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedAt,
    this.unlockedById,
  }) : id = id ?? const Uuid().v4() {
    _debugPrint('새로운 업적 생성: $name (ID: $id)');
  }
  
  /// 업적 잠금 해제
  void unlock([String? characterId]) {
    if (isUnlocked) {
      _debugPrint('업적이 이미 잠금 해제되어 있습니다');
      return;
    }
    
    isUnlocked = true;
    unlockedAt = DateTime.now();
    unlockedById = characterId;
    _debugPrint('업적 잠금 해제됨: $experienceReward XP 보상');
  }
  
  /// 보상 경험치 반환
  int getExperienceReward() {
    return experienceReward;
  }
  
  /// 업적 초기화
  void reset() {
    if (!isUnlocked) {
      _debugPrint('업적이 이미 잠겨 있습니다');
      return;
    }
    
    isUnlocked = false;
    unlockedAt = null;
    unlockedById = null;
    _debugPrint('업적 초기화됨');
  }
  
  /// copyWith 메서드 추가
  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? condition,
    bool? isUnlocked,
    int? experienceReward,
    DateTime? unlockedAt,
    String? unlockedById,
    AchievementTier? tier,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      experienceReward: experienceReward ?? this.experienceReward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockedById: unlockedById ?? this.unlockedById,
      tier: tier ?? this.tier,
    );
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'condition': condition,
      'isUnlocked': isUnlocked,
      'experienceReward': experienceReward,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'unlockedById': unlockedById,
      'tier': tier.name,
    };
  }
  
  /// JSON에서 변환
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      condition: json['condition'] as String,
      isUnlocked: json['isUnlocked'] as bool,
      experienceReward: json['experienceReward'] as int,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
      unlockedById: json['unlockedById'] as String?,
      tier: AchievementTier.values.firstWhere((t) => t.name == json['tier']),
    );
  }
}

/// 프로젝트 모델 클래스
/// 클랜 내에서 수행하는 활동의 큰 단위입니다.
class Project {
  /// 프로젝트의 고유 ID
  final String id;
  
  /// 프로젝트 이름
  String name;
  
  /// 프로젝트 설명
  String description;
  
  /// 프로젝트 생성일
  final DateTime createdAt;
  
  /// 프로젝트 마감일 (선택적)
  DateTime? dueDate;
  
  /// 프로젝트 생성자의 캐릭터 ID
  final String creatorCharacterId;
  
  /// 프로젝트가 속한 클랜 ID
  final String clanId;
  
  /// 프로젝트에 참여 중인 캐릭터 ID 목록
  List<String> assignedCharacterIds;
  
  /// 프로젝트의 미션 목록
  List<Mission> missions;
  
  /// 프로젝트에 설정된 태그
  List<String> tags;
  
  /// 프로젝트의 업적 목록
  List<Achievement> achievements;

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('📊 Project ($name): $message');
  }
  
  /// 프로젝트 생성자
  Project({
    String? id,
    required this.name,
    required this.description,
    required this.creatorCharacterId,
    required this.clanId,
    List<String>? assignedCharacterIds,
    List<Mission>? missions,
    List<String>? tags,
    this.dueDate,
    DateTime? createdAt,
    List<Achievement>? achievements,
  }) : 
    id = id ?? const Uuid().v4(),
    assignedCharacterIds = assignedCharacterIds ?? [],
    missions = missions ?? [],
    tags = tags ?? [],
    achievements = achievements ?? [],
    createdAt = createdAt ?? DateTime.now() {
    _debugPrint('새로운 프로젝트 생성: $name (ID: $id)');
  }
  
  /// 프로젝트 진행률 계산 (0.0 ~ 1.0)
  double calculateProgress() {
    if (missions.isEmpty) {
      return 0.0;
    }
    
    final completedMissions = missions.where((m) => m.status == MissionStatus.completed).length;
    return completedMissions / missions.length;
  }
  
  /// 미션 추가
  void addMission(Mission mission) {
    if (missions.any((m) => m.id == mission.id)) {
      _debugPrint('미션이 이미 존재합니다: ${mission.id}');
      return;
    }
    
    missions.add(mission);
    _debugPrint('미션 추가됨: ${mission.name} (ID: ${mission.id})');
  }
  
  /// 미션 제거
  void removeMission(String missionId) {
    final removedMissions = missions.where((m) => m.id == missionId).toList();
    if (removedMissions.isEmpty) {
      _debugPrint('제거할 미션을 찾을 수 없습니다: $missionId');
      return;
    }
    
    missions.removeWhere((m) => m.id == missionId);
    _debugPrint('미션 제거됨: ${removedMissions.first.name} (ID: $missionId)');
  }
  
  /// 캐릭터 할당
  void assignCharacter(String characterId) {
    if (assignedCharacterIds.contains(characterId)) {
      _debugPrint('캐릭터가 이미 할당되어 있습니다: $characterId');
      return;
    }
    
    assignedCharacterIds.add(characterId);
    _debugPrint('캐릭터 할당됨: $characterId');
  }
  
  /// 캐릭터 할당 해제
  void unassignCharacter(String characterId) {
    if (!assignedCharacterIds.contains(characterId)) {
      _debugPrint('할당된 캐릭터가 아닙니다: $characterId');
      return;
    }
    
    assignedCharacterIds.remove(characterId);
    _debugPrint('캐릭터 할당 해제됨: $characterId');
  }
  
  /// 태그 추가
  void addTag(String tag) {
    if (tags.contains(tag)) {
      _debugPrint('태그가 이미 존재합니다: $tag');
      return;
    }
    
    tags.add(tag);
    _debugPrint('태그 추가됨: $tag');
  }
  
  /// 태그 제거
  void removeTag(String tag) {
    if (!tags.contains(tag)) {
      _debugPrint('제거할 태그를 찾을 수 없습니다: $tag');
      return;
    }
    
    tags.remove(tag);
    _debugPrint('태그 제거됨: $tag');
  }
  
  /// 업적 추가
  void addAchievement(Achievement achievement) {
    if (achievements.any((a) => a.id == achievement.id)) {
      _debugPrint('업적이 이미 존재합니다: ${achievement.name}');
      return;
    }
    
    achievements.add(achievement);
    _debugPrint('업적 추가됨: ${achievement.name}');
  }
  
  /// 업적 잠금 해제
  bool unlockAchievement(String achievementId, [String? characterId]) {
    final achievement = getAchievement(achievementId);
    if (achievement == null) {
      _debugPrint('업적을 찾을 수 없음: $achievementId');
      return false;
    }
    
    if (achievement.isUnlocked) {
      _debugPrint('업적이 이미 잠금 해제되어 있습니다: ${achievement.name}');
      return false;
    }
    
    achievement.unlock(characterId);
    _debugPrint('업적 잠금 해제 성공: ${achievement.name}');
    return true;
  }
  
  /// 업적 가져오기
  Achievement? getAchievement(String achievementId) {
    final index = achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) {
      return null;
    }
    return achievements[index];
  }
  
  /// 복사본 생성
  Project copyWith({
    String? name,
    String? description,
    DateTime? dueDate,
    List<String>? assignedCharacterIds,
    List<Mission>? missions,
    List<String>? tags,
    List<Achievement>? achievements,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorCharacterId: creatorCharacterId,
      clanId: clanId,
      dueDate: dueDate ?? this.dueDate,
      assignedCharacterIds: assignedCharacterIds ?? List.from(this.assignedCharacterIds),
      missions: missions ?? List.from(this.missions),
      tags: tags ?? List.from(this.tags),
      createdAt: createdAt,
      achievements: achievements ?? List.from(this.achievements),
    );
  }
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'creatorCharacterId': creatorCharacterId,
      'clanId': clanId,
      'assignedCharacterIds': assignedCharacterIds,
      'missions': missions.map((mission) => mission.toJson()).toList(),
      'tags': tags,
      'achievements': achievements.map((a) => a.toJson()).toList(),
    };
  }
  
  /// JSON에서 변환
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      creatorCharacterId: json['creatorCharacterId'] as String,
      clanId: json['clanId'] as String,
      assignedCharacterIds: List<String>.from(json['assignedCharacterIds']),
      missions: (json['missions'] as List).map((missionJson) => Mission.fromJson(missionJson)).toList(),
      tags: List<String>.from(json['tags']),
      achievements: (json['achievements'] as List?)?.map((a) => Achievement.fromJson(a)).toList() ?? [],
    );
  }
} 