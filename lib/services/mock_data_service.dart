import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clan.dart';
import '../models/character.dart';
import '../models/project.dart';
import 'package:flutter/material.dart';
import 'package:family_choi_app/services/game_effects_service.dart';

/// Firebase를 대신하여, 로컬 저장소를 사용하는 모의 데이터 서비스
/// 실제 애플리케이션에서는 Firebase로 교체될 예정입니다.
class MockDataService {
  // 싱글톤 인스턴스
  static final MockDataService _instance = MockDataService._internal();
  
  // SharedPreferences 인스턴스
  late SharedPreferences _prefs;
  
  // 메모리 내 데이터 캐시
  final Map<String, Character> _characters = {};
  final Map<String, Clan> _clans = {};
  final Map<String, Project> _projects = {};
  
  // 데이터 변경 스트림 컨트롤러
  final _characterStreamController = StreamController<Map<String, Character>>.broadcast();
  final _clanStreamController = StreamController<Map<String, Clan>>.broadcast();
  final _projectStreamController = StreamController<Map<String, Project>>.broadcast();
  
  // 스트림 getter
  Stream<Map<String, Character>> get characterStream => _characterStreamController.stream;
  Stream<Map<String, Clan>> get clanStream => _clanStreamController.stream;
  Stream<Map<String, Project>> get projectStream => _projectStreamController.stream;

