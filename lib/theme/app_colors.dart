import 'package:flutter/material.dart';

/// App-wide color palette with modern HSL/tailored hex styling.
class AppColors {
  // Primary & Accent Colors
  static const Color primary = Color(0xFF6366F1); // Modern Indigo
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Backgrounds - Light Mode
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);

  // Backgrounds - Dark Mode
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCardBorder = Color(0xFF334155);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Category Colors
  static const Color categoryFood = Color(0xFFEF4444); // Red
  static const Color categoryTransport = Color(0xFF3B82F6); // Blue
  static const Color categoryShopping = Color(0xFFEC4899); // Pink
  static const Color categoryBills = Color(0xFF8B5CF6); // Purple
  static const Color categoryEntertainment = Color(0xFFF59E0B); // Amber
  static const Color categoryHealthcare = Color(0xFF10B981); // Teal
  static const Color categoryEducation = Color(0xFF06B6D4); // Cyan
  static const Color categoryOther = Color(0xFF64748B); // Slate

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
