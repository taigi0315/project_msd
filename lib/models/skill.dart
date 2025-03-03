import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'character.dart';

/// 캐릭터가 익힐 수 있는 스킬을 나타내는 클래스입니다.
/// 각 스킬은 특정 유형, 레벨 및 경험치를 가집니다.
class Skill {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  int level;
  int experience;
  final Color color;
  
  /// 스킬이 생성된 시간
  final DateTime createdAt;
  
  /// 스킬이 마지막으로 사용된 시간
  DateTime? lastUsed;
  
  /// 기본 생성자
  Skill({
    String? id,
    required this.name,
    required this.description,
    required this.type,
    this.level = 1,
    this.experience = 0,
    this.color = Colors.blue,
    DateTime? createdAt,
    this.lastUsed,
  }) : 
    this.id = id ?? Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now();
  
  /// 다음 레벨까지 필요한 경험치를 계산합니다
  int get experienceToNextLevel {
    // 간단한 RPG 스타일 경험치 곡선
    return level * 100;
  }
  
  /// 현재 레벨의 진행도를 백분율로 반환합니다
  double get levelProgress {
    return experience / experienceToNextLevel;
  }
  
  /// 스킬에 경험치를 추가하고 필요시 레벨업을 처리합니다
  bool addExperience(int amount) {
    if (amount <= 0) return false;
    
    experience += amount;
    bool leveledUp = false;
    
    // 레벨업 처리
    while (experience >= experienceToNextLevel) {
      experience -= experienceToNextLevel;
      level++;
      leveledUp = true;
    }
    
    // 마지막 사용 시간 업데이트
    lastUsed = DateTime.now();
    
    return leveledUp;
  }
  
  /// 스킬의 복사본을 만들고 특정 값을 변경할 수 있습니다
  Skill copyWith({
    String? id,
    String? name,
    String? description,
    SkillType? type,
    int? level,
    int? experience,
    Color? color,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
  
  /// JSON 직렬화를 위한 메소드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.index,
      'level': level,
      'experience': experience,
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }
  
  /// JSON에서 Skill 객체를 생성하는 팩토리 메소드
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: SkillType.values[json['type']],
      level: json['level'],
      experience: json['experience'],
      color: Color(json['color'] ?? Colors.blue.value),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }
  
  /// 스킬 유형에 따른 아이콘을 반환합니다
  IconData getIcon() {
    switch (type) {
      case SkillType.combat:
        return Icons.security;
      case SkillType.knowledge:
        return Icons.school;
      case SkillType.social:
        return Icons.people;
      case SkillType.survival:
        return Icons.nature_people;
    }
  }
  
  /// 기본 스킬 세트 생성
  static List<Skill> createDefaultSkills() {
    return [
      // 전투 스킬
      Skill(
        name: 'Strategic Thinking',
        description: 'Ability to approach problem situations tactically',
        type: SkillType.combat,
      ),
      Skill(
        name: 'Concentration',
        description: 'Ability to focus on important moments',
        type: SkillType.combat,
      ),
      
      // 지식 스킬
      Skill(
        name: 'Historical Knowledge',
        description: 'Knowledge of family history and stories',
        type: SkillType.knowledge,
      ),
      Skill(
        name: 'Analytical Thinking',
        description: 'Ability to analyze complex information',
        type: SkillType.knowledge,
      ),
      
      // 사회적 스킬
      Skill(
        name: 'Communication',
        description: 'Ability to communicate clearly and effectively',
        type: SkillType.social,
      ),
      Skill(
        name: 'Empathy',
        description: 'Ability to understand and relate to others',
        type: SkillType.social,
      ),
      
      // 생존 스킬
      Skill(
        name: 'Stress Management',
        description: 'Ability to maintain composure in stressful situations',
        type: SkillType.survival,
      ),
      Skill(
        name: 'Adaptability',
        description: 'Ability to adapt quickly to changing environments',
        type: SkillType.survival,
      ),
    ];
  }
} 