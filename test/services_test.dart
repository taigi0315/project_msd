import 'package:flutter_test/flutter_test.dart';
import 'package:family_choi_app/models/character.dart';
import 'package:family_choi_app/models/mission.dart';
import 'package:family_choi_app/services/openai_service.dart';
import 'package:family_choi_app/services/mock_data_service.dart';
import 'package:family_choi_app/models/project.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([OpenAIService])
void main() {
  group('MockDataService Tests', () {
    late MockDataService dataService;
    
    setUp(() async {
      dataService = MockDataService();
      await dataService.initialize();
    });
    
    test('Character creation and experience calculation test', () async {
      // Create character
      final character = Character(
        name: 'Test Character',
        userId: 'test_user_id',
        specialty: CharacterSpecialty.warrior,
        battleCry: 'Battle cry for testing!',
      );
      
      // Check initial experience
      expect(character.level, 1);
      expect(character.totalExperience, 0);
      expect(character.experienceToNextLevel, 100);
      
      // Add experience
      await character.gainExperience(50);
      expect(character.totalExperience, 50);
      expect(character.experienceToNextLevel, 50);
      expect(character.level, 1);
      
      // Add experience for level up
      await character.gainExperience(50);
      expect(character.totalExperience, 100);
      expect(character.level, 2);
      expect(character.experienceToNextLevel, 200); // Experience requirement increases for new level
    });
    
    test('Mission creation and status change test', () {
      // Create mission
      final mission = Mission(
        name: 'Test Mission',
        description: 'This is a test mission',
        experienceReward: 100,
        status: MissionStatus.todo,
        creatorCharacterId: 'test_character_id',
      );
      
      // Check initial status
      expect(mission.status, MissionStatus.todo);
      
      // Change status
      mission.startMission('test_character_id');
      expect(mission.status, MissionStatus.inProgress);
      
      mission.completeMission();
      expect(mission.status, MissionStatus.completed);
    });
    
    test('Adding missions to project test', () {
      // Create project
      final project = Project(
        name: 'Test Project',
        description: 'This is a test project',
        goals: ['Test Goal 1', 'Test Goal 2'],
        creatorCharacterId: 'test_character_id',
        clanId: 'test_clan_id',
      );
      
      // Check initial mission count
      expect(project.missions.length, 0);
      
      // Add mission
      final mission = Mission(
        name: 'Test Mission',
        description: 'This is a test mission',
        experienceReward: 100,
        status: MissionStatus.todo,
        creatorCharacterId: 'test_character_id',
      );
      
      project.addMission(mission);
      expect(project.missions.length, 1);
      expect(project.missions.first.name, 'Test Mission');
    });
  });
  
  group('OpenAIService Tests (Mock Mode)', () {
    late OpenAIService openAIService;
    
    setUp(() async {
      openAIService = OpenAIService();
      await openAIService.initialize();
    });
    
    test('Project name generation test', () async {
      final projectName = await openAIService.generateProjectName('Family History Recording');
      expect(projectName.isNotEmpty, true);
    });
    
    test('Mission generation test', () async {
      final missions = await openAIService.generateMissions(
        'Family History Recording',
        'Family Chronicles Project',
        3
      );
      
      expect(missions.length, 3);
      expect(missions[0].name.isNotEmpty, true);
      expect(missions[0].description.isNotEmpty, true);
      expect(missions[0].experienceReward, isNotNull);
      expect(missions[0].experienceReward! > 0, true);
    });
    
    test('Achievement generation test', () async {
      final achievements = await openAIService.generateAchievements(
        'Family History Recording',
        'Family Chronicles Project'
      );
      
      expect(achievements.length, 3);
      expect(achievements[0].name.isNotEmpty, true);
      expect(achievements[0].description.isNotEmpty, true);
      expect(achievements[0].experienceReward > 0, true);
      
      // First achievement is automatically unlocked
      expect(achievements[0].isUnlocked, true);
      expect(achievements[1].isUnlocked, false);
    });
  });
} 