import 'package:amavunapp/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedService {
  static Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Remove data for the 'counter' key.
      await prefs.remove('token');
      await prefs.remove("id");
      await prefs.remove("names");
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }
}
