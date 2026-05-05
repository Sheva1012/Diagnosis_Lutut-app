import 'package:flutter/material.dart';

class AdminTheme {
  static const Color bg = Color(0xFFFFF7F0);
  static const Color ink = Color(0xFF3B2A1A);
  static const Color primary = Color(0xFFEE6C4D);
  static const Color primaryDark = Color(0xFFB2432C);
  static const Color primarySoft = Color(0xFFFFE1D6);
  static const Color accent = Color(0xFFF2A65A);
  static const Color danger = Color(0xFFE0524F);
  static const Color stroke = Color(0xFFF1D5C8);
  static const Color rowAlt = Color(0xFFFFFCFA);
  static const Color headerLight = Color(0xFFFFE3D7);
  static const Color headerDark = Color(0xFFFFD8C7);

  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF4EB), Color(0xFFFFFBF7)],
  );

  static const Color blueMuted = Color(0xFFD9E8FF);
  static const Color greenMuted = Color(0xFFE9F6E8);
  static const Color orangeMuted = Color(0xFFFFEFE6);

  // Row colors for role differentiation (pengguna table)
  static const Color adminRowBg = Color(0xFFFFF0E8);       // warm orange tint for Admin
  static const Color masyarakatRowBg = Color(0xFFE8F4FF);   // cool blue tint for Masyarakat
}
