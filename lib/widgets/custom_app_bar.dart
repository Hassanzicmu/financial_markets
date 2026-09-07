import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title is Text
          ? Text(
              (title as Text).data!,
              style: AppTypography.titleMd,
            )
          : title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: context.canvas.withValues(alpha: 0.7),
      iconTheme: IconThemeData(color: context.ink),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(color: context.hairline, width: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
