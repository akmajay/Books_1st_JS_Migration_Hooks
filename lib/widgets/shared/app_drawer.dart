import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('JAYGANGA', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(title: const Text('Profile'), onTap: () {}),
          ListTile(title: const Text('My Listings'), onTap: () {}),
          ListTile(title: const Text('Settings'), onTap: () {}),
        ],
      ),
    );
  }
}
