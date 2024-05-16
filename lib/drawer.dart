import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import 'constants.dart';
import 'info.dart';
import 'logger.dart';
import 'player.dart';
import 'rules.dart';
import 'settings.dart';
import 'utilities.dart';

var drawerTextColor = TextStyle(
  color: Colors.grey[600],
);
var tilePadding = const EdgeInsets.only(left: 8.0, right: 8, top: 8);

class MyDrawer extends StatelessWidget {
  final Player player;

  const MyDrawer({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[300],
      elevation: 0,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: [
                  RandomAvatar(
                    player.avatar,
                    height: 80,
                    width: 80,
                    trBackground: false,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: Text(
                      player.name != null && player.name!.isNotEmpty ? player.name! : fallbackUserName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ListTile(
                leading: const Icon(Icons.home),
                title: Text(
                  'D A S H B O A R D',
                  style: drawerTextColor,
                ),
                onTap: () {
                  // Handle tap for Dashboard
                  Navigator.pop(context);
                  showAccount(context, player);
                },
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ListTile(
                leading: const Icon(Icons.leaderboard),
                title: Text(
                  'L E A D E R B O A R D',
                  style: drawerTextColor,
                ),
                onTap: () {
                  // Handle tap for Leaderboard
                  Navigator.pop(context);
                  showLeaderboard(context, player);
                },
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: Text(
                  'S E T T I N G S',
                  style: drawerTextColor,
                ),
                onTap: () {
                  // Handle tap for Settings
                  showSettings(context);
                },
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ListTile(
                leading: const Icon(Icons.info),
                title: Text(
                  'A B O U T',
                  style: drawerTextColor,
                ),
                onTap: () {
                  // Handle tap for About
                  showInfo(context);
                },
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: Text(
                  'R U L E S',
                  style: drawerTextColor,
                ),
                onTap: () {
                  // Handle tap for Rules
                  logger('screen_view', {'firebase_screen': 'Rules', 'firebase_screen_class': 'Rules', 'file': 'drawer'});
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Rules(),
                      settings: const RouteSettings(name: 'Rules'),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: tilePadding,
              child: ListTile(
                leading: const Icon(Icons.feedback),
                title: Text(
                  'F E E D B A C K',
                  style: drawerTextColor,
                ),
                onTap: () {
                  // Handle tap for Feedback
                  Navigator.pop(context);
                  showFeedback(context, player);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showInfo(context) {
    logger('screen_view', {'firebase_screen': 'Info', 'firebase_screen_class': 'Info', 'file': 'drawer'});
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Info'),
              backgroundColor: appBarColour,
            ),
            body: const Info(),
          );
        },
        settings: const RouteSettings(name: 'Info'),
      ),
    );
  }

  void showSettings(context) {
    logger('screen_view', {'firebase_screen': 'Settings', 'firebase_screen_class': 'Settings', 'file': 'drawer'});
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Settings'),
              backgroundColor: appBarColour,
            ),
            body: Settings(player: player),
          );
        },
        settings: const RouteSettings(name: 'Settings'),
      ),
    );
  }
}
