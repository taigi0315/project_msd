import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/character.dart';
import '../models/project.dart';
import '../models/clan.dart';
import '../models/mission.dart' as app_mission;
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

/// 프로젝트 상세 화면
/// 선택한 프로젝트의 모든 세부정보와 미션 목록을 표시합니다.
class ProjectDetailScreen extends StatefulWidget {
  final Character character;
  final Project project;
  final Clan clan;
  
  const ProjectDetailScreen({
    super.key,
    required this.character,
    required this.project,
    required this.clan,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  Project? _project;
  List<Character> _assignedMembers = [];
  bool _isCharacterOwner = false;
  late TabController _tabController;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('📋 ProjectDetailScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProjectData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  /// 프로젝트 데이터 로드
  Future<void> _loadProjectData() async {
    _debugPrint('프로젝트 데이터 로딩 중...');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 최신 프로젝트 데이터 로드
      final updatedProject = await dataService.getProjectById(widget.project.id);
      if (updatedProject == null) {
        throw Exception('프로젝트를 찾을 수 없습니다');
      }
      
      // 할당된 멤버 정보 로드
      final assignedMembers = <Character>[];
      for (final memberId in updatedProject.assignedCharacterIds) {
        final member = await dataService.getCharacterById(memberId);
        if (member != null) {
          assignedMembers.add(member);
        }
      }
      
      // 현재 캐릭터가 프로젝트 소유자인지 확인
      _isCharacterOwner = updatedProject.creatorCharacterId == widget.character.id;
      
      setState(() {
        _project = updatedProject;
        _assignedMembers = assignedMembers;
        _isLoading = false;
      });
      
      _debugPrint('프로젝트 데이터 로드 완료: ${updatedProject.name}');
    } catch (e) {
      _debugPrint('프로젝트 데이터 로드 오류: $e');
      
      setState(() {
        _errorMessage = '프로젝트 데이터를 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }
  
  /// 미션 상태 업데이트
  Future<void> _updateMissionStatus(app_mission.Mission mission, app_mission.MissionStatus newStatus) async {
    _debugPrint('미션 상태 업데이트: ${mission.name} -> $newStatus');
    
    try {
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 미션 복사본 생성 및 상태 업데이트
      final updatedAppMission = mission.copyWith(status: newStatus);
      
      // 앱 미션을 프로젝트 미션으로 변환
      final updatedProjectMission = _convertToProjectMission(updatedAppMission);
      
      // 프로젝트의 미션 목록 업데이트
      final projectCopy = _project!.copyWith();
      final missionIndex = projectCopy.missions.indexWhere((m) => m.id == mission.id);
      
      if (missionIndex != -1) {
        projectCopy.missions[missionIndex] = updatedProjectMission;
        
        // 미션이 완료 상태로 변경된 경우 XP 지급
        if (newStatus == app_mission.MissionStatus.completed && mission.status != app_mission.MissionStatus.completed) {
          widget.character.gainExperience(mission.experienceReward);
          await dataService.updateCharacter(widget.character);
          
          // 완료 축하 메시지 표시
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('미션 완료! +${mission.experienceReward} XP 획득!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // 프로젝트 업데이트 저장
        await dataService.updateProject(projectCopy);
        
        // UI 갱신
        setState(() {
          _project = projectCopy;
        });
      }
    } catch (e) {
      _debugPrint('미션 상태 업데이트 오류: $e');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('미션 상태 업데이트 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// 미션 할당 대화상자 표시
  Future<void> _showAssignMissionDialog(app_mission.Mission mission) async {
    _debugPrint('미션 할당 대화상자 표시');
    
    try {
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 클랜의 모든 멤버 로드
      final clanMembers = <Character>[];
      for (final memberId in widget.clan.memberIds) {
        final member = await dataService.getCharacterById(memberId);
        if (member != null) {
          clanMembers.add(member);
        }
      }
      
      if (!mounted) return;
      
      // 멤버 선택 대화상자 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('미션 할당'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: clanMembers.length,
              itemBuilder: (context, index) {
                final member = clanMembers[index];
                final bool isAssigned = mission.assignedCharacterIds.contains(member.id);
                
                return CheckboxListTile(
                  title: Text(member.name),
                  subtitle: Text('Lv.${member.level} ${member.specialty.displayName}'),
                  value: isAssigned,
                  onChanged: (bool? value) {
                    if (value == true) {
                      mission.assignedCharacterIds.add(member.id);
                    } else {
                      mission.assignedCharacterIds.remove(member.id);
                    }
                    setState(() {});
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  // 프로젝트의 미션 목록 업데이트
                  final projectCopy = _project!.copyWith();
                  final missionIndex = projectCopy.missions.indexWhere((m) => m.id == mission.id);
                  
                  if (missionIndex != -1) {
                    // 업데이트된 미션 정보 저장
                    await dataService.updateProject(projectCopy);
                    
                    // UI 갱신
                    setState(() {
                      _project = projectCopy;
                    });
                  }
                } catch (e) {
                  _debugPrint('미션 할당 저장 오류: $e');
                  
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('미션 할당 저장 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      );
    } catch (e) {
      _debugPrint('미션 할당 대화상자 오류: $e');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('미션 할당 처리 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// 미션 삭제
  Future<void> _deleteMission(app_mission.Mission mission) async {
    _debugPrint('미션 삭제: ${mission.name}');
    
    try {
      // 삭제 확인 대화상자
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('미션 삭제 확인'),
          content: Text('정말로 "${mission.name}" 미션을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      final dataService = Provider.of<MockDataService>(context, listen: false);
      
      // 프로젝트의 미션 목록 업데이트
      final projectCopy = _project!.copyWith();
      projectCopy.missions.removeWhere((m) => m.id == mission.id);
      
      // 프로젝트 업데이트 저장
      await dataService.updateProject(projectCopy);
      
      // UI 갱신
      setState(() {
        _project = projectCopy;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('미션이 삭제되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _debugPrint('미션 삭제 오류: $e');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('미션 삭제 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// 새 미션 추가 대화상자
  Future<void> _showAddMissionDialog() async {
    _debugPrint('새 미션 추가 대화상자 표시');
    
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final experienceController = TextEditingController(text: '100');
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 미션 추가'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
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
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '미션 설명',
                    hintText: '미션에 대한 설명을 입력하세요',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '미션 설명을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: experienceController,
                  decoration: const InputDecoration(
                    labelText: '경험치 보상',
                    hintText: '미션 완료 시 획득할 경험치',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '경험치 보상을 입력해주세요';
                    }
                    final exp = int.tryParse(value);
                    if (exp == null || exp <= 0) {
                      return '유효한 경험치 값을 입력해주세요';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // 폼 데이터 추출
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                final experienceReward = int.parse(experienceController.text.trim());
                
                Navigator.of(context).pop();
                
                try {
                  final dataService = Provider.of<MockDataService>(context, listen: false);
                  
                  // 새 미션 생성
                  final newMission = app_mission.Mission(
                    name: name,
                    description: description,
                    experienceReward: experienceReward,
                    status: app_mission.MissionStatus.todo,
                    creatorCharacterId: widget.character.id,
                    assignedCharacterIds: [],
                  );
                  
                  // 프로젝트에 미션 추가
                  final projectCopy = _project!.copyWith();
                  
                  // project.dart의 Mission 형식으로 변환
                  final projectMission = Mission(
                    id: newMission.id,
                    name: newMission.name,
                    description: newMission.description,
                    status: MissionStatus.todo,
                    assignedToId: newMission.assignedCharacterIds.isNotEmpty ? 
                      newMission.assignedCharacterIds.first : null,
                    experienceReward: newMission.experienceReward
                  );
                  
                  projectCopy.missions.add(projectMission);
                  
                  // 프로젝트 업데이트 저장
                  await dataService.updateProject(projectCopy);
                  
                  // UI 갱신
                  setState(() {
                    _project = projectCopy;
                  });
                  
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('새 미션이 추가되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  _debugPrint('미션 추가 오류: $e');
                  
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('미션 추가 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_project?.name ?? '프로젝트 상세'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjectData,
            tooltip: '새로고침',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '개요', icon: Icon(Icons.info_outline)),
            Tab(text: '미션', icon: Icon(Icons.task_alt)),
            Tab(text: '멤버', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadProjectData,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildMissionsTab(),
                    _buildMembersTab(),
                  ],
                ),
      floatingActionButton: _isCharacterOwner && _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _showAddMissionDialog,
              child: const Icon(Icons.add),
              tooltip: '새 미션 추가',
            )
          : null,
    );
  }
  
  /// 개요 탭 위젯
  Widget _buildOverviewTab() {
    if (_project == null) {
      return const Center(child: Text('프로젝트 정보를 불러올 수 없습니다'));
    }
    
    final completedMissions = _project!.missions.where((m) => m.status == app_mission.MissionStatus.completed).length;
    final totalMissions = _project!.missions.length;
    final progress = totalMissions > 0 ? completedMissions / totalMissions : 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로젝트 헤더 카드
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _project!.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _project!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    '생성일',
                    _formatDate(_project!.createdAt),
                    Icons.calendar_today,
                  ),
                  _buildInfoRow(
                    '상태',
                    _getProjectStatusText(),
                    Icons.sync,
                  ),
                  _buildInfoRow(
                    '미션',
                    '$completedMissions / $totalMissions',
                    Icons.task_alt,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 진행률
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '프로젝트 진행률',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    color: AppTheme.primaryColor,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 최근 활동
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '최근 활동',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  // 여기에 최근 활동 목록 추가 (미션 상태 변경 등)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('최근 활동 내역이 없습니다'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 미션 탭 위젯
  Widget _buildMissionsTab() {
    if (_project == null) {
      return const Center(child: Text('프로젝트 정보를 불러올 수 없습니다'));
    }
    
    if (_project!.missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('아직 미션이 없습니다'),
            const SizedBox(height: 24),
            if (_isCharacterOwner)
              ElevatedButton.icon(
                onPressed: _showAddMissionDialog,
                icon: const Icon(Icons.add),
                label: const Text('미션 추가하기'),
              ),
          ],
        ),
      );
    }
    
    // 미션 상태별로 분류 (프로젝트의 Mission 사용)
    final todoMissions = _project!.missions.where((m) => m.status.toString() == 'MissionStatus.todo').toList();
    final inProgressMissions = _project!.missions.where((m) => m.status.toString() == 'MissionStatus.inProgress').toList();
    final completedMissions = _project!.missions.where((m) => m.status.toString() == 'MissionStatus.completed').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 할 일 미션
          _buildMissionSection('할 일', todoMissions, app_mission.MissionStatus.todo),
          
          const SizedBox(height: 16),
          
          // 진행 중 미션
          _buildMissionSection('진행 중', inProgressMissions, app_mission.MissionStatus.inProgress),
          
          const SizedBox(height: 16),
          
          // 완료된 미션
          _buildMissionSection('완료됨', completedMissions, app_mission.MissionStatus.completed),
        ],
      ),
    );
  }
  
  /// 미션 섹션 위젯
  Widget _buildMissionSection(String title, List<Mission> projectMissions, app_mission.MissionStatus status) {
    // 프로젝트 미션을 앱 미션으로 변환
    final missions = projectMissions.map((m) => _convertToAppMission(m)).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Text(
                '$title (${missions.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getMissionStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        if (missions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('미션이 없습니다')),
          )
        else
          ...missions.map((mission) => _buildMissionCard(mission)),
      ],
    );
  }
  
  /// 프로젝트 미션을 앱 미션으로 변환
  app_mission.Mission _convertToAppMission(Mission projectMission) {
    return app_mission.Mission(
      id: projectMission.id,
      name: projectMission.name,
      description: projectMission.description,
      status: _convertToAppMissionStatus(projectMission.status),
      experienceReward: projectMission.experienceReward,
      creatorCharacterId: _project!.creatorCharacterId,
      assignedCharacterIds: projectMission.assignedToId != null 
          ? [projectMission.assignedToId!] 
          : [],
    );
  }
  
  /// 프로젝트 미션 상태를 앱 미션 상태로 변환
  app_mission.MissionStatus _convertToAppMissionStatus(MissionStatus status) {
    if (status.toString() == 'MissionStatus.todo') {
      return app_mission.MissionStatus.todo;
    } else if (status.toString() == 'MissionStatus.inProgress') {
      return app_mission.MissionStatus.inProgress;
    } else if (status.toString() == 'MissionStatus.completed') {
      return app_mission.MissionStatus.completed;
    } else {
      return app_mission.MissionStatus.todo; // 기본값
    }
  }
  
  /// 앱 미션을 프로젝트 미션으로 변환
  Mission _convertToProjectMission(app_mission.Mission appMission) {
    return Mission(
      id: appMission.id,
      name: appMission.name, 
      description: appMission.description,
      status: _convertToProjectMissionStatus(appMission.status),
      experienceReward: appMission.experienceReward,
      assignedToId: appMission.assignedCharacterIds.isNotEmpty 
          ? appMission.assignedCharacterIds.first 
          : null,
    );
  }
  
  /// 앱 미션 상태를 프로젝트 미션 상태로 변환
  MissionStatus _convertToProjectMissionStatus(app_mission.MissionStatus status) {
    switch (status) {
      case app_mission.MissionStatus.todo:
        return MissionStatus.todo;
      case app_mission.MissionStatus.inProgress:
        return MissionStatus.inProgress;
      case app_mission.MissionStatus.completed:
        return MissionStatus.completed;
      default:
        return MissionStatus.todo; // 기본값
    }
  }
  
  /// 미션 카드 위젯
  Widget _buildMissionCard(app_mission.Mission mission) {
    final isAssigned = mission.assignedCharacterIds.contains(widget.character.id);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getMissionStatusColor(mission.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission.name,
                  style: TextStyle(
                    decoration: mission.status == app_mission.MissionStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              if (isAssigned)
                const Tooltip(
                  message: '나에게 할당됨',
                  child: Icon(Icons.person, size: 16, color: AppTheme.secondaryColor),
                ),
            ],
          ),
          subtitle: Text('보상: ${mission.experienceReward} XP'),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(mission.description),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 상태 변경 드롭다운
                      Expanded(
                        child: DropdownButtonFormField<app_mission.MissionStatus>(
                          value: mission.status,
                          decoration: const InputDecoration(
                            labelText: '상태',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: app_mission.MissionStatus.values.map((status) {
                            return DropdownMenuItem<app_mission.MissionStatus>(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getMissionStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_getMissionStatusText(status)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null && newStatus != mission.status) {
                              _updateMissionStatus(mission, newStatus);
                            }
                          },
                        ),
                      ),
                      // 할당 버튼
                      if (_isCharacterOwner)
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          tooltip: '멤버 할당',
                          onPressed: () => _showAssignMissionDialog(mission),
                        ),
                      // 삭제 버튼
                      if (_isCharacterOwner)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: '미션 삭제',
                          color: Colors.red,
                          onPressed: () => _deleteMission(mission),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 멤버 탭 위젯
  Widget _buildMembersTab() {
    if (_assignedMembers.isEmpty) {
      return const Center(child: Text('프로젝트에 할당된 멤버가 없습니다'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _assignedMembers.length,
      itemBuilder: (context, index) {
        final member = _assignedMembers[index];
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(member.name),
            subtitle: Text('Lv.${member.level} ${member.specialty.displayName}'),
            trailing: member.id == _project!.creatorCharacterId
                ? const Chip(
                    label: Text('생성자'),
                    backgroundColor: AppTheme.secondaryColor,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                : null,
          ),
        );
      },
    );
  }
  
  /// 정보 행 위젯
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
  
  /// 프로젝트 상태 텍스트 반환
  String _getProjectStatusText() {
    if (_project == null) {
      return '알 수 없음';
    }
    
    final completedMissions = _project!.missions.where((m) => m.status == app_mission.MissionStatus.completed).length;
    final totalMissions = _project!.missions.length;
    
    if (totalMissions == 0) {
      return '시작 전';
    } else if (completedMissions == totalMissions) {
      return '완료됨';
    } else if (completedMissions == 0) {
      return '시작됨';
    } else {
      return '진행 중';
    }
  }
  
  /// 미션 상태 텍스트 반환
  String _getMissionStatusText(app_mission.MissionStatus status) {
    switch (status) {
      case app_mission.MissionStatus.todo:
        return '할 일';
      case app_mission.MissionStatus.inProgress:
        return '진행 중';
      case app_mission.MissionStatus.completed:
        return '완료됨';
      default:
        return '알 수 없음';
    }
  }
  
  /// 미션 상태 색상 반환
  Color _getMissionStatusColor(app_mission.MissionStatus status) {
    switch (status) {
      case app_mission.MissionStatus.todo:
        return Colors.grey;
      case app_mission.MissionStatus.inProgress:
        return Colors.blue;
      case app_mission.MissionStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
} 