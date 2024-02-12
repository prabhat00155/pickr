import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_avatar/random_avatar.dart';

import 'constants.dart';
import 'player.dart';

Future<List<Player>> getLeaderboard() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query the top users
  QuerySnapshot result = await firestore
      .collection(documentName)
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
          'Score: ${player.score}     Highest Score: ${player.highestScore}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        leading: RandomAvatar(player.avatar, height: 20, width: 20, trBackground: false),
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
    int score = player.getScore();
    int highestScore = player.getHighestScore();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    player.photoUrl == null
                    ? RandomAvatar(player.avatar, height: 50, width: 50, trBackground: false)
                    : CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(
                        player.photoUrl!,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      flex: 1,
                      child: Text(
                        player.name ?? player.playerId,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CountryFlag.fromCountryCode(
                      player.countryCode,
                      height: 36,
                      width: 50,
                      borderRadius: 8,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Total Score: $score',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Highest Score: $highestScore',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                const Divider(),
                const Center(
                  child: Text(
                    'Badges',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  )
                ),
                const Divider(),
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
                const Divider(),
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
