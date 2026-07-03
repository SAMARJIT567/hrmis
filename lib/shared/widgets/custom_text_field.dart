// ============================================================
// 📁 lib/shared/widgets/custom_text_field.dart
// ─────────────────────────────────────────────────────────────
// Professional reusable text field widget.
// All style params are exposed for individual customization.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? labelColor;
  final double borderRadius;
  final double fontSize;
  final EdgeInsets contentPadding;
  final bool showLabel;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixWidget,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.fillColor,
    this.borderColor,
    this.focusBorderColor,
    this.textColor,
    this.hintColor,
    this.labelColor,
    this.borderRadius = 12,
    this.fontSize = 14,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.showLabel = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscure() => setState(() => _obscureText = !_obscureText);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: widget.labelColor ?? AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.fillColor ?? AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
            border: Border.all(
              color: widget.borderColor ?? AppColors.border,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText,
            readOnly: widget.readOnly,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            style: GoogleFonts.poppins(
              fontSize: widget.fontSize.sp,
              fontWeight: FontWeight.w400,
              color: widget.textColor ?? AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint ?? widget.label,
              hintStyle: GoogleFonts.poppins(
                fontSize: (widget.fontSize - 1).sp,
                color: widget.hintColor ?? AppColors.textTertiary,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius.r),
                borderSide: BorderSide(
                  color: widget.focusBorderColor ?? AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: widget.contentPadding,
              counterText: '',
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20.sp,
                      color: AppColors.textTertiary,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? GestureDetector(
                      onTap: _toggleObscure,
                      child: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20.sp,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : widget.suffixWidget,
            ),
          ),
        ),
      ],
    );
  }
}