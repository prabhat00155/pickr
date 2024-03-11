import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'logger.dart';
import 'player.dart';

class FeedbackForm extends StatefulWidget {
  final Player player;

  const FeedbackForm({super.key, required this.player});

  @override
  FeedbackFormState createState() {
    return FeedbackFormState();
  }
}

class FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  String message = '';
  Player get player => widget.player;

  @override  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> uploadFeedback(contents) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userRef = firestore.collection('feedback').doc(player.playerId);

    try {
      var doc = await userRef.get();
      if (doc.exists) {
        // If document exists, update it by appending new feedback
        await userRef.update({
          'name': player.name,
          'email': player.email,
          'timestamp': FieldValue.serverTimestamp(),
          'feedback': FieldValue.arrayUnion([contents]),
        });
      } else {
        await userRef.set({
          'playerId': player.playerId,
          'name': player.name,
          'email': player.email,
          'timestamp': FieldValue.serverTimestamp(),
          'feedback': [contents],
        }, SetOptions(merge: true));
      }
      setState(() {
        message = 'Feedback sent successfully.';
      });
    } catch(e) {
      logger('exception', {'title': 'feedback', 'method': 'uploadFeedback', 'file': 'user_feedback', 'details': e.toString()});
      setState(() {
        message = 'Error in sending the feedback.';
      });
    }
    showSnackBar(message);
    await Future.delayed(const Duration(seconds: 2));
    if(mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: textController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      uploadFeedback(textController.text);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
