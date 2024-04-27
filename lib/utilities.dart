import 'dart:math';
import 'package:flutter/material.dart';

import 'account.dart';
import 'constants.dart';
import 'leaderboard.dart';
import 'logger.dart';
import 'player.dart';

Color fetchColour(int score) {
  if (score > 500) {
    return Colors.lightBlue[200]!;
  } else if (score > 400) {
    return Colors.cyan[200]!;
  } else if (score > 300) {
    return Colors.teal[200]!;
  } else if (score > 200) {
    return Colors.green[200]!;
  } else if (score > 100) {
    return Colors.lightGreen[200]!;
  } else if (score > 50) {
    return Colors.lime[200]!;
  } else if (score > 25) {
    return Colors.yellow[200]!;
  } else if (score > 10) {
    return Colors.amber[200]!;
  } else {
    return Colors.orange[200]!;
  }
}

String fetchRandom([int max = 101]) {
  return Random().nextInt(max).toString();
}

void showLeaderboard(BuildContext context, Player? currentPlayer) {
  logger('screen_view', {'firebase_screen': 'Leaderboard', 'firebase_screen_class': 'Leaderboard', 'file': 'utilities'});
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        if (currentPlayer == null) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Leaderboard'),
              backgroundColor: appBarColour,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Leaderboard'),
            backgroundColor: appBarColour,
          ),
          body: Leaderboard(player: currentPlayer),
        );
      },
      settings: const RouteSettings(name: 'Leaderboard'),
    ),
  );
}

void showAccount(BuildContext context, Player? currentPlayer) {
  bool updated = false;

  void updateAccount(bool isUpdated) {
    updated = isUpdated;
  }

  logger('screen_view', {'firebase_screen': 'Account', 'firebase_screen_class': 'Account', 'file': 'utilities'});
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        if (currentPlayer == null) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Account'),
              backgroundColor: appBarColour,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) {
            if (updated) {
              currentPlayer.updateScoreInFirebase();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Account'),
              backgroundColor: appBarColour,
            ),
            body: Account(player: currentPlayer, onUpdate: updateAccount),
          ),
        );
      },
      settings: const RouteSettings(name: 'Account'),
    ),
  );
}
