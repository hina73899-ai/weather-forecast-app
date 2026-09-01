
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';


class AppColors {
  static const Color background = Color(0xFFF7F8FA);
  static const Color darkText = Color(0xFF000000);
  static const Color greyText = Color(0xFF363B64);
  static const Color primaryBlue = Color(0xFF3C6FD1);
  static const Color calendarBg = Color(0xFFEAF1FF);

  // Gradient Colors (Only for Weather Cards)
  static const Color cardGradientStart = Color(0xFF24B0FF);
  static const Color cardGradientEnd = Color(0xFF7CA9FF);

  // Gradient Colors (Only for Drawer)
  static const Color drawerGradientStart = Color(0xFF24B0FF);
  static const Color drawerGradientEnd = Color(0xFF75A7FC);

   static const drawerGradientStarttop = Color(0xFF0A1F44);
   static const drawerGradientEndbottom = Color(0xFF14315C);
}

class AppPaddings {
  // EdgeInset Constants
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets cardContent = EdgeInsets.all(20.0);
  static const EdgeInsets newsContent = EdgeInsets.all(16.0);
  static const EdgeInsets calendarPadding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0);
  static const EdgeInsets drawerPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0);

  // Common SizedBox Heights (Spacing)
  static const SizedBox spaceS = SizedBox(height: 12.0);
  static const SizedBox spaceM = SizedBox(height: 24.0);
  static const SizedBox spaceL = SizedBox(height: 28.0);
}