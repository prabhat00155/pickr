import 'dart:io';

import 'package:country_flags/country_flags.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import 'constants.dart';
import 'player.dart';

class Account extends StatefulWidget {
  final Player player;
  const Account({super.key, required this.player});

  @override
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {
  Player get player => widget.player;

  Future<void> _changeAvatar() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Avatar'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(
                60,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      player.avatar = '$index';
                    });
                    Navigator.of(context).pop();
                  },
                  child: RandomAvatar(
                    '$index',
                    height: 50,
                    width: 50,
                    trBackground: false,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeFlag() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Flag'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(
                countryCodes.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      player.countryCode = countryCodes[index];
                    });
                    Navigator.of(context).pop();
                  },
                  child: CountryFlag.fromCountryCode(
                    countryCodes[index],
                    height: 32,
                    width: 46,
                    borderRadius: 8,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    signInAnon();
    int score = player.getScore();
    int categoryScores = player.getCategoryScores('Animals');
    int categoryTotalCorrect = player.getCategoryTotalCorrect('Animals');
    int attempts = player.getAttempts('Animals');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _changeAvatar(),
            child: RandomAvatar(
              player.avatar,
              height: 80,
              width: 80,
              trBackground: false,
            ),
          ),
          Text(player.playerId),
          Text(player.name ?? ''),
          Text('$score'),
          Text('$categoryScores'),
          Text('$categoryTotalCorrect'),
          Text('$attempts'),
          GestureDetector(
            onTap: () => _changeFlag(),
            child: CountryFlag.fromCountryCode(
              player.countryCode,
              height: 36,
              width: 50,
              borderRadius: 8,
            ),
          ),
          const Text('Badges'),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(levelToImage[player.level]!),
                radius: 50,
              ),
              ...(player.badges.map((badge) =>
                CircleAvatar(
                  backgroundImage: AssetImage(badgeToImage[badge]!),
                  radius: 50,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  void signInAnon() async {
    String uniqueId = await getDeviceUniqueId();
    setState(() {
      player.playerId = uniqueId;
    });
  }

  Future<String> getDeviceUniqueId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return 'Unknown'; // For other platforms or errors
  }

}
