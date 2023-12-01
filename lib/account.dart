import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {
  String userId = '';

  @override
  Widget build(BuildContext context) {
    signInAnon();
    return Text('$userId');
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
