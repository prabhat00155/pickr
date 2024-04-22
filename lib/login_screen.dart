import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'constants.dart';
import 'home_screen.dart';
import 'logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Map<String, Function> mapper;
  bool _isSigningIn = false;

  _LoginScreenState() {
    mapper = {
      'Guest': _continueAsGuest,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pickr'),
        backgroundColor: appBarColour,
      ),
      body: Center(
        child: _isSigningIn
          ? const CircularProgressIndicator()
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTile('Continue as Guest', const Icon(Icons.people), 'Guest', context),
            ],
          ),
      ),
    );
  }

  Padding _buildTile(title, imagePath, key, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        leading: key == 'Guest' ? imagePath : Image.asset(imagePath, width: 20, height: 20),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: () async {
          final bool result = await InternetConnection().hasInternetAccess;
          if (!result) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No internet connection available. Please check your network settings.'),
              ),
            );
          } else {
            mapper[key]?.call(context);
          }
        },
        contentPadding: const EdgeInsets.only(left: 20.0),
      ),
    );
  }

  Future<void> _continueAsGuest(BuildContext context) async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          final String message = "Anonymous auth hasn't been enabled for this project: $e";
          logger('exception', {'title': 'LoginScreen', 'method': '_continueAsGuest', 'file': 'login_screen', 'details': message});
          break;
        default:
          logger('exception', {'title': 'LoginScreen', 'method': '_continueAsGuest', 'file': 'login_screen', 'details': e.toString()});
      }
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }
}
