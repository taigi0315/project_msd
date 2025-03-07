import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:family_choi_app/services/game_effects_service.dart';
import 'package:family_choi_app/models/game_sound.dart';
import 'skill.dart';

/// Character specialty roles in our epic RPG adventure!
enum CharacterSpecialty {
  /// Awesome leader with epic leadership skills
  leader('Leader', 'Leads the clan with epic boss vibes!'),
  
  /// Combat-specialized warrior ready to slay problems
  warrior('Warrior', 'Tackles tough quests head-on like a boss!'),
  
  /// Spell-slinging wizard with creative solutions
  mage('Mage', 'Solves problems with big brain energy!'),
  
  /// Life-saving healer keeping the squad healthy
  healer('Healer', 'Boosts team spirit and settles drama!'),
  
  /// Sneaky scout gathering all the intel
  scout('Scout', 'Collects intel and predicts the future like a psychic!'),
  
  /// Wild explorer finding all the secrets
  ranger('Ranger', 'Explores the wilderness and gathers juicy info!'),
  
  /// Sneaky sneaky stealth master
  rogue('Rogue', 'Uses 200 IQ moves to escape battles or bamboozle enemies!'),
  
  /// Holy support with divine blessings
  cleric('Cleric', 'Heals teammates and drops holy buffs on the squad!');

  /// Name to display in the UI
  final String displayName;
  
  /// What this awesome role actually does
  final String description;
  
  const CharacterSpecialty(this.displayName, this.description);
}

/// Skill types for our epic heroes
enum SkillType {
  /// Battle skills for getting EPIC VICTORIES
  combat,
  
  /// Big brain skills for solving puzzles
  knowledge,
  
  /// Talk-no-jutsu for convincing others
  social,
  
  /// Not dying in the wilderness skills
  survival,
}

/// RPG-style Character in our epic Family Quest app!
/// Each character represents a family member with special skills and stats.
/// Characters can join clans, complete missions, and level up!
class Character {
  final String id;
  final String name;
  final String userId;
  final String email;
  final CharacterSpecialty specialty;
  String battleCry;
  int level;
  int experience;
  String? clanId;
  Color color;
  List<String> skillIds; // Skills this character has mastered
  List<String> completedMissionIds; // Epic quests this hero has completed!
  DateTime? createdAt;
  DateTime? lastActive;
  
  // D&D character profile data
  String? dndClassName;
  String? dndSpecialty;
  List<String>? dndSkills;
  
  // Easy access to experience points
  int get experiencePoints => experience;
  
  // Method to get character skills (must be implemented externally)
  List<Skill> get skills {
    // Returns skills from default skills that match this character's skill IDs
    // In a real implementation, this would fetch from a database, but returning dummy data for now
    final defaultSkills = Skill.createDefaultSkills();
    if (skillIds.isEmpty) return [];
    
    // In reality, we should find skills matching the IDs, but for now just return the first few
    return defaultSkills.take(skillIds.length).toList();
  }
  
  Character({
    String? id,
    required this.name,
    required this.userId,
    this.email = '',
    required this.specialty,
    this.battleCry = "Let's make family history awesome!",
    this.level = 1,
    this.experience = 0,
    this.clanId,
    Color? color,
    List<String>? skillIds,
    List<String>? completedMissionIds,
    this.createdAt,
    this.lastActive,
    this.dndClassName,
    this.dndSpecialty,
    this.dndSkills,
  }) : 
    this.id = id ?? Uuid().v4(),
    this.color = color ?? Colors.blue,
    this.skillIds = skillIds ?? [],
    this.completedMissionIds = completedMissionIds ?? [];
  
  /// Calculate the XP needed for the next level
  int get experienceToNextLevel {
    // RPG-style exponential XP curve - the higher the level, the more XP needed!
    return (100 * level * (1 + level * 0.1)).round();
  }
  
  /// Calculate the XP needed for the next level (alias for compatibility)
  int calculateNextLevelExp() {
    return experienceToNextLevel;
  }
  
  /// Current XP progress percentage towards next level
  double get levelProgress {
    return experience / experienceToNextLevel;
  }
  
