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
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pickr'),
        backgroundColor: appBarColour,
      ),
      body: _isSigningIn
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ImageIcon(AssetImage('assets/images/pickr_logo.png'), size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'W E L C O M E',
                     style: TextStyle(fontSize: 24),
                   ),
                  const SizedBox(height: 20),
                  const Text(
                    'T O',
                     style: TextStyle(fontSize: 24),
                   ),
                  const SizedBox(height: 20),
                  const Text(
                    'P I C K R',
                     style: TextStyle(fontSize: 24),
                   ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text(
                      'Please select a category on the next page to start playing.',
                       style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTile('C O N T I N U E', const Icon(Icons.arrow_forward_ios_sharp), context),
                ],
              ),
            ),
          ),
    );
  }

  Padding _buildTile(title, icon, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        trailing: icon,
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
            _continueAsGuest(context);
          }
        },
        contentPadding: const EdgeInsets.only(left: 20.0),
        tileColor: Colors.green.withOpacity(0.5),
      ),
    );
  }

  Future<void> _continueAsGuest(BuildContext context) async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (context.mounted) {
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
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }
}
