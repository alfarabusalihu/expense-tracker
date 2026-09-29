import 'package:flutter/material.dart';

/// Reusable AppBar with a vibrant, visible radiant gradient background.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: false,
      actions: actions,
      bottom: bottom,
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent, // Required for flexibleSpace gradient visibility
      surfaceTintColor: Colors.transparent, // Required in M3 to prevent overlay tinting
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4F46E5), // Deep Indigo
              Color(0xFF7C3AED), // Vibrant Purple
              Color(0xFF2563EB), // Electric Blue
              Color(0xFF10B981), // Emerald Accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
