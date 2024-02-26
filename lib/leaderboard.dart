import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:random_avatar/random_avatar.dart';

import 'constants.dart';
import 'player.dart';
import 'utilities.dart';

Future<List<Player>> getLeaderboard() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query the top users
  QuerySnapshot result = await firestore
      .collection(documentName)
      .orderBy('score', descending: true)
      .limit(50)
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
              return const Text('Error loading leaderboard at this time.');
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
        onTap: () => playerInfo(context, player, rank),
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

  void playerInfo(BuildContext context, Player player, int rank) {
    int score = player.getScore();
    int highestScore = player.getHighestScore();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
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
                    'Rank: $rank',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
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
                    ),
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
                  const Center(
                    child: Text(
                      'Accuracy',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    )
                  ),
                  const Divider(),
                  accuracyPieChart(context, player),
                  const Divider(),
                  const Center(
                    child: Text(
                      'Highest Scores',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  displayScores(player.perCategoryHighestScore),
                  const Divider(),
                  const Center(
                    child: Text(
                      'Total Scores',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Divider(),
                  displayScores(player.perCategoryScores),
                  const Divider(),
                ],
              ),
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

  Widget accuracyPieChart(BuildContext context, Player player) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          String categoryName = categories[index].name;
          String accuracyText;
          int correct = player.perCategoryTotalCorrect[categoryName] ?? 0;
          int attempts = player.perCategoryAttempts[categoryName] ?? 0;
          double greenPercentage;
          double redPercentage;

          if (attempts == 0) {
            accuracyText = 'N/A';
            greenPercentage = 0;
            redPercentage = 0;
          } else {
            double accuracy = 100.0 * correct / attempts;
            greenPercentage = accuracy;
            redPercentage = 100 - greenPercentage;
            accuracyText = '${accuracy.toStringAsFixed(0)}%';
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                PieChart(
                  dataMap: {
                    'Green': greenPercentage,
                    'Red': redPercentage,
                  },
                  colorList: const [
                    Colors.green,
                    Colors.red,
                  ],
                  chartType: ChartType.ring,
                  chartRadius: MediaQuery.of(context).size.width / 7,
                  centerText: accuracyText,
                  legendOptions: const LegendOptions(
                    showLegends: false,
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValueBackground: false,
                    showChartValues: false,
                  ),
                ),
                const SizedBox(height: 10),
                Text(categoryName),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget displayScores(scores) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          String categoryName = categories[index].name;
          int score = scores[categoryName];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fetchColour(score),
                  ),
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(categoryName),
              ],
            ),
          );
        }),
      ),
    );
  }
}
