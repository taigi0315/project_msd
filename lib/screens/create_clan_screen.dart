import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../models/clan.dart';
import '../services/mock_ai_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'clan_dashboard_screen.dart';

/// 클랜 생성 화면
/// 캐릭터가 새로운 클랜을 창설할 수 있는 화면입니다.
class CreateClanScreen extends StatefulWidget {
  final Character character;
  
  const CreateClanScreen({
    super.key, 
    required this.character,
  });

  @override
  State<CreateClanScreen> createState() => _CreateClanScreenState();
}

// 퀘스팅 목표 옵션 클래스
class QuestingGoalOption {
  final String title;
  final String description;
  
  QuestingGoalOption(this.title, this.description);
}

// 분위기 체크 옵션 클래스
class VibeCheckOption {
  final String title;
  final String description;
  
  VibeCheckOption(this.title, this.description);
}

// 작업 스타일 옵션 클래스
class WorkStyleOption {
  final String title;
  final String description;
  
  WorkStyleOption(this.title, this.description);
}

// 출전 명령 옵션 클래스
class CallToArmsOption {
  final String title;
  final String vibe;
  
  CallToArmsOption(this.title, this.vibe);
}

class _CreateClanScreenState extends State<CreateClanScreen> {
  // 상태 관리
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionEditController = TextEditingController();
  bool _isEditingDescription = false;
  
  // 선택된 옵션들
  String _selectedVibeCheck = 'Strategists\' Guild';
  String _selectedWorkStyle = 'Solo Quest';
  String _selectedQuestingGoal = 'Forge an Eternal Legacy!';
  String _selectedCallToArms = 'For glory and honor!';
  
  Color _selectedBannerColor = Colors.blue;
  String _selectedBannerIcon = 'shield';
  String _generatedDescription = '';
  bool _isLoading = false;
  bool _isGeneratingName = false;
  bool _isGeneratingDescription = false;
  String? _errorMessage;
  
  // 드롭다운 옵션들
  final List<QuestingGoalOption> _questingGoalOptions = [
    QuestingGoalOption(
      'Forge an Eternal Legacy!',
      'Perfect for clans aiming to create something lasting—be it an art empire, a family tradition, or a community impact. It\'s epic and timeless, appealing to dreamers and builders.'
    ),
    QuestingGoalOption(
      'Loot the Golden Hoard!',
      'A playful nod to wealth and success, ideal for projects focused on financial gain, resource gathering, or tangible rewards. It\'s cheeky yet bold.'
    ),
    QuestingGoalOption(
      'Slay the Dream Dragon!',
      'For clans chasing ambitious personal or group dreams—conquering challenges to make aspirations real. It\'s motivational with a monster-slaying vibe.'
    ),
    QuestingGoalOption(
      'Conquer the Realm of Chaos!',
      'Suits clans tackling disorganized or ambitious messes—organizing, creating order, or pulling off wild ideas. It\'s quirky and adventurous.'
    ),
    QuestingGoalOption(
      'Feast Upon Epic Glory!',
      'A celebration-focused goal for clans seeking joy, recognition, or shared victories—think food, fame, or festivities. It\'s warm and victorious.'
    ),
  ];
  
  final List<VibeCheckOption> _vibeCheckOptions = [
    VibeCheckOption(
      'Strategists\' Guild',
      'Detailed planning, step-by-step approach, thoughtful execution'
    ),
    VibeCheckOption(
      'Warriors\' Rush',
      'Bold action, fearless charging ahead, energetic momentum'
    ),
    VibeCheckOption(
      'Artisans\' Flow',
      'Creative process, artistic flair, intuitive development'
    ),
    VibeCheckOption(
      'Harmony Circle',
      'Balanced teamwork, supportive environment, collaborative spirit'
    ),
  ];
  
