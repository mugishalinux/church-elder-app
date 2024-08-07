import 'package:amavunapp/pages/post_page.dart';
import 'package:flutter/material.dart';

import '../common/theme_helper.dart';
import '../service.dart';
import 'attendence.dart';
import 'christian_page.dart';
import 'home_page.dart';

class NavBar extends StatefulWidget {
  final String names;
  const NavBar({Key? key, required this.names}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.names,
              style: const TextStyle(fontSize: 18),
            ),
            accountEmail: const Text(""),
            currentAccountPicture: Align(
              alignment: Alignment.center,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage("assets/userav.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: ThemeHelper
                  .primaryColor, // Set the background color from ThemeHelper
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text("Home"),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              )
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.people_alt),
            title: const Text("Christians"),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ChristianPage()),
                (Route<dynamic> route) => false,
              )
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.note_alt_outlined),
            title: const Text("Post"),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PostPage()),
                (Route<dynamic> route) => false,
              )
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_alt),
            title: const Text("Attendence"),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AttendencePage()),
                (Route<dynamic> route) => false,
              )
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app_outlined),
            title: const Text("Logout"),
            onTap: () async => {await SharedService.logout(context)},
          )
        ],
      ),
    );
  }
}
