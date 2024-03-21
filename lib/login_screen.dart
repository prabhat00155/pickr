import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        onTap: () => mapper[key]?.call(context),
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

Future<String> linkAccountWithGoogle() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Link the anonymous account with the Google account
    await user!.linkWithCredential(credential);

    // User linked successfully
    return 'Account linked successfully with Google.';
  } catch (e) {
    // Handle linking error
    if (e.toString().contains('[')) {
      return 'Error linking account with Google: $e'.replaceAll(RegExp(r'\[.*?\]'), '');
    }
    return 'Error linking account with Google.';
  }
}
