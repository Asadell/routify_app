import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6B4CE6);
  static const Color primaryLight = Color(0xFF8B6FF0);
  static const Color primaryDark = Color(0xFF5039B8);

  // Secondary Colors
  static const Color secondary = Color(0xFF20C997);
  static const Color secondaryLight = Color(0xFF4DD4AC);
  static const Color secondaryDark = Color(0xFF1BA87D);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Icon Colors
  static const Color iconPrimary = Color(0xFF475569);
  static const Color iconSecondary = Color(0xFF94A3B8);

  // Workout Status Colors
  static const Color workoutCompleted = Color(0xFF10B981);
  static const Color workoutPartial = Color(0xFFEF4444);
  static const Color workoutScheduled = Color(0xFF3B82F6);
  static const Color workoutNone = Color(0xFF94A3B8);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}