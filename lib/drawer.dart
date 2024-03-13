import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_avatar/random_avatar.dart';

import 'login_screen.dart';
import 'constants.dart';
import 'info.dart';
import 'logger.dart';
import 'player.dart';
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
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                player.photoUrl != null
                  ? CircleAvatar(
                    radius: 40,
                    backgroundImage: CachedNetworkImageProvider(
                      player.photoUrl!,
                    ),
                  )
                  : RandomAvatar(
                    player.avatar,
                    height: 80,
                    width: 80,
                    trBackground: false,
                  ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: Text(
                    player.name ?? player.playerId,
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
                showLeaderboard(context);
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
              leading: const Icon(Icons.logout),
              title: Text(
                'L O G O U T',
                style: drawerTextColor,
              ),
              onTap: () {
                signUserOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void showInfo(context) {
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

  void signUserOut(context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      logger('exception', {'title': 'Drawer', 'method': 'signUserOut', 'file': 'drawer', 'details': e.toString()});
    }
  }

  void showSettings(context) {
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
