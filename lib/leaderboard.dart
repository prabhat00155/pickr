import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_avatar/random_avatar.dart';
import 'player.dart';

Future<List<Player>> getLeaderboard() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query the top users
  QuerySnapshot result = await firestore
      .collection('users')
      .orderBy('score', descending: true)
      .limit(10) // Adjust as needed
      .get();

  // Convert the result to a list of User objects
  return result.docs.map((doc) => Player.fromFirestore(doc)).toList();
}

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
         child: FutureBuilder<List<Player>>(
          future: getLeaderboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No leaderboard data available');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Player player = snapshot.data![index];
                  return _buildTile(context, player, index+1);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Padding _buildTile(context, player, rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListTile(
        title: Text(
          player.name ?? player.playerId,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'Score: ${player.score}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        leading: player.photoUrl == null ?
          RandomAvatar(player.avatar, height: 20, width: 20, trBackground: false) :
          Image.asset(player.photoUrl, width: 20, height: 20),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: () => playerInfo(context, player),
        trailing: Text(
          'Rank: $rank',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
      ),
    );
  }

  void playerInfo(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(player.name ?? player.playerId),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Score: ${player.score}'),
                // Add more player details as needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
