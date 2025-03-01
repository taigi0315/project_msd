import 'package:uuid/uuid.dart';

/// 미션 상태를 정의하는 열거형
enum MissionStatus {
  /// 할 일 (시작 전)
  todo('할 일'),
  
  /// 진행 중
  inProgress('진행 중'),
  
  /// 완료됨
  completed('완료됨'),
  
  /// 지연됨
  delayed('지연됨');
  
  /// 상태의 표시 이름
  final String displayName;
  
  /// 생성자
  const MissionStatus(this.displayName);
}

/// 미션 모델 클래스
/// 프로젝트 내부의 작업 단위입니다.
class Mission {
  /// 미션의 고유 ID
  final String id;
  
  /// 미션 이름
  final String name;
  
  /// 미션 설명
  final String description;
  
  /// 미션 생성일
  final DateTime createdAt;
  
  /// 미션 마감일 (선택적)
  final DateTime? dueDate;
  
  /// 미션 상태
  MissionStatus status;
  
  /// 완료 시 얻는 경험치
  final int experienceReward;
  
  /// 미션 생성자의 캐릭터 ID
  final String creatorCharacterId;
  
  /// 미션에 할당된 캐릭터 ID 목록
  final List<String> assignedCharacterIds;
  
  /// 미션 완료일 (완료 시에만 값이 있음)
  DateTime? completedAt;

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('📝 Mission ($name): $message');
  }
  
  /// 미션 생성자
  Mission({
    String? id,
    required this.name,
    required this.description,
    required this.experienceReward,
    required this.status,
    required this.creatorCharacterId,
    List<String>? assignedCharacterIds,
    this.dueDate,
    this.completedAt,
    DateTime? createdAt,
  }) : 
    id = id ?? const Uuid().v4(),
    assignedCharacterIds = assignedCharacterIds ?? [],
    createdAt = createdAt ?? DateTime.now() {
    _debugPrint('새로운 미션 생성: $name (ID: $id)');
    
    // 이미 완료 상태인 경우 완료일 자동 설정
    if (status == MissionStatus.completed && completedAt == null) {
      completedAt = DateTime.now();
    }
  }
  
  /// 미션 상태 업데이트
  void updateStatus(MissionStatus newStatus) {
    if (status == newStatus) {
      _debugPrint('상태가 이미 $newStatus 입니다');
      return;
    }
    
    final oldStatus = status;
    status = newStatus;
    
    // 완료 상태로 변경된 경우 완료일 설정
    if (newStatus == MissionStatus.completed) {
      completedAt = DateTime.now();
    } else {
      // 완료 상태에서 다른 상태로 변경된 경우 완료일 제거
      if (oldStatus == MissionStatus.completed) {
        completedAt = null;
      }
    }
    
    _debugPrint('상태 업데이트됨: $oldStatus -> $newStatus');
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
  
  /// 복사본 생성
  Mission copyWith({
    String? name,
    String? description,
    int? experienceReward,
    MissionStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? assignedCharacterIds,
  }) {
    return Mission(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      experienceReward: experienceReward ?? this.experienceReward,
      status: status ?? this.status,
      creatorCharacterId: creatorCharacterId,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      assignedCharacterIds: assignedCharacterIds ?? List.from(this.assignedCharacterIds),
      createdAt: createdAt,
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
      'status': status.name,
      'experienceReward': experienceReward,
      'creatorCharacterId': creatorCharacterId,
      'assignedCharacterIds': assignedCharacterIds,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
  
  /// JSON에서 변환
  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      status: MissionStatus.values.firstWhere((e) => e.name == json['status']),
      experienceReward: json['experienceReward'] as int,
      creatorCharacterId: json['creatorCharacterId'] as String,
      assignedCharacterIds: List<String>.from(json['assignedCharacterIds']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }
} 