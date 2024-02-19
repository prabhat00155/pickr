import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'constants.dart';
import 'login_screen.dart';
import 'player.dart';

class Settings extends StatefulWidget {
  final Player player;
  const Settings({super.key, required this.player});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  String dropdownValue = languages.first;
  Player get player => widget.player;
  final currentUser = FirebaseAuth.instance.currentUser!;
  late Map<String, Function> mapper;

  SettingsState() {
    mapper = {
      'Privacy and Security': details,
      'Link with Google Account': accountLinking,
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> settingsOptions = [
      buildLanguage(context, 'Language'),
      const SizedBox(height: 30),
      buildOption(context, 'Privacy and Security'),
    ];

    if (currentUser.isAnonymous) {
      settingsOptions.add(const SizedBox(height: 30));
      settingsOptions.add(buildOption(context, 'Link with Google Account'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...settingsOptions,
        ],
      ),
    );
  }

  GestureDetector buildOption(BuildContext context, String title) {
    return GestureDetector(
      onTap: () => mapper[title]?.call(context, title),
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
          content: const SingleChildScrollView(
            child: Text(
              'Privacy and Security!',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void accountLinking(BuildContext context, String title) async {
    String response = await linkAccountWithGoogle();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      for (var userInfo in user.providerData) {
        if (userInfo.providerId == 'google.com') {
          player.name = userInfo.displayName;
          player.email = userInfo.email;
          player.photoUrl = userInfo.photoURL;
          break;
        }
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              response,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget buildLanguage(BuildContext context, String title) {
    return Row(
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
        buildDropdown(context),
      ],
    );
  }

  Widget buildDropdown(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: languages.first,
      onSelected: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      dropdownMenuEntries: languages.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }
}
