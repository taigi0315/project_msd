import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Super cool text input field for our epic app!
/// This reusable component ensures consistent input styling 
/// while providing multiple customization options.
class AppInput extends StatefulWidget {
  /// Placeholder text when field is empty
  final String hintText;
  
  /// Label text above the input field
  final String? labelText;
  
  /// Helper text below the input field
  final String? helperText;
  
  /// Error message to display (if any)
  final String? errorText;
  
  /// Icon to display before the input
  final IconData? prefixIcon;
  
  /// Icon to display after the input
  final IconData? suffixIcon;
  
  /// Input controller
  final TextEditingController? controller;
  
  /// Text input type (email, number, etc)
  final TextInputType keyboardType;
  
  /// Called when text changes
  final Function(String)? onChanged;
  
  /// Called when field is submitted
  final Function(String)? onSubmitted;
  
  /// Whether to obscure text (for passwords)
  final bool obscureText;
  
  /// Max lines in the input field
  final int? maxLines;
  
  /// Min lines in the input field
  final int? minLines;
  
  /// Input text validators
  final List<TextInputFormatter>? inputFormatters;
  
  /// Whether the field is required
  final bool isRequired;
  
  /// Whether to autocorrect text
  final bool autocorrect;
  
  /// Whether to autofocus this input
  final bool autofocus;
  
  /// Whether field is enabled
  final bool enabled;
  
  /// Constructor for our epic input field
  const AppInput({
    Key? key,
    required this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.isRequired = false,
    this.autocorrect = true,
    this.autofocus = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  _AppInputState createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _obscureText = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      // Update UI when focus changes (if needed)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        if (widget.labelText != null) ...[
          Row(
            children: [
              Text(
                widget.labelText!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        
        // Input field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.maxLines == 1
              ? TextInputAction.next
              : TextInputAction.newline,
          obscureText: _obscureText,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          autocorrect: widget.autocorrect,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            filled: true,
            fillColor: AppTheme.cardColor,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _focusNode.hasFocus
                        ? AppTheme.primaryColor
                        : Colors.grey.shade600,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
          ),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
        ),
        
        // Helper text
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.helperText!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build the suffix icon (password toggle or custom icon)
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey.shade600,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: Colors.grey.shade600,
      );
    }
    return null;
  }
} 