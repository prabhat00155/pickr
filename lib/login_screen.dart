import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      'Google': _signInWithGoogle,
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
              _buildTile('Sign in with Google', 'assets/images/login/google.png', 'Google', context),
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
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

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ));
    } catch (error) {
      logger('exception', {'title': 'LoginScreen', 'method': '_signInWithGoogle', 'file': 'login_screen', 'details': error.toString()});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Info'),
            content: const SingleChildScrollView(
              child: Text(
                'We cannot log you in using Google Account at the moment. Please use the "Continue as Guest" option.',
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
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
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
