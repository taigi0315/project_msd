import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Super fancy card component for our epic RPG-style app!
/// This reusable card ensures consistent styling across the app
/// while providing multiple customization options.
class AppCard extends StatelessWidget {
  /// Card content widgets
  final Widget child;
  
  /// Card title (optional)
  final String? title;
  
  /// Card subtitle (optional)
  final String? subtitle;
  
  /// Icon to display in header (optional)
  final IconData? icon;
  
  /// Card footer widgets (optional)
  final Widget? footer;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Border color (optional)
  final Color? borderColor;
  
  /// Card elevation
  final double elevation;
  
  /// Tap callback (optional)
  final VoidCallback? onTap;
  
  /// Progress value between 0.0 and 1.0 (optional)
  final double? progress;
  
  /// Progress color (optional)
  final Color? progressColor;
  
  /// Whether to add padding around the content
  final bool contentPadding;
  
  /// Constructor for our epic card
  const AppCard({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.footer,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 4,
    this.onTap,
    this.progress,
    this.progressColor,
    this.contentPadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = backgroundColor ?? AppTheme.cardColor;
    final borderSide = borderColor != null 
        ? BorderSide(color: borderColor!, width: 2)
        : BorderSide.none;
    
    // Create card with appropriate style
    return Card(
      elevation: elevation,
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: borderSide,
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.primaryColor.withOpacity(0.1),
        highlightColor: AppTheme.primaryColor.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card header (if title is provided)
            if (title != null) _buildHeader(),
            
            // Progress indicator (if progress value is provided)
            if (progress != null) _buildProgressIndicator(),
            
            // Card content
            Padding(
              padding: contentPadding
                  ? const EdgeInsets.all(16)
                  : EdgeInsets.zero,
              child: child,
            ),
            
            // Card footer (if provided)
            if (footer != null) _buildFooter(),
          ],
        ),
      ),
    );
  }
  
  /// Build card header with title, subtitle, and icon
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon (if provided)
          if (icon != null) ...[
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              radius: 16,
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                
                // Subtitle (if provided)
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build progress indicator bar
  Widget _buildProgressIndicator() {
    return Container(
      height: 6,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(
          progressColor ?? AppTheme.primaryColor,
        ),
      ),
    );
  }
  
  /// Build card footer
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: footer,
    );
  }
} 