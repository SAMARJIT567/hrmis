// ============================================================
// 📁 lib/shared/widgets/custom_button.dart
// ─────────────────────────────────────────────────────────────
// Reusable button widget with primary, outline, and text types.
// Every style property is customizable via parameters.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

enum ButtonType { primary, outline, text, danger }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  final ButtonType type;
  final double? width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isDisabled;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  final EdgeInsets padding;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.width,
    this.height = AppDimensions.buttonHeightMD,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.borderRadius = 12,
  });

  Color get _bgColor {
    if (isDisabled) return AppColors.border;
    if (backgroundColor != null) return backgroundColor!;
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.danger:
        return AppColors.error;
      default:
        return Colors.transparent;
    }
  }

  Color get _fgColor {
    if (isDisabled) return AppColors.textTertiary;
    if (foregroundColor != null) return foregroundColor!;
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
    }
  }

  Color get _borderColorResolved {
    if (borderColor != null) return borderColor!;
    switch (type) {
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.danger:
        return AppColors.error;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null && !isLoading) ...[
          Icon(prefixIcon, size: 18.sp, color: _fgColor),
          SizedBox(width: 8.w),
        ],
        if (isLoading)
          SizedBox(
            width: 18.w,
            height: 18.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: _fgColor,
            ),
          )
        else
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: fontSize.sp,
              fontWeight: fontWeight,
              color: _fgColor,
            ),
          ),
        if (suffixIcon != null && !isLoading) ...[
          SizedBox(width: 8.w),
          Icon(suffixIcon, size: 18.sp, color: _fgColor),
        ],
      ],
    );

    return Container(
      width: width,
      height: height.h,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(color: _borderColorResolved),
        boxShadow: (type == ButtonType.primary || type == ButtonType.danger) &&
                !isDisabled
            ? [
                BoxShadow(
                  color: _bgColor.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: InkWell(
          onTap: (isLoading || isDisabled) ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: Padding(
            padding: padding,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

// ─── Small Icon Button ────────────────────────────────────────
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final double borderRadius;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: Icon(
            icon,
            size: iconSize.sp,
            color: iconColor ?? AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}