import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'account.dart';
import 'auth_screen.dart';
import 'player.dart';

var drawerTextColor = TextStyle(
  color: Colors.grey[600],
);
var tilePadding = const EdgeInsets.only(left: 8.0, right: 8, top: 8);

class MyDrawer extends StatelessWidget {
  final Player player;

  const MyDrawer({required this.player});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[300],
      elevation: 0,
      child: Column(
        children: [
          DrawerHeader(
            child: Image.asset('assets/images/pickr_logo.png', width: 100, height: 100),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: Icon(Icons.home),
              title: Text(
                'D A S H B O A R D',
                style: drawerTextColor,
              ),
              onTap: () {
                // Handle tap for Dashboard
                print('Dashboard tapped');
                showAccount(context);
              },
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'S E T T I N G S',
                style: drawerTextColor,
              ),
              onTap: () {
                // Handle tap for Settings
                print('Settings tapped');
              },
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text(
                'A B O U T',
                style: drawerTextColor,
              ),
              onTap: () {
                // Handle tap for About
                print('About tapped');
              },
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                'L O G O U T',
                style: drawerTextColor,
              ),
              onTap: () {
                print('sign out');
                signUserOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void signUserOut(context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully.');
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void showAccount(context) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Account'),
            ),
            body: Account(player: player),
          );
        },
        settings: const RouteSettings(name: 'Account'),
      ),
    );
  }
}
