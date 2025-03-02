import 'package:uuid/uuid.dart';
import 'character.dart';
import 'project.dart';
import 'package:flutter/foundation.dart';

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
  final DateTime? foundedAt;

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
  bool isPrivate = true;

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
  }) : 
    id = id ?? const Uuid().v4(),
    memberIds = memberIds ?? [leaderId],
    projectIds = projectIds ?? [],
    inviteCode = inviteCode ?? _generateInviteCode(),
    createdAt = createdAt ?? DateTime.now(),
    foundedAt = foundedAt ?? DateTime.now() {
    // isPrivate 매개변수는 무시됩니다 - 항상 true입니다
    this.isPrivate = true;
    
    _debugPrint('New clan created: $name (ID: $id)');
  }

  /// 초대 코드 생성
  static String _generateInviteCode() {
    // UUID의 첫 6자리를 사용하여 초대 코드 생성
    String code = const Uuid().v4().substring(0, 6).toUpperCase();
    // ignore: avoid_print
    print('🔑 New invite code generated: $code');
    return code;
  }

  /// 새로운 초대 코드 생성
  void regenerateInviteCode() {
    inviteCode = _generateInviteCode();
    _debugPrint('Invite code regenerated: $inviteCode');
  }

  /// 클랜에 멤버 추가
  void addMember(String memberId) {
    if (!memberIds.contains(memberId)) {
      memberIds.add(memberId);
      _debugPrint('Member added: $memberId');
    } else {
      _debugPrint('Member already exists: $memberId');
    }
  }

  /// 클랜에서 멤버 제거
  void removeMember(String memberId) {
    if (memberId == leaderId) {
      _debugPrint('Cannot remove the leader!');
      return;
    }
    
    if (memberIds.contains(memberId)) {
      memberIds.remove(memberId);
      _debugPrint('Member removed: $memberId');
    } else {
      _debugPrint('Member not found: $memberId');
    }
  }

  /// 클랜 리더 변경
  void changeLeader(String newLeaderId) {
    if (!memberIds.contains(newLeaderId)) {
      _debugPrint('The member to set as leader is not in the clan!');
      return;
    }
    
    leaderId = newLeaderId;
    _debugPrint('New leader set: $newLeaderId');
  }

  /// 새 프로젝트 추가
  void addProject(String projectId) {
    if (!projectIds.contains(projectId)) {
      projectIds.add(projectId);
      _debugPrint('Project added: $projectId');
    } else {
      _debugPrint('Project already exists: $projectId');
    }
  }

  /// 프로젝트 제거
  void removeProject(String projectId) {
    if (projectIds.contains(projectId)) {
      projectIds.remove(projectId);
      _debugPrint('Project removed: $projectId');
    } else {
      _debugPrint('Project not found: $projectId');
    }
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'foundedAt': foundedAt?.toIso8601String(),
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
      foundedAt: json['foundedAt'] != null ? DateTime.parse(json['foundedAt'] as String) : null,
      leaderId: json['leaderId'] as String,
      founderCharacterId: json['founderCharacterId'] as String,
      memberIds: List<String>.from(json['memberIds']),
      projectIds: List<String>.from(json['projectIds']),
      inviteCode: json['inviteCode'] as String,
    );
  }
} 