  final List<WorkStyleOption> _workStyleOptions = [
    WorkStyleOption(
      'Solo Quest',
      'Independent adventuring, self-reliant tasks, personal ownership'
    ),
    WorkStyleOption(
      'Allied Forces',
      'Coordinated teamwork, specialized roles, unified direction'
    ),
    WorkStyleOption(
      'Hive Mind',
      'Collective brainstorming, shared responsibility, group consensus'
    ),
    WorkStyleOption(
      'Tactical Squad',
      'Agile adaptation, strategic pivots, responsive planning'
    ),
  ];
  
  final List<CallToArmsOption> _callToArmsOptions = [
    CallToArmsOption('For glory and honor!', 'noble and inspiring'),
    CallToArmsOption('Victory or death!', 'fearless and determined'),
    CallToArmsOption('Together we rise!', 'unifying and uplifting'),
    CallToArmsOption('Chaos is a ladder!', 'opportunistic and bold'),
    CallToArmsOption('Unleash the kraken!', 'wild and unpredictable'),
    CallToArmsOption('By fire be purged!', 'intense and transformative'),
    CallToArmsOption('The night is dark and full of terrors!', 'mysterious and ominous'),
    CallToArmsOption('Winter is coming!', 'determined and forewarning'),
  ];
  
  final List<String> _bannerIconOptions = [
    'shield',
    'bolt',
    'star',
    'crown',
    'fire',
    'water',
    'earth',
    'air'
  ];
  
  // 퀘스팅 목표 설명 가져오기
  String _getQuestingGoalDescription() {
    for (var option in _questingGoalOptions) {
      if (option.title == _selectedQuestingGoal) {
        return option.description;
      }
    }
    return '';
  }
  
  // 출전 명령 분위기 가져오기
  String _getCallToArmsVibe() {
    for (var option in _callToArmsOptions) {
      if (option.title == _selectedCallToArms) {
        return option.vibe;
      }
    }
    return 'powerful';
  }
  
  // AI 서비스 및 데이터 서비스
  late MockAIService _aiService;
  late MockDataService _dataService;
  
  // 디버깅 출력
  void _debugPrint(String message) {
    // ignore: avoid_print
    print('🛡️ CreateClanScreen: $message');
  }
  
  @override
  void initState() {
    super.initState();
    _debugPrint('Initializing...');
    
    _aiService = MockAIService();
    
    // 랜덤 이름으로 초기화 (필요시)
    _generateRandomClanName();
    // 초기 설명 생성
    _generateDescription();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataService = Provider.of<MockDataService>(context, listen: false);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionEditController.dispose();
    _debugPrint('Resources released');
    super.dispose();
  }
  
  /// 클랜 이름 랜덤 생성
  Future<void> _generateRandomClanName() async {
    _debugPrint('Generating random clan name...');
    
    setState(() {
      _isGeneratingName = true;
    });
    
    try {
      final clanName = _aiService.generateProjectName(type: 'clan');
      
      setState(() {
        _nameController.text = clanName;
      });
      
      _debugPrint('Generated clan name: $clanName');
      _generateDescription();
    } catch (e) {
      _debugPrint('Error generating clan name: $e');
    } finally {
      setState(() {
        _isGeneratingName = false;
      });
    }
  }
  
  /// 설명 생성
  void _generateDescription() {
    setState(() {
      _isGeneratingDescription = true;
    });
    
    try {
      final clanName = _nameController.text.isNotEmpty ? 
          _nameController.text : "Unnamed Clan";
      final questingGoalDescription = _getQuestingGoalDescription();
      final callToArmsVibe = _getCallToArmsVibe();
      
      _generatedDescription = "Hail, adventurers! We, the mighty $clanName, are a band of $_selectedVibeCheck united by our grand quest to $_selectedQuestingGoal—$questingGoalDescription. With every step, we rally under our wild cry of \"$_selectedCallToArms\", a chant that's $callToArmsVibe. Together, we charge forth with laughter, valor, and a touch of glorious madness—our legend will echo through the realms!";
      
      // 편집 컨트롤러도 업데이트
      _descriptionEditController.text = _generatedDescription;
      
      _debugPrint('Generated description: $_generatedDescription');
    } catch (e) {
      _debugPrint('Error generating description: $e');
    } finally {
      setState(() {
        _isGeneratingDescription = false;
      });
    }
  }
  
