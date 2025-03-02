import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// 앱에서 사용하는 툴팁 위젯
/// 사용자에게 기능 사용 방법을 안내하는 팝업 메시지를 표시합니다.
/// 최초 사용 시에만 표시하거나 항상 표시할 수 있습니다.
class AppTooltip extends StatefulWidget {
  /// 툴팁이 포함할 자식 위젯
  final Widget child;
  
  /// 툴팁 메시지
  final String message;
  
  /// 툴팁 식별자 (최초 사용 확인에 사용)
  final String tooltipId;
  
  /// 툴팁 표시 위치
  final AxisDirection preferredDirection;
  
  /// 툴팁을 항상 표시할지 여부
  final bool alwaysShow;
  
  /// 툴팁 표시 지연 시간
  final Duration showDelay;
  
  const AppTooltip({
    super.key,
    required this.child,
    required this.message,
    required this.tooltipId,
    this.preferredDirection = AxisDirection.down,
    this.alwaysShow = false,
    this.showDelay = const Duration(milliseconds: 500),
  });

  @override
  State<AppTooltip> createState() => _AppTooltipState();
}

class _AppTooltipState extends State<AppTooltip> {
  bool _shouldShow = false;
  bool _isVisible = false;
  final GlobalKey _widgetKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    
    // 툴팁을 보여줄지 결정
    _checkIfShouldShow();
    
    // 지연 시간 후 툴팁 표시
    if (widget.alwaysShow) {
      Future.delayed(widget.showDelay, () {
        if (mounted && _shouldShow) {
          _showTooltip();
        }
      });
    }
  }

  /// 툴팁을 표시할지 여부 확인
  Future<void> _checkIfShouldShow() async {
    if (widget.alwaysShow) {
      setState(() {
        _shouldShow = true;
      });
      return;
    }
    
    // SharedPreferences에서 툴팁 표시 여부 확인
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShown = prefs.getBool('tooltip_${widget.tooltipId}') ?? false;
      
      if (!hasShown) {
        // 툴팁을 표시한 것으로 저장
        await prefs.setBool('tooltip_${widget.tooltipId}', true);
        
        setState(() {
          _shouldShow = true;
        });
      }
    } catch (e) {
      // 오류 발생 시 항상 표시
      setState(() {
        _shouldShow = true;
      });
      debugPrint('툴팁 표시 여부 확인 중 오류 발생: $e');
    }
  }

  /// 툴팁 표시
  void _showTooltip() {
    if (_isVisible || !_shouldShow) return;
    
    // 위젯의 위치 및 크기 가져오기
    final RenderBox? renderBox = _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    // 툴팁 위치 계산
    double top, left;
    
    switch (widget.preferredDirection) {
      case AxisDirection.down:
        top = offset.dy + size.height + 8;
        left = offset.dx + (size.width / 2) - 100;
        break;
      case AxisDirection.up:
        top = offset.dy - 48;
        left = offset.dx + (size.width / 2) - 100;
        break;
      case AxisDirection.right:
        top = offset.dy + (size.height / 2) - 24;
        left = offset.dx + size.width + 8;
        break;
      case AxisDirection.left:
        top = offset.dy + (size.height / 2) - 24;
        left = offset.dx - 208;
        break;
    }
    
    // 오버레이 엔트리 생성
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: top,
        left: left,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '도움말',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _hideTooltip,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // 오버레이에 툴팁 추가
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isVisible = true;
    });
    
    // 5초 후 자동으로 툴팁 숨기기
    Future.delayed(const Duration(seconds: 5), () {
      _hideTooltip();
    });
  }
  
  /// 툴팁 숨기기
  void _hideTooltip() {
    if (!_isVisible) return;
    
    _overlayEntry?.remove();
    _overlayEntry = null;
    
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _widgetKey,
      onTap: () {
        if (widget.alwaysShow && _shouldShow) {
          if (_isVisible) {
            _hideTooltip();
          } else {
            _showTooltip();
          }
        }
      },
      child: widget.child,
    );
  }
}

/// 툴팁 표시 관리자
/// 앱 전체에서 툴팁 표시 여부를 관리합니다.
class TooltipManager {
  static final TooltipManager _instance = TooltipManager._internal();
  
  factory TooltipManager() {
    return _instance;
  }
  
  TooltipManager._internal();
  
  /// 툴팁 활성화 여부
  bool tooltipsEnabled = true;
  
  /// 모든 툴팁 초기화 (다시 표시되도록)
  Future<void> resetAllTooltips() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('tooltip_')).toList();
    
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
} 