  /// 디버깅을 위한 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🗄️ MockDataService: $message');
  }
  
  /// 팩토리 생성자
  factory MockDataService() {
    return _instance;
  }
  
  /// 내부 생성자
  MockDataService._internal();
  
  /// 서비스 초기화
  Future<void> initialize() async {
    _debugPrint('Initializing service...');
    _prefs = await SharedPreferences.getInstance();
    await _loadAllData();
    _debugPrint('Data loading complete');
  }
  
  /// 모든 데이터 로드
  Future<void> _loadAllData() async {
    await _loadCharacters();
    await _loadClans();
    await _loadProjects();
  }
  
  /// 캐릭터 데이터 로드
  Future<void> _loadCharacters() async {
    _debugPrint('Loading character data...');
    _characters.clear();
    
    final charactersJson = _prefs.getStringList('characters') ?? [];
    for (var json in charactersJson) {
      try {
        final Map<String, dynamic> data = jsonDecode(json);
        final character = Character.fromJson(data);
        _characters[character.id] = character;
      } catch (e) {
        _debugPrint('Error parsing character data: $e');
      }
    }
    
    _characterStreamController.add(_characters);
    _debugPrint('${_characters.length} characters loaded');
  }
  
  /// 클랜 데이터 로드
  Future<void> _loadClans() async {
    _debugPrint('Loading clan data...');
    _clans.clear();
    
    final clansJson = _prefs.getStringList('clans') ?? [];
    for (var json in clansJson) {
      try {
        final Map<String, dynamic> data = jsonDecode(json);
        final clan = Clan.fromJson(data);
        _clans[clan.id] = clan;
      } catch (e) {
        _debugPrint('Error parsing clan data: $e');
      }
    }
    
    _clanStreamController.add(_clans);
    _debugPrint('${_clans.length} clans loaded');
  }
  
  /// 프로젝트 데이터 로드
  Future<void> _loadProjects() async {
    _debugPrint('Loading project data...');
    _projects.clear();
    
    final projectsJson = _prefs.getStringList('projects') ?? [];
    for (var json in projectsJson) {
      try {
        final Map<String, dynamic> data = jsonDecode(json);
        final project = Project.fromJson(data);
        _projects[project.id] = project;
      } catch (e) {
        _debugPrint('Error parsing project data: $e');
      }
    }
    
    _projectStreamController.add(_projects);
    _debugPrint('${_projects.length} projects loaded');
  }
  
  /// 모든 데이터 저장
  Future<void> _saveAllData() async {
    await _saveCharacters();
    await _saveClans();
    await _saveProjects();
  }
  
  /// 캐릭터 데이터 저장
  Future<void> _saveCharacters() async {
    _debugPrint('Saving character data...');
    final charactersJson = _characters.values.map((character) => 
      jsonEncode(character.toJson())).toList();
    
    await _prefs.setStringList('characters', charactersJson);
    _debugPrint('${charactersJson.length} characters saved');
  }
  
  /// 클랜 데이터 저장
  Future<void> _saveClans() async {
    _debugPrint('Saving clan data...');
    final clansJson = _clans.values.map((clan) => 
      jsonEncode(clan.toJson())).toList();
    
    await _prefs.setStringList('clans', clansJson);
    _debugPrint('${clansJson.length} clans saved');
  }
  
  /// 프로젝트 데이터 저장
  Future<void> _saveProjects() async {
    _debugPrint('Saving project data...');
    final projectsJson = _projects.values.map((project) => 
      jsonEncode(project.toJson())).toList();
    
    await _prefs.setStringList('projects', projectsJson);
    _debugPrint('${projectsJson.length} projects saved');
  }
  
  // 캐릭터 관련 CRUD 메서드
  
  /// 새 캐릭터 추가
  Future<Character> addCharacter(Character character) async {
    _debugPrint('Adding new character: ${character.name}');
    _characters[character.id] = character;
    _characterStreamController.add(_characters);
    await _saveCharacters();
    return character;
  }
  
  /// 캐릭터 수정
  Future<Character> updateCharacter(Character character) async {
    _debugPrint('Updating character: ${character.name}');
    _characters[character.id] = character;
    _characterStreamController.add(_characters);
    await _saveCharacters();
    return character;
  }
  
  /// 캐릭터 제거
  Future<void> removeCharacter(String characterId) async {
    _debugPrint('Deleting character: $characterId');
    _characters.remove(characterId);
    _characterStreamController.add(_characters);
    await _saveCharacters();
  }
  
  /// 캐릭터 조회
  Character? getCharacter(String characterId) {
    return _characters[characterId];
  }
  
  /// 사용자 ID로 캐릭터 조회
  Character? getCharacterByUserId(String userId) {
    try {
      return _characters.values.firstWhere((character) => character.userId == userId);
    } catch (e) {
      _debugPrint('Could not find character by user ID: $userId');
      return null;
    }
  }
  
  /// 모든 캐릭터 조회
  List<Character> getAllCharacters() {
    return _characters.values.toList();
  }
  
  // 클랜 관련 CRUD 메서드
  
  /// 새 클랜 추가
  Future<Clan> addClan(Clan clan) async {
    _debugPrint('Adding new clan: ${clan.name}');
    _clans[clan.id] = clan;
    _clanStreamController.add(_clans);
    await _saveClans();
    return clan;
  }
  
  /// 클랜 수정
  Future<Clan> updateClan(Clan clan) async {
    _debugPrint('Updating clan: ${clan.name}');
    _clans[clan.id] = clan;
    _clanStreamController.add(_clans);
    await _saveClans();
    return clan;
  }
  
  /// 클랜 제거
  Future<void> removeClan(String clanId) async {
    _debugPrint('Deleting clan: $clanId');
    _clans.remove(clanId);
    _clanStreamController.add(_clans);
    await _saveClans();
  }
  
  /// 클랜 조회
  Clan? getClan(String clanId) {
    return _clans[clanId];
  }
  
  /// 클랜 조회 (별칭)
  Clan? getClanById(String clanId) {
    return getClan(clanId);
  }
  
  /// 초대 코드로 클랜 조회
  Clan? getClanByInviteCode(String inviteCode) {
    try {
      return _clans.values.firstWhere((clan) => clan.inviteCode == inviteCode);
    } catch (e) {
      _debugPrint('Could not find clan by invite code: $inviteCode');
      return null;
    }
  }
  
  /// 모든 클랜 조회
  List<Clan> getAllClans() {
    return _clans.values.toList();
  }
  
  // 프로젝트 관련 CRUD 메서드
  
  /// 새 프로젝트 추가
  Future<Project> addProject(Project project) async {
    _debugPrint('Adding new project: ${project.name}');
    _projects[project.id] = project;
    
    // 클랜에 프로젝트 연결
    final clan = _clans[project.clanId];
    if (clan != null) {
      clan.addProject(project.id);
      await updateClan(clan);
    }
    
    _projectStreamController.add(_projects);
    await _saveProjects();
    return project;
  }
  
  /// 프로젝트 수정
  Future<Project> updateProject(Project project) async {
    _debugPrint('Updating project: ${project.name}');
    _projects[project.id] = project;
    _projectStreamController.add(_projects);
    await _saveProjects();
    return project;
  }
  
  /// 프로젝트 제거
  Future<void> removeProject(String projectId) async {
    _debugPrint('Deleting project: $projectId');
    final project = _projects[projectId];
    
    if (project != null) {
      // 클랜에서 프로젝트 연결 해제
      final clan = _clans[project.clanId];
      if (clan != null) {
        clan.removeProject(projectId);
        await updateClan(clan);
      }
    }
    
    _projects.remove(projectId);
    _projectStreamController.add(_projects);
    await _saveProjects();
  }
  
  /// 프로젝트 조회
  Project? getProject(String projectId) {
    return _projects[projectId];
  }
  
  /// 프로젝트 조회 (별칭)
  Project? getProjectById(String projectId) {
    return getProject(projectId);
  }
  
  /// 클랜 ID로 프로젝트 목록 조회
  List<Project> getProjectsByClanId(String clanId) {
    return _projects.values.where((project) => project.clanId == clanId).toList();
  }
  
  /// 모든 프로젝트 조회
  List<Project> getAllProjects() {
    return _projects.values.toList();
  }
  
  /// 미션 상태 업데이트
  Future<void> updateMissionStatus(String projectId, String missionId, MissionStatus status) async {
    final project = _projects[projectId];
    if (project == null) {
      _debugPrint('Project not found: $projectId');
      return;
    }
    
    final missionIndex = project.missions.indexWhere((m) => m.id == missionId);
    if (missionIndex == -1) {
      _debugPrint('Mission not found: $missionId');
      return;
    }
    
    project.missions[missionIndex].updateStatus(status);
    await updateProject(project);
  }
  
  /// 캐릭터가 업적을 획득하면 호출
  void unlockAchievement(String projectId, String achievementId, String characterId) {
    final project = getProject(projectId);
    if (project == null) {
      _debugPrint('Project not found: $projectId');
      return;
    }
    
    final achievement = project.getAchievement(achievementId);
    if (achievement == null) {
      _debugPrint('Achievement not found: $achievementId');
      return;
    }
    
    if (achievement.isUnlocked) {
      _debugPrint('Achievement already unlocked');
      return;
    }
    
    // 업적 해제 및 경험치 부여
    achievement.unlock(characterId);
    
    // 캐릭터 경험치 지급
    final character = getCharacterById(characterId);
    if (character != null) {
      character.gainExperience(achievement.getExperienceReward());
      _updateCharacterData(character);
    }
    
    // 변경된 프로젝트 저장
    _updateProjectData(project);
    
    // 스트림 갱신
    _projectStreamController.add(_projects);
    _characterStreamController.add(_characters);
  }
  
  /// 사용자의 클랜 목록 가져오기
  List<Clan> getUserClans(String characterId) {
    return _clans.values.where((clan) => 
      clan.memberIds.contains(characterId)).toList();
  }
  
  /// 샘플 데이터 생성 (테스트용)
  Future<void> createSampleData() async {
    if (_characters.isNotEmpty || _clans.isNotEmpty || _projects.isNotEmpty) {
      _debugPrint('Sample data already exists');
      return;
    }
    
    _debugPrint('Creating sample data...');
    
    // 캐릭터 생성
    final character = Character(
      name: 'Choi Warrior',
      userId: 'sample_user_id',
      specialty: CharacterSpecialty.warrior,
      battleCry: 'For victory!',
      email: 'warrior@choi.family'
    );
    
    // 클랜 생성
    final clan = Clan(
      name: 'Choi Family Clan',
      description: 'A clan for recording the great achievements of the Choi family.',
      leaderId: character.id,
      founderCharacterId: character.id
    );
    
    final updatedCharacter = character.joinClan(clan.id);
    
    // 프로젝트 생성
    final project = Project(
      name: 'Family Chronicles',
      description: 'A project to record the history and achievements of the Choi family.',
      clanId: clan.id,
      creatorCharacterId: character.id,
      dueDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    // 미션 생성
    final mission1 = Mission(
      id: 'sample-mission-1',
      name: 'Sample Mission 1',
      description: 'Description for Sample Mission 1',
      status: MissionStatus.todo,
      assignedToId: character.id,
      experienceReward: 100,
    );
    
    final mission2 = Mission(
      id: 'sample-mission-2',
      name: 'Sample Mission 2',
      description: 'Description for Sample Mission 2',
      status: MissionStatus.todo,
      assignedToId: character.id,
      experienceReward: 150,
    );
    
    final mission3 = Mission(
      id: 'sample-mission-3',
      name: 'Sample Mission 3',
      description: 'Description for Sample Mission 3',
      status: MissionStatus.todo,
      assignedToId: character.id,
      experienceReward: 200,
    );
    
    // 업적 생성
    final achievement1 = Achievement(
      name: 'Family Historian',
      description: 'Researched and recorded the history of the Choi family.',
      condition: 'Complete all missions',
      experienceReward: 500,
      tier: AchievementTier.gold,
    );
    
    final achievement2 = Achievement(
      name: 'Family Interviewer',
      description: 'Successfully completed interviews with family members.',
      condition: 'Complete the family interview mission',
      experienceReward: 200,
      tier: AchievementTier.silver,
    );
    
    final achievement3 = Achievement(
      name: 'Chronicle Recorder',
      description: 'Drafted the chronicles of the Choi family.',
      condition: 'Write a draft of the chronicles',
      experienceReward: 300,
      tier: AchievementTier.silver,
    );
    
    // 미션과 업적을 프로젝트에 추가
    project.addMission(mission1);
    project.addMission(mission2);
    project.addMission(mission3);
    project.addAchievement(achievement1);
    project.addAchievement(achievement2);
    project.addAchievement(achievement3);
    
    // 데이터 저장
    await addCharacter(updatedCharacter);
    await addClan(clan);
    await addProject(project);
    
    // 클랜에 프로젝트 연결
    clan.addProject(project.id);
    await updateClan(clan);
    
    _debugPrint('Sample data creation completed');
  }
  
  /// 서비스 종료 처리
  void dispose() {
    _characterStreamController.close();
    _clanStreamController.close();
    _projectStreamController.close();
    _debugPrint('Service terminated');
  }
  
  /// 캐릭터 ID로 캐릭터 조회
  Character? getCharacterById(dynamic characterId) {
    // ID가 int인 경우 String으로 변환
    final String id = characterId.toString();
    return getCharacter(id);
  }
  
  /// 캐릭터 데이터 내부 업데이트 메서드
  Future<void> _updateCharacterData(Character character) async {
    _debugPrint('Internal character data update: ${character.name}');
    _characters[character.id] = character;
    _characterStreamController.add(_characters);
    await _saveCharacters();
  }
  
  /// 프로젝트 데이터 내부 업데이트 메서드
  Future<void> _updateProjectData(Project project) async {
    _debugPrint('Internal project data update: ${project.name}');
    _projects[project.id] = project;
    _projectStreamController.add(_projects);
    await _saveProjects();
  }
  
  /// 로그아웃 처리
  Future<void> logout() async {
    _debugPrint('Processing logout...');
    
    // 현재 사용자 정보 삭제 (실제 구현에서는 Firebase Auth를 사용)
    await _prefs.remove('currentUserId');
    
    _debugPrint('Logout completed');
  }
  
  /// 캐릭터에 경험치 추가
  Future<bool> gainCharacterExperience(String characterId, int amount, {BuildContext? context}) async {
    _debugPrint('Attempting to add $amount experience to character ID $characterId');
    
    if (amount <= 0) {
      _debugPrint('Invalid experience value: $amount');
      return false;
    }
    
    // 캐릭터 찾기
    final Character? character = await getCharacter(characterId);
    if (character == null) {
      _debugPrint('Character not found: $characterId');
      return false;
    }
    
    // 경험치 추가 및 레벨업 확인
    final bool didLevelUp = await character.gainExperience(amount);
    
    // 캐릭터 저장
    await _saveCharacter(character);
    
    _debugPrint('Added $amount experience to character ID $characterId. Level up: $didLevelUp');
    return didLevelUp;
  }
  
  /// 캐릭터 저장
  Future<void> _saveCharacter(Character character) async {
    _debugPrint('Saving character: ${character.name}');
    _characters[character.id] = character;
    _characterStreamController.add(_characters);
    await _saveCharacters();
  }
  
  /// 사용자 로그인
  Future<dynamic> login(String email) async {
    _debugPrint('Login attempt: $email');
    
    // 이메일로 사용자 찾기 (실제 Firebase 대신 모의 구현)
    await Future.delayed(Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션
    
    // 기존 캐릭터 중에서 이메일과 일치하는 것이 있는지 확인
    try {
      final existingCharacter = _characters.values.firstWhere(
        (character) => character.email == email,
      );
      
      _debugPrint('Existing user found: ${existingCharacter.name}');
      return existingCharacter;
    } catch (e) {
      // 일치하는 캐릭터가 없을 경우
      _debugPrint('New user. Character creation required.');
      return null;
    }
  }
} 