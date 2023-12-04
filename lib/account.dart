import 'dart:io';

import 'package:country_flags/country_flags.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import 'constants.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {
  String userId = '';
  String defaultAvatar = '100';
  String defaultCountryCode = 'in';

  Future<void> _changeAvatar() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Avatar'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: List.generate(
                60,
                (index) => GestureDetector(
                  onTap: () {
                    // Update the defaultAvatar to the selected avatar ID
                    setState(() {
                      defaultAvatar = '$index';
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
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: List.generate(
                countryCodes.length,
                (index) => GestureDetector(
                  onTap: () {
                    // Update the defaultCountryCode to the selected country code
                    setState(() {
                      defaultCountryCode = countryCodes[index];
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => _changeAvatar(),
            child: RandomAvatar(
              defaultAvatar,
              height: 80,
              width: 80,
              trBackground: false,
            ),
          ),
          Text(userId),
          GestureDetector(
            onTap: () => _changeFlag(),
            child: CountryFlag.fromCountryCode(
              defaultCountryCode,
              height: 36,
              width: 50,
              borderRadius: 8,
            ),
          ),
          const Text('Badges'),
          const Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/badges/initiate.png'),
                radius: 50,
              ),
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/badges/master.png'),
                radius: 50,
              ),
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/badges/first.png'),
                radius: 50,
                backgroundColor: Colors.white,
              ),
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/badges/inspiration.png'),
                radius: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void signInAnon() async {
    String uniqueId = await getDeviceUniqueId();
    setState(() {
      userId = uniqueId;
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
