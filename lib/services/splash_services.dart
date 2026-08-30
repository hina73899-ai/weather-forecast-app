import 'package:flutter/material.dart';

import '../views/home_screen.dart';
class SplashServices {

  void isLogin(BuildContext context) {
    Future.delayed(const Duration(seconds: 9), () {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }
}