  /// 클랜 생성 시도
  Future<void> _createClan() async {
    // 폼 검증
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final name = _nameController.text.trim();
    
    // 최종 설명 가져오기
    final finalDescription = _isEditingDescription ? 
        _descriptionEditController.text : _generatedDescription;
    
    _debugPrint('Attempting to create clan: $name');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 새 클랜 생성
      final newClan = Clan(
        id: const Uuid().v4(),
        name: name,
        description: finalDescription,
        inviteCode: _generateInviteCode(),
        founderCharacterId: widget.character.id,
        leaderId: widget.character.id,
        memberIds: [widget.character.id],
        createdAt: DateTime.now(),
      );
      
      // 데이터베이스에 저장
      await _dataService.addClan(newClan);
      
      // 캐릭터에 클랜 연결
      final updatedCharacter = widget.character.joinClan(newClan.id);
      await _dataService.updateCharacter(updatedCharacter);
      
      _debugPrint('Clan creation completed: ${newClan.name} (ID: ${newClan.id})');
      
      // 대시보드로 이동
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ClanDashboardScreen(character: updatedCharacter),
        ),
      );
    } catch (e) {
      _debugPrint('Error creating clan: $e');
      
      setState(() {
        _errorMessage = 'An error occurred while creating the clan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 초대 코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    
    for (var i = 0; i < 8; i++) {
      buffer.write(chars[rnd % chars.length]);
    }
    
    final code = buffer.toString();
    _debugPrint('Generated invite code: $code');
    return code;
  }
  
  /// 목적 표시 위젯
  Widget _buildPurposeInfo(String title, String purpose) {
    return Tooltip(
      message: purpose,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.question_mark,
                size: 14,
                color: AppTheme.primaryColor,
              ),
            ),
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
        title: const Text('Create New Clan'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 상단 제목
                      const Padding(
                        padding: EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          'Create Your Own Clan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
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
                      
                      // 클랜 이름 입력
                      _buildPurposeInfo(
                        'Clan Name', 
                        'The name of your clan, which represents your identity in the game.'
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Enter the name of your clan',
                                prefixIcon: const Icon(Icons.shield, color: AppTheme.primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                helperText: 'Max 50 characters',
                              ),
                              maxLength: 50,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a clan name';
                                }
                                if (value.length < 3) {
                                  return 'Clan name must be at least 3 characters';
                                }
                                return null;
                              },
                              onChanged: (_) => _generateDescription(),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // 랜덤 이름 생성 버튼
                          IconButton(
                            onPressed: _isGeneratingName ? null : _generateRandomClanName,
                            icon: _isGeneratingName
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.autorenew),
                            tooltip: 'Generate Random Name',
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Questing Goal
                      _buildPurposeInfo(
                        'Questing Goal', 
                        'The primary mission or objective your clan aims to achieve.'
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedQuestingGoal,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.flag, color: AppTheme.primaryColor),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return _questingGoalOptions.map<Widget>((QuestingGoalOption option) {
                            return Text(option.title);
                          }).toList();
                        },
                        items: _questingGoalOptions.map((QuestingGoalOption option) {
                          return DropdownMenuItem<String>(
                            value: option.title,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  option.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQuestingGoal = value!;
                            _generateDescription();
                          });
                        },
                        isExpanded: true,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Vibe Check
                      _buildPurposeInfo(
                        'Vibe Check', 
                        'The overall atmosphere and culture of your clan.'
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedVibeCheck,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.mood, color: AppTheme.primaryColor),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return _vibeCheckOptions.map<Widget>((VibeCheckOption option) {
                            return Text(option.title);
                          }).toList();
                        },
                        items: _vibeCheckOptions.map((VibeCheckOption option) {
                          return DropdownMenuItem<String>(
                            value: option.title,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  option.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVibeCheck = value!;
                            _generateDescription();
                          });
                        },
                        isExpanded: true,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Work Style
                      _buildPurposeInfo(
                        'Work Style', 
                        'How your clan members collaborate and approach challenges.'
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedWorkStyle,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.work, color: AppTheme.primaryColor),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return _workStyleOptions.map<Widget>((WorkStyleOption option) {
                            return Text(option.title);
                          }).toList();
                        },
                        items: _workStyleOptions.map((WorkStyleOption option) {
                          return DropdownMenuItem<String>(
                            value: option.title,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  option.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWorkStyle = value!;
                            _generateDescription();
                          });
                        },
                        isExpanded: true,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Clan Banner
                      _buildPurposeInfo(
                        'Clan Banner', 
                        'A visual symbol that represents your clan identity.'
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedBannerIcon,
                              decoration: InputDecoration(
                                labelText: 'Icon',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _bannerIconOptions.map((String value) {
                                IconData iconData;
                                switch (value) {
                                  case 'shield':
                                    iconData = Icons.shield;
                                    break;
                                  case 'bolt':
                                    iconData = Icons.bolt;
                                    break;
                                  case 'star':
                                    iconData = Icons.star;
                                    break;
                                  case 'crown':
                                    iconData = Icons.king_bed;
                                    break;
                                  case 'fire':
                                    iconData = Icons.local_fire_department;
                                    break;
                                  case 'water':
                                    iconData = Icons.water_drop;
                                    break;
                                  case 'earth':
                                    iconData = Icons.public;
                                    break;
                                  case 'air':
                                    iconData = Icons.air;
                                    break;
                                  default:
                                    iconData = Icons.shield;
                                }
                                
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Icon(iconData, color: _selectedBannerColor),
                                      const SizedBox(width: 8),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBannerIcon = value!;
                                });
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Color Picker Preview
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Select Banner Color'),
                                    content: SingleChildScrollView(
                                      child: Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          _colorOption(Colors.red),
                                          _colorOption(Colors.blue),
                                          _colorOption(Colors.green),
                                          _colorOption(Colors.yellow),
                                          _colorOption(Colors.purple),
                                          _colorOption(Colors.orange),
                                          _colorOption(Colors.teal),
                                          _colorOption(Colors.pink),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _selectedBannerColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Call to Arms
                      _buildPurposeInfo(
                        'Call to Arms', 
                        'A rallying cry or motto that motivates your clan members.'
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCallToArms,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.campaign, color: AppTheme.primaryColor),
                        ),
                        items: _callToArmsOptions.map((CallToArmsOption option) {
                          return DropdownMenuItem<String>(
                            value: option.title,
                            child: Text(option.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCallToArms = value!;
                            _generateDescription();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Generated Description
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPurposeInfo(
                            'Description (Auto-Generated)', 
                            'A summary of your clan based on the information provided.'
                          ),
                          
                          // 편집 버튼
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditingDescription = !_isEditingDescription;
                                if (!_isEditingDescription) {
                                  // 편집 모드에서 빠져나올 때 자동 생성 설명으로 다시 업데이트
                                  _generateDescription();
                                }
                              });
                            },
                            icon: Icon(
                              _isEditingDescription ? Icons.check : Icons.edit,
                              size: 16,
                            ),
                            label: Text(_isEditingDescription ? 'Done' : 'Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // 설명 표시/편집
                      _isEditingDescription
                          ? TextFormField(
                              controller: _descriptionEditController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: 'Enter custom description',
                              ),
                              maxLines: 6,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            )
                          : Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: _isGeneratingDescription
                                  ? const Center(child: CircularProgressIndicator())
                                  : Text(_generatedDescription),
                            ),
                      
                      const SizedBox(height: 32),
                      
                      // 클랜 창설 버튼
                      ElevatedButton(
                        onPressed: _isLoading ? null : _createClan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Clan',
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
                        child: const Text('Cancel'),
                      ),
                      
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  /// 컬러 선택 옵션 위젯
  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBannerColor = color;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedBannerColor == color 
                ? Colors.black 
                : Colors.grey.shade300,
            width: _selectedBannerColor == color ? 2 : 1,
          ),
        ),
      ),
    );
  }
} 