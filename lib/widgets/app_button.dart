import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/game_effects_service.dart';
import '../models/game_sound.dart';

/// Super awesome button for our epic app!
/// This reusable button component ensures consistent button styling across the app
/// while providing multiple customization options.
class AppButton extends StatelessWidget {
  /// The text to display on the button
  final String label;
  
  /// Icon to display before the text (optional)
  final IconData? icon;
  
  /// What happens when button is pressed
  final VoidCallback? onPressed;
  
  /// If true, shows a loading spinner instead of text
  final bool isLoading;
  
  /// Button style variant: 'primary', 'secondary', 'success', 'danger', 'outline'
  final String variant;
  
  /// Size variant: 'large', 'medium', 'small'
  final String size;
  
  /// Expand button to full width
  final bool isFullWidth;

  /// Constructor for our epic button
  const AppButton({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.variant = 'primary',
    this.size = 'medium',
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button properties based on variant and size
    final Color backgroundColor = _getBackgroundColor();
    final Color textColor = _getTextColor();
    final double horizontalPadding = _getHorizontalPadding();
    final double verticalPadding = _getVerticalPadding();
    final double fontSize = _getFontSize();
    final double elevation = variant == 'outline' ? 0 : 4;
    final BorderSide borderSide = _getBorderSide();
    
    // Create button child (text or loading indicator)
    Widget buttonChild = _createButtonChild(textColor, fontSize);
    
    // Create button with appropriate style
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          if (onPressed != null) {
            // 버튼 클릭 사운드 재생 (낮은 볼륨)
            final gameEffects = GameEffectsService();
            
            // 볼륨 조절 메서드를 만들어 사용합니다
            gameEffects.setVolume(0.3);
            gameEffects.playSound(GameSound.buttonClick);
            gameEffects.setVolume(1.0);
            
            onPressed!();
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: backgroundColor,
          disabledForegroundColor: Colors.grey.shade300,
          disabledBackgroundColor: Colors.grey.shade100,
          elevation: elevation,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderSide,
          ),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: buttonChild,
      ),
    );
  }
  
  /// Create the button content (icon + text or loading spinner)
  Widget _createButtonChild(Color textColor, double fontSize) {
    if (isLoading) {
      return Container(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: fontSize + 4),
          SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    
    return Text(label);
  }
  
  /// Get background color based on variant
  Color _getBackgroundColor() {
    switch (variant) {
      case 'primary':
        return AppTheme.primaryColor;
      case 'secondary':
        return AppTheme.secondaryColor;
      case 'success':
        return AppTheme.successColor;
      case 'danger':
        return AppTheme.errorColor;
      case 'outline':
        return Colors.transparent;
      default:
        return AppTheme.primaryColor;
    }
  }
  
  /// Get text color based on variant
  Color _getTextColor() {
    switch (variant) {
      case 'primary':
      case 'success':
      case 'danger':
        return Colors.white;
      case 'secondary':
        return AppTheme.textColor;
      case 'outline':
        return AppTheme.primaryColor;
      default:
        return Colors.white;
    }
  }
  
  /// Get border side based on variant
  BorderSide _getBorderSide() {
    if (variant == 'outline') {
      return BorderSide(color: AppTheme.primaryColor, width: 2);
    }
    return BorderSide.none;
  }
  
  /// Get horizontal padding based on size
  double _getHorizontalPadding() {
    switch (size) {
      case 'large':
        return 32;
      case 'medium':
        return 24;
      case 'small':
        return 16;
      default:
        return 24;
    }
  }
  
  /// Get vertical padding based on size
  double _getVerticalPadding() {
    switch (size) {
      case 'large':
        return 16;
      case 'medium':
        return 12;
      case 'small':
        return 8;
      default:
        return 12;
    }
  }
  
  /// Get font size based on size
  double _getFontSize() {
    switch (size) {
      case 'large':
        return 18;
      case 'medium':
        return 16;
      case 'small':
        return 14;
      default:
        return 16;
    }
  }
} 