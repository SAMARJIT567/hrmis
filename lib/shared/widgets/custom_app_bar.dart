// ============================================================
// 📁 lib/shared/widgets/custom_app_bar.dart
// ─────────────────────────────────────────────────────────────
// Professional reusable AppBar widget.
// Supports title, subtitle, back button, and action buttons.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ─── Parameters ───────────────────────────────────────────
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool centerTitle;

  // ─── Style overrides ──────────────────────────────────────
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? backIconColor;
  final double elevation;
  final double titleFontSize;
  final bool showDivider;
  final Widget? leading;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions,
    this.onBackPressed,
    this.centerTitle = false,
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.backIconColor,
    this.elevation = 0,
    this.titleFontSize = 17,
    this.showDivider = false,
    this.leading,
    this.height = AppDimensions.appBarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              )
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: elevation * 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBack)
              Container(
                width: 38.w,
                height: 38.h,
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16.sp,
                      color: backIconColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
              )
            else if (leading != null)
              leading!,

            Expanded(
              child: centerTitle
                  ? Center(child: _buildTitleColumn())
                  : _buildTitleColumn(),
            ),

            if (actions != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
          ],
        ),
      ),
    );
  }

  // ─── Title + Subtitle column ──────────────────────────────
  Widget _buildTitleColumn() {
    return Column(
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: titleFontSize.sp,
            fontWeight: FontWeight.w600,
            color: titleColor ?? AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          SizedBox(height: 1.h),
          Text(
            subtitle!,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: subtitleColor ?? AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// ─── Gradient Header (used on Dashboard / Login) ──────────────
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;

  final LinearGradient? gradient;
  final EdgeInsets padding;
  final double minHeight;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.gradient,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
    this.minHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight.h),
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (bottom != null) ...[
              SizedBox(height: 16.h),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }
}