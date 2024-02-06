import 'package:flutter/material.dart';

import 'player.dart';

class Settings extends StatefulWidget {
  final Player player;
  const Settings({super.key, required this.player});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  Player get player => widget.player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildOption(context, 'Language'),
          const SizedBox(height: 20),
          buildOption(context, 'Privacy and Security'),
        ],
      ),
    );
  }

  GestureDetector buildOption(BuildContext context, String title) {
    return GestureDetector(
      onTap: () => details(context, title),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ],
      ),
    );
  }

  void details(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            children: [
              Text('English'),
              Text('Hindi'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
