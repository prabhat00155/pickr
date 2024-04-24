import 'package:flutter/material.dart';

import 'constants.dart';

class Rules extends StatelessWidget {

  const Rules({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rules',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Rules'),
          backgroundColor: appBarColour,
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Rules',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'The rules of Pickr are pretty straightforward.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1. Select a category on the home page.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '2. Look at the image and select the option that matches with the image.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '3. Complete the remaining questions to improve your score, progress through the player levels, earn badges and climb up the leaderboard.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const Divider(),
                      const Text(
                        'Scores',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Scores are calculated as a weighted sum of all the questions answered plus some contrubition coming from the time left at the end of the quiz.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'All the questions carry a weight equal to the question number displayed at the top left. So, if you answer question number 1 correctly, you get 1 point, and if you answer question number 10 correctly, you get 10 points added to the score',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'The time left at the end of the quiz gets divided by the square of one more than the number of wrong answers, and then this is added to the final score.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const Divider(),
                      const Text(
                        'Player Levels',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Players progress through the following levels as they gain experience by playing quizzes and attempting more questions.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: levelToImage.entries.map((entry) {
                          final String level = _toPascalCase(entry.key.name);
                          final String imageAsset = entry.value;
                          final String info = levelToInfo.containsKey(entry.key) ? levelToInfo[entry.key]! : '';

                          return GestureDetector(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(imageAsset),
                                  radius: 50,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  level,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                            onTap: () => showInfo(context, info, level),
                          );
                        }).toList(),
                      ),
                      const Divider(),
                      const Text(
                        'Badges',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Players can win the following badges based on their achievements in the game. Badges won by a player can be seen under Dashboard/Account. Badges won by other players can be seen by viewing the player details in the leaderboard.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: badgeToImage.entries.where((entry) =>
                        !entry.key.name.toLowerCase().endsWith('inarow')).map((entry) {
                          final String badge = _toPascalCase(entry.key.name);
                          final String imageAsset = entry.value;
                          final String info = badgeToInfo.containsKey(entry.key) ? badgeToInfo[entry.key]! : '';

                          return GestureDetector(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(imageAsset),
                                  radius: 50,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    badge,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => showInfo(context, info, badge),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toPascalCase(String word) {
    return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '';
  }

  void showInfo(BuildContext context, String info, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              info,
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
}
