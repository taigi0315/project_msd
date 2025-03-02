import 'package:flutter_test/flutter_test.dart';
import 'package:family_choi_app/models/character.dart';
import 'package:family_choi_app/models/mission.dart';
import 'package:family_choi_app/services/openai_service.dart';
import 'package:family_choi_app/services/mock_data_service.dart';
import 'package:family_choi_app/models/project.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Mocks 생성
@GenerateMocks([OpenAIService])
void main() {
  group('MockDataService 테스트', () {
    late MockDataService dataService;
    
    setUp(() async {
      dataService = MockDataService();
      await dataService.initialize();
    });
    
    test('캐릭터 생성 및 경험치 계산 테스트', () async {
      // 캐릭터 생성
      final character = Character(
        name: '테스트 캐릭터',
        userId: 'test_user_id',
        specialty: CharacterSpecialty.warrior,
        battleCry: '테스트를 위한 전투 구호!',
      );
      
      // 초기 경험치 확인
      expect(character.level, 1);
      expect(character.totalExperience, 0);
      expect(character.experienceToNextLevel, 100);
      
      // 경험치 추가
      await character.gainExperience(50);
      expect(character.totalExperience, 50);
      expect(character.experienceToNextLevel, 50);
      expect(character.level, 1);
      
      // 레벨업을 위한 경험치 추가
      await character.gainExperience(50);
      expect(character.totalExperience, 100);
      expect(character.level, 2);
      expect(character.experienceToNextLevel, 200); // 새로운 레벨에 맞게 요구 경험치 증가
    });
    
    test('미션 생성 및 상태 변경 테스트', () {
      // 미션 생성
      final mission = Mission(
        name: '테스트 미션',
        description: '이것은 테스트 미션입니다',
        experienceReward: 100,
        status: MissionStatus.todo,
        creatorCharacterId: 'test_character_id',
      );
      
      // 초기 상태 확인
      expect(mission.status, MissionStatus.todo);
      
      // 상태 변경
      mission.startMission('test_character_id');
      expect(mission.status, MissionStatus.inProgress);
      
      mission.completeMission();
      expect(mission.status, MissionStatus.completed);
    });
    
    test('프로젝트에 미션 추가 테스트', () {
      // 프로젝트 생성
      final project = Project(
        name: '테스트 프로젝트',
        description: '이것은 테스트 프로젝트입니다',
        goals: ['테스트 목표 1', '테스트 목표 2'],
        creatorCharacterId: 'test_character_id',
        clanId: 'test_clan_id',
      );
      
      // 초기 미션 수 확인
      expect(project.missions.length, 0);
      
      // 미션 추가
      final mission = Mission(
        name: '테스트 미션',
        description: '이것은 테스트 미션입니다',
        experienceReward: 100,
        status: MissionStatus.todo,
        creatorCharacterId: 'test_character_id',
      );
      
      project.addMission(mission);
      expect(project.missions.length, 1);
      expect(project.missions.first.name, '테스트 미션');
    });
  });
  
  group('OpenAIService 테스트 (목업 모드)', () {
    late OpenAIService openAIService;
    
    setUp(() async {
      openAIService = OpenAIService();
      await openAIService.initialize();
    });
    
    test('프로젝트 이름 생성 테스트', () async {
      final projectName = await openAIService.generateProjectName('가족 역사 기록하기');
      expect(projectName.isNotEmpty, true);
    });
    
    test('미션 생성 테스트', () async {
      final missions = await openAIService.generateMissions(
        '가족 역사 기록하기',
        '가족 연대기 프로젝트',
        3
      );
      
      expect(missions.length, 3);
      expect(missions[0].name.isNotEmpty, true);
      expect(missions[0].description.isNotEmpty, true);
      expect(missions[0].experienceReward, isNotNull);
      expect(missions[0].experienceReward! > 0, true);
    });
    
    test('업적 생성 테스트', () async {
      final achievements = await openAIService.generateAchievements(
        '가족 역사 기록하기',
        '가족 연대기 프로젝트'
      );
      
      expect(achievements.length, 3);
      expect(achievements[0].name.isNotEmpty, true);
      expect(achievements[0].description.isNotEmpty, true);
      expect(achievements[0].experienceReward > 0, true);
      
      // 첫 번째 업적은 자동으로 해제됨
      expect(achievements[0].isUnlocked, true);
      expect(achievements[1].isUnlocked, false);
    });
  });
} 