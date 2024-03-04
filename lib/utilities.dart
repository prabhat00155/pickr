import 'package:flutter/material.dart';

import 'constants.dart';
import 'leaderboard.dart';

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

void showLeaderboard(context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Leaderboard'),
            backgroundColor: appBarColour,
          ),
          body: const Leaderboard(),
        );
      },
      settings: const RouteSettings(name: 'Info'),
    ),
  );
}
