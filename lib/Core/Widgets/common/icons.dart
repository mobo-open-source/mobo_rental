import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/Core/utils/constants/colors.dart';

class ErrorIcon extends StatelessWidget {
  final Color iconColor;
  const ErrorIcon({super.key, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.error_outline_outlined, color: iconColor);
  }
}

Widget appbar(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InkWell(
    onTap: () {
      Navigator.pop(context);
    },
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: HugeIcon(
        size: 8,
        icon: HugeIcons.strokeRoundedArrowLeft01,
        color: isDark ? Colors.white : Colors.black,
      ),
    ),
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final Color? backgroundColor;
  List<Widget>? actions;

  CustomAppBar({
    required this.title,
    this.leading,
    this.backgroundColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor:
          backgroundColor ??
          (isDark ? Colors.grey[900] : Theme.of(context).colorScheme.secondary),
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: leading ?? appbar(context),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
