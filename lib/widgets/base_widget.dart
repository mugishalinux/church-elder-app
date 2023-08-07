import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottom_nav.dart';

class BaseScreen extends StatelessWidget {
  final BottomNav bottomNav;
  final Widget child;

  const BaseScreen({super.key, required this.bottomNav, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: child,
      bottomNavigationBar: bottomNav,
    );
  }
}
