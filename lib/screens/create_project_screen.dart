import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/clan.dart';
import '../models/project.dart';
import '../models/mission.dart' as app_mission;
import '../services/mock_ai_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

/// 프로젝트 생성 화면
/// 새로운 프로젝트를 생성하는 화면입니다.
class CreateProjectScreen extends StatefulWidget {
  final Character character;
  final Clan clan;
  
  const CreateProjectScreen({
    super.key, 
    required this.character, 
    required this.clan,
  });

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  // 상태 관리
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isGeneratingName = false;
  bool _isGeneratingMissions = false;
  String? _errorMessage;
  final List<app_mission.Mission> _missions = [];
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30)); // 기본값은 현재로부터 30일 후
  
  // AI 서비스 및 데이터 서비스
  late MockAIService _aiService;
  late MockDataService _dataService;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('📋 CreateProjectScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('초기화 중...');
    
    _aiService = MockAIService();
    
    // 랜덤 이름으로 초기화
    _generateRandomProjectName();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataService = Provider.of<MockDataService>(context, listen: false);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _debugPrint('리소스 해제됨');
    super.dispose();
  }
  
  /// 프로젝트 이름 랜덤 생성
  Future<void> _generateRandomProjectName() async {
    _debugPrint('프로젝트 이름 랜덤 생성 중...');
    
    setState(() {
      _isGeneratingName = true;
    });
    
    try {
      final projectName = _aiService.generateProjectName();
      
      setState(() {
        _nameController.text = projectName;
      });
      
      _debugPrint('생성된 프로젝트 이름: $projectName');
    } catch (e) {
      _debugPrint('프로젝트 이름 생성 오류: $e');
    } finally {
      setState(() {
        _isGeneratingName = false;
      });
    }
  }
  
  /// 초기 미션 자동 생성
  Future<void> _generateInitialMissions() async {
    _debugPrint('초기 미션 자동 생성 중...');
    
    // 프로젝트 이름과 설명이 비어있으면 생성 불가
    if (_nameController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로젝트 이름과 설명을 먼저 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isGeneratingMissions = true;
    });
    
    try {
      // 3~5개의 미션 생성
      final count = 3 + (DateTime.now().millisecondsSinceEpoch % 3);
      final newMissions = <app_mission.Mission>[];
      
      for (var i = 0; i < count; i++) {
        final missionName = _aiService.generateMissionName();
        final missionDescription = _aiService.generateMissionDescription();
        
        final mission = app_mission.Mission(
          id: const Uuid().v4(),
          name: missionName,
          description: missionDescription,
          status: app_mission.MissionStatus.todo,
          creatorCharacterId: widget.character.id,
          assignedCharacterIds: [],
          experienceReward: 50 + (i * 10), // 50, 60, 70, 80, 90
        );
        
        newMissions.add(mission);
        _debugPrint('미션 생성: ${mission.name}');
      }
      
      setState(() {
        _missions.clear();
        _missions.addAll(newMissions);
      });
      
      _debugPrint('${newMissions.length}개의 미션 생성 완료');
      
      // 알림 표시
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newMissions.length}개의 미션이 생성되었습니다'),
        ),
      );
    } catch (e) {
      _debugPrint('미션 생성 오류: $e');
      
      // 에러 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('미션 생성 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingMissions = false;
      });
    }
  }
  
  /// 미션 추가
  void _addMission() {
    _debugPrint('미션 직접 추가');
    
    showDialog(
      context: context,
      builder: (context) => _MissionDialog(
        onAdd: (name, description, experienceReward) {
          setState(() {
            final mission = app_mission.Mission(
              id: const Uuid().v4(),
              name: name,
              description: description,
              status: app_mission.MissionStatus.todo,
              creatorCharacterId: widget.character.id,
              assignedCharacterIds: [],
              experienceReward: experienceReward,
            );
            
            _missions.add(mission);
            _debugPrint('미션 추가됨: $name');
          });
        },
      ),
    );
  }
  
  /// 미션 삭제
  void _removeMission(app_mission.Mission mission) {
    _debugPrint('미션 삭제: ${mission.name}');
    
    setState(() {
      _missions.remove(mission);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('미션이 삭제되었습니다: ${mission.name}'),
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () {
            setState(() {
              _missions.add(mission);
              _debugPrint('미션 삭제 실행 취소: ${mission.name}');
            });
          },
        ),
      ),
    );
  }
  
  /// 프로젝트 생성 시도
  Future<void> _createProject() async {
    // 폼 검증
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // 미션이 없는 경우 확인
    if (_missions.isEmpty) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('미션 없음'),
          content: const Text('미션이 없는 프로젝트를 생성하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('계속'),
            ),
          ],
        ),
      );
      
      if (shouldContinue != true) {
        return;
      }
    }
    
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    
    _debugPrint('프로젝트 생성 시도: $name');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 첫 번째 보상 업적 추가 (프로젝트 생성자에게만 해제)
      final achievements = <Achievement>[
        Achievement(
          name: 'Project Founder',
          description: 'Created your first project!',
          condition: 'Create a project',
          experienceReward: 100,
          tier: AchievementTier.bronze,
          isUnlocked: true,
          unlockedAt: DateTime.now()
        ),
        Achievement(
          name: 'Mission Strategist',
          description: 'Created 5 or more missions.',
          condition: 'Create 5 or more missions',
          experienceReward: 200,
          tier: AchievementTier.silver
        ),
        Achievement(
          name: 'Project Master',
          description: 'Successfully completed a project.',
          condition: 'Complete all missions',
          experienceReward: 500,
          tier: AchievementTier.gold
        ),
      ];
      
      // 최종 프로젝트 생성
      final newProject = Project(
        name: name,
        description: description,
        clanId: widget.clan.id,
        creatorCharacterId: widget.character.id,
        dueDate: _dueDate,
        missions: _missions.map((m) => Mission(
          id: m.id,
          name: m.name,
          description: m.description,
          status: MissionStatus.todo,
          assignedToId: m.assignedCharacterIds.isNotEmpty ? m.assignedCharacterIds.first : null,
          experienceReward: m.experienceReward,
        )).toList(),
        assignedCharacterIds: [widget.character.id],
        achievements: achievements,
      );
      
      _dataService.addProject(newProject).then((_) {
        // 클랜에 프로젝트 추가
        final updatedClan = widget.clan;
        updatedClan.addProject(newProject.id);
        _dataService.updateClan(updatedClan);
        
        // 경험치 보상 지급
        final expReward = achievements[0].experienceReward;
        widget.character.addExperience(expReward);
        _dataService.updateCharacter(widget.character);
        
        // 성공 메시지 표시 및 화면 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로젝트가 성공적으로 생성되었습니다!')),
        );
        
        Navigator.pop(context, newProject);
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _errorMessage = '프로젝트 생성 중 오류가 발생했습니다: $error';
        });
      });
    } catch (e) {
      _debugPrint('프로젝트 생성 오류: $e');
      
      setState(() {
        _errorMessage = '프로젝트 생성 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('새 프로젝트 생성'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 상단 제목
                    const Text(
                      '새로운 모험을 시작하세요',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      '클랜의 새 프로젝트를 생성하고 미션을 추가하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 에러 메시지
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // 프로젝트 정보 카드
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '프로젝트 정보',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 프로젝트 이름 입력
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: '프로젝트 이름',
                                      hintText: '프로젝트의 이름을 입력하세요',
                                      prefixIcon: const Icon(Icons.folder, color: AppTheme.primaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return '프로젝트 이름을 입력해주세요';
                                      }
                                      if (value.length < 3) {
                                        return '프로젝트 이름은 최소 3글자 이상이어야 합니다';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                // 랜덤 이름 생성 버튼
                                IconButton(
                                  onPressed: _isGeneratingName ? null : _generateRandomProjectName,
                                  icon: _isGeneratingName
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.autorenew),
                                  tooltip: '랜덤 이름 생성',
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 프로젝트 설명 입력
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: '프로젝트 설명',
                                hintText: '프로젝트에 대한 설명을 입력하세요',
                                prefixIcon: const Icon(Icons.description, color: AppTheme.primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '프로젝트 설명을 입력해주세요';
                                }
                                if (value.length < 10) {
                                  return '프로젝트 설명은 최소 10글자 이상이어야 합니다';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 미션 섹션 헤더
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '미션',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        // 미션 자동 생성 버튼
                        TextButton.icon(
                          onPressed: _isGeneratingMissions ? null : _generateInitialMissions,
                          icon: _isGeneratingMissions
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: const Text('자동 생성'),
                        ),
                      ],
                    ),
                    
                    // 미션 목록
                    if (_missions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Text(
                                '미션이 없습니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                '미션을 추가하거나 자동으로 생성해보세요',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _missions.length,
                        itemBuilder: (context, index) {
                          final mission = _missions[index];
                          return _buildMissionItem(mission);
                        },
                      ),
                    
                    // 미션 추가 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: OutlinedButton.icon(
                        onPressed: _addMission,
                        icon: const Icon(Icons.add),
                        label: const Text('미션 추가'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 프로젝트 생성 버튼
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '프로젝트 생성하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 취소 버튼
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  /// 미션 아이템 위젯
  Widget _buildMissionItem(app_mission.Mission mission) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 미션 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment,
                color: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 미션 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (mission.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        mission.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // 경험치 표시
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      
                      const SizedBox(width: 4),
                      
                      Text(
                        '${mission.experienceReward} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 삭제 버튼
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeMission(mission),
              tooltip: '미션 삭제',
            ),
          ],
        ),
      ),
    );
  }
}

/// 미션 추가 다이얼로그
class _MissionDialog extends StatefulWidget {
  final Function(String name, String description, int experienceReward) onAdd;
  
  const _MissionDialog({required this.onAdd});

  @override
  State<_MissionDialog> createState() => _MissionDialogState();
}

class _MissionDialogState extends State<_MissionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _experienceReward = 50;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _handleAdd() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        _experienceReward,
      );
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('미션 추가'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 미션 이름
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '미션 이름',
                hintText: '미션의 이름을 입력하세요',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '미션 이름을 입력해주세요';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 미션 설명
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '미션 설명',
                hintText: '미션에 대한 설명을 입력하세요',
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // 경험치 보상
            Row(
              children: [
                const Text('경험치 보상:'),
                
                Expanded(
                  child: Slider(
                    value: _experienceReward.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() {
                        _experienceReward = value.toInt();
                      });
                    },
                  ),
                ),
                
                Text(
                  '$_experienceReward XP',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _handleAdd,
          child: const Text('추가'),
        ),
      ],
    );
  }
} 