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
  bool _hasInternet = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    bool result = await InternetConnection().hasInternetAccess;
    if (mounted) {
      setState(() {
        _hasInternet = result;
        _loading = false;
      });
    }
    if (_hasInternet) {
      _continueAsGuest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pickr'),
        backgroundColor: appBarColour,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _hasInternet
          ? const Center(child: CircularProgressIndicator())
          : Center(
            child: _buildTile(
              'No internet connection available.\nTap to refresh!',
              const Icon(Icons.refresh_sharp),
              onTap: _checkInternetConnection,
            ),
          ),
    );
  }

  Padding _buildTile(String title, Widget leading, {VoidCallback? onTap}) {
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
        leading: leading,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.only(left: 20.0),
      ),
    );
  }

  Future<void> _continueAsGuest() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (context != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          final String message = "Anonymous auth hasn't been enabled for this project: $e";
          logger('exception', {'title': 'LoginScreen', 'method': '_continueAsGuest', 'file': 'login_screen', 'details': message});
          break;
        default:
          logger('exception', {'title': 'LoginScreen', 'method': '_continueAsGuest', 'file': 'login_screen', 'details': e.toString()});
      }
    } catch(e) {
      logger('exception', {'title': 'LoginScreen', 'method': '_continueAsGuest', 'file': 'login_screen', 'details': e.toString()});
    }
  }
}
