import 'package:uuid/uuid.dart';
import 'character.dart';
import 'project.dart';

/// 클랜 모델 클래스
/// 사용자들이 모여 하나의 클랜을 형성합니다.
/// 클랜은 여러 프로젝트를 관리할 수 있습니다.
class Clan {
  /// 클랜의 고유 ID
  final String id;

  /// 클랜의 이름
  String name;
  
  /// 클랜의 설명
  String description;

  /// 클랜 생성 날짜
  final DateTime createdAt;
  
  /// 클랜 창설일 (lore용)
  final DateTime foundedAt;

  /// 클랜 리더의 ID
  String leaderId;
  
  /// 클랜 창립자의 캐릭터 ID
  final String founderCharacterId;

  /// 클랜 멤버들의 ID 목록
  List<String> memberIds;

  /// 클랜의 프로젝트 ID 목록
  List<String> projectIds;

  /// 클랜의 초대 코드
  String inviteCode;
  
  /// 클랜의 공개 여부
  bool isPrivate;

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🏰 Clan: $message');
  }

  /// 클랜 생성자
  Clan({
    String? id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.founderCharacterId,
    List<String>? memberIds,
    List<String>? projectIds,
    String? inviteCode,
    DateTime? createdAt,
    DateTime? foundedAt,
    this.isPrivate = false,
  }) : 
    id = id ?? const Uuid().v4(),
    memberIds = memberIds ?? [leaderId],
    projectIds = projectIds ?? [],
    inviteCode = inviteCode ?? _generateInviteCode(),
    createdAt = createdAt ?? DateTime.now(),
    foundedAt = foundedAt ?? DateTime.now() {
    _debugPrint('새로운 클랜 생성: $name (ID: $id)');
  }

  /// 초대 코드 생성
  static String _generateInviteCode() {
    // UUID의 첫 6자리를 사용하여 초대 코드 생성
    String code = const Uuid().v4().substring(0, 6).toUpperCase();
    // ignore: avoid_print
    print('🔑 새로운 초대 코드 생성: $code');
    return code;
  }

  /// 새로운 초대 코드 생성
  void regenerateInviteCode() {
    inviteCode = _generateInviteCode();
    _debugPrint('초대 코드 재생성됨: $inviteCode');
  }

  /// 클랜에 멤버 추가
  void addMember(String memberId) {
    if (!memberIds.contains(memberId)) {
      memberIds.add(memberId);
      _debugPrint('멤버 추가됨: $memberId');
    } else {
      _debugPrint('멤버가 이미 존재함: $memberId');
    }
  }

  /// 클랜에서 멤버 제거
  void removeMember(String memberId) {
    if (memberId == leaderId) {
      _debugPrint('리더는 제거할 수 없습니다!');
      return;
    }
    
    if (memberIds.contains(memberId)) {
      memberIds.remove(memberId);
      _debugPrint('멤버 제거됨: $memberId');
    } else {
      _debugPrint('멤버를 찾을 수 없음: $memberId');
    }
  }

  /// 클랜 리더 변경
  void changeLeader(String newLeaderId) {
    if (!memberIds.contains(newLeaderId)) {
      _debugPrint('리더로 설정할 멤버가 클랜에 없습니다!');
      return;
    }
    
    leaderId = newLeaderId;
    _debugPrint('새 리더 설정됨: $newLeaderId');
  }

  /// 새 프로젝트 추가
  void addProject(String projectId) {
    if (!projectIds.contains(projectId)) {
      projectIds.add(projectId);
      _debugPrint('프로젝트 추가됨: $projectId');
    } else {
      _debugPrint('프로젝트가 이미 존재함: $projectId');
    }
  }

  /// 프로젝트 제거
  void removeProject(String projectId) {
    if (projectIds.contains(projectId)) {
      projectIds.remove(projectId);
      _debugPrint('프로젝트 제거됨: $projectId');
    } else {
      _debugPrint('프로젝트를 찾을 수 없음: $projectId');
    }
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'foundedAt': foundedAt.toIso8601String(),
      'leaderId': leaderId,
      'founderCharacterId': founderCharacterId,
      'memberIds': memberIds,
      'projectIds': projectIds,
      'inviteCode': inviteCode,
      'isPrivate': isPrivate,
    };
  }

  /// JSON에서 변환
  factory Clan.fromJson(Map<String, dynamic> json) {
    return Clan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      foundedAt: DateTime.parse(json['foundedAt'] as String),
      leaderId: json['leaderId'] as String,
      founderCharacterId: json['founderCharacterId'] as String,
      memberIds: List<String>.from(json['memberIds']),
      projectIds: List<String>.from(json['projectIds']),
      inviteCode: json['inviteCode'] as String,
      isPrivate: json['isPrivate'] as bool,
    );
  }
} 