  /// Create a copy of the character with optional new values
  Character copyWith({
    String? id,
    String? name,
    String? userId,
    String? email,
    CharacterSpecialty? specialty,
    String? battleCry,
    int? level,
    int? experience,
    String? clanId,
    Color? color,
    List<String>? skillIds,
    List<String>? completedMissionIds,
    DateTime? createdAt,
    DateTime? lastActive,
    String? dndClassName,
    String? dndSpecialty,
    List<String>? dndSkills,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
      battleCry: battleCry ?? this.battleCry,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      clanId: clanId ?? this.clanId,
      color: color ?? this.color,
      skillIds: skillIds ?? List.from(this.skillIds),
      completedMissionIds: completedMissionIds ?? List.from(this.completedMissionIds),
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      dndClassName: dndClassName ?? this.dndClassName,
      dndSpecialty: dndSpecialty ?? this.dndSpecialty,
      dndSkills: dndSkills ?? this.dndSkills,
    );
  }
  
  /// Add skills to the character's skillset
  Character addSkills(List<Skill> skills) {
    final newSkillIds = List<String>.from(skillIds);
    for (final skill in skills) {
      if (!newSkillIds.contains(skill.id)) {
        newSkillIds.add(skill.id);
      }
    }
    return copyWith(skillIds: newSkillIds);
  }
  
  /// Add experience and handle level up process
  Future<bool> gainExperience(int amount) async {
    if (amount <= 0) return false;
    
    experience += amount;
    bool leveledUp = false;
    
    // Level up processing
    while (experience >= experienceToNextLevel) {
      experience -= experienceToNextLevel;
      level++;
      leveledUp = true;
      
      // Level up sound and animation
      if (leveledUp) {
        GameEffectsService().playSound(GameSound.levelUp);
      }
    }
    
    return leveledUp;
  }
  
  /// Add experience and handle level up process (backward compatibility)
  Future<bool> addExperience(int amount) async {
    return gainExperience(amount);
  }
  
  /// Set D&D character info from OpenAI generated data
  Character setDnDCharacterInfo(Map<String, dynamic> dndData) {
    return copyWith(
      dndClassName: dndData['class_name'],
      dndSpecialty: dndData['specialty'],
      dndSkills: List<String>.from(dndData['skills'] ?? []),
    );
  }
  
  /// Make character join a clan
  Character joinClan(String newClanId) {
    return copyWith(clanId: newClanId);
  }
  
  /// Remove character from clan
  Character leaveClan() {
    return copyWith(clanId: null);
  }
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'email': email,
      'specialty': specialty.toString().split('.').last,
      'battleCry': battleCry,
      'level': level,
      'experience': experience,
      'clanId': clanId,
      'color': color.value,
      'skillIds': skillIds,
      'completedMissionIds': completedMissionIds,
      'createdAt': createdAt?.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'dndClassName': dndClassName,
      'dndSpecialty': dndSpecialty,
      'dndSkills': dndSkills,
    };
  }
  
  /// Create character from JSON data
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      userId: json['userId'],
      email: json['email'] ?? '',
      specialty: _specialtyFromString(json['specialty'] ?? 'warrior'),
      battleCry: json['battleCry'] ?? "Let's make family history awesome!",
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      clanId: json['clanId'],
      color: Color(json['color'] ?? Colors.blue.value),
      skillIds: List<String>.from(json['skillIds'] ?? []),
      completedMissionIds: List<String>.from(json['completedMissionIds'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
      dndClassName: json['dndClassName'],
      dndSpecialty: json['dndSpecialty'],
      dndSkills: json['dndSkills'] != null ? List<String>.from(json['dndSkills']) : null,
    );
  }
  
  /// Helper method to convert string to CharacterSpecialty enum
  static CharacterSpecialty _specialtyFromString(String typeStr) {
    switch (typeStr) {
      case 'leader': return CharacterSpecialty.leader;
      case 'warrior': return CharacterSpecialty.warrior;
      case 'mage': return CharacterSpecialty.mage;
      case 'healer': return CharacterSpecialty.healer;
      case 'scout': return CharacterSpecialty.scout;
      case 'ranger': return CharacterSpecialty.ranger;
      case 'rogue': return CharacterSpecialty.rogue;
      case 'cleric': return CharacterSpecialty.cleric;
      default: return CharacterSpecialty.warrior;
    }
  }
} 