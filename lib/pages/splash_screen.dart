import 'dart:async';

import 'package:amavunapp/common/theme_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../components/square_tile.dart';
import '../models/login_response.dart';
import 'home_page.dart';
import 'login_page.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), navigateToMain);
  }

  Future<void> navigateToMain() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final String? token = preferences.getString('token');
      if (token == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {}
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        // Center the circular loader both vertically and horizontally
        child: Container(
          width: 50, // Adjust the width to make the loader smaller
          height: 50, // Adjust the height to make the loader smaller
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ThemeHelper.primaryColor),
          ),
        ),
      ),
    );
  }
}
