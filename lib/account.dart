import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:random_avatar/random_avatar.dart';

import 'constants.dart';
import 'player.dart';

class Account extends StatefulWidget {
  final Player player;
  const Account({super.key, required this.player});

  @override
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> {
  Player get player => widget.player;

  Future<void> _changeAvatar() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Avatar'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(
                60,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      player.avatar = '$index';
                    });
                    Navigator.of(context).pop();
                  },
                  child: RandomAvatar(
                    '$index',
                    height: 50,
                    width: 50,
                    trBackground: false,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeFlag() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Flag'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(
                countryCodes.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      player.countryCode = countryCodes[index];
                    });
                    Navigator.of(context).pop();
                  },
                  child: CountryFlag.fromCountryCode(
                    countryCodes[index],
                    height: 32,
                    width: 46,
                    borderRadius: 8,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget accuracyPieChart() {
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
          Color colour = score >= 50 ? Colors.green : Colors.red;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colour,
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

  @override
  Widget build(BuildContext context) {
    int score = player.getScore();
    int highestScore = player.getHighestScore();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _changeAvatar(),
                  child: RandomAvatar(
                    player.avatar,
                    height: 80,
                    width: 80,
                    trBackground: false,
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
                GestureDetector(
                  onTap: () => _changeFlag(),
                  child: CountryFlag.fromCountryCode(
                    player.countryCode,
                    height: 36,
                    width: 50,
                    borderRadius: 8,
                  ),
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
            accuracyPieChart(),
            const Divider(),
            const Center(
              child: Text(
                'Highest Scores',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              )
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
              )
            ),
            const Divider(),
            displayScores(player.perCategoryScores),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
