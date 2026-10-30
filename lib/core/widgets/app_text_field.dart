import 'package:flutter/material.dart';

import '../../presentation/widgets/glass/openflix_morph_icon.dart';
import '../../services/theme_service.dart';
import '../../theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final int maxLines;
  final double? borderRadius;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.maxLines = 1,
    this.borderRadius,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isBlue = ThemeService.instance.isWindowsBlue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: isBlue ? const Color(0xFFE2F1FF) : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          autofocus: widget.autofocus,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: ThemeService.instance.primaryColor,
          cursorHeight: 18,
          cursorRadius: Radius.circular(1),
          style: TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: isBlue ? const Color(0xFFB8D4E8) : AppColors.textMuted,
              fontSize: 15,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: isBlue
                        ? const Color(0xFFB8D4E8)
                        : AppColors.textMuted,
                    size: 20,
                  )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: OpenFlixMorphIcon.snappy(
                      icon: _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: isBlue
                          ? const Color(0xFFB8D4E8)
                          : AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? (isBlue ? 20 : 16)),
              borderSide: BorderSide(
                color: isBlue ? const Color(0x4D5AD2F4) : Colors.white12,
                width: 1.0,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? (isBlue ? 20 : 16)),
              borderSide: BorderSide(
                color: isBlue ? const Color(0x4D5AD2F4) : Colors.white12,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? (isBlue ? 20 : 16)),
              borderSide: BorderSide(
                color: isBlue
                    ? const Color(0xFF66C7F4)
                    : ThemeService.instance.primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? (isBlue ? 20 : 16)),
              borderSide: const BorderSide(color: AppColors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? (isBlue ? 20 : 16)),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
