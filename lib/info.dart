import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'constants.dart';
import 'logger.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  InfoState createState() => InfoState();
}

class InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _tile(
          'About Pickr',
          const ImageIcon(AssetImage('assets/images/pickr_logo.png'), size: 30, color: Colors.red),
          context,
          'assets/text/about.txt',
        ),
        const Divider(),
        ListTile(
          title: const Text(
            'Rules',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          leading: Icon(Icons.edit_note_outlined, color: Colors.blue[500]),
          onTap: () {
            logger('click', {'title': 'Rules', 'method': 'build', 'file': 'info'});
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Rules(),
                settings: const RouteSettings(name: 'Rules'),
              ),
            );
          },
        ),
        const Divider(),
        _tile(
          'Privacy Policy',
          Icon(Icons.privacy_tip_outlined, color: Colors.blue[500]),
          context,
          'assets/text/privacy_policy.html',
        ),
        const Divider(),
      ],
    );
  }

  FutureBuilder _tile(title, icon, context, fileName) {
    Future<String> contents = fetchContent(fileName);
    return FutureBuilder(
      future: contents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            leading: icon,
            onTap: () {
              logger('click', {'title': title, 'method': '_tile', 'file': 'info'});
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Contents(title: title, htmlContent: snapshot.data),
                  settings: RouteSettings(name: title),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          logger('exception', {'title': 'Info', 'method': '_tile', 'file': 'info', 'details': snapshot.error.toString()});
          return const Center(child: Text('N/A'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }

  Future<String> fetchContent(fileName) async {
    try {
      return await rootBundle.loadString(fileName);
    } catch(e) {
      logger('exception', {'title': 'Info', 'method': 'fetchContent', 'file': 'info', 'details': e.toString()});
      return 'N/A';
    }
  }
}

class Contents extends StatelessWidget {
  final String? htmlContent;
  final String title;

  const Contents({
    super.key,
    required this.title,
    required this.htmlContent,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(title),
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
                  child: HtmlWidget(
                    htmlContent ?? 'N/A',
                    textStyle: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                        '3. Complete the remaining questions to improve your score, player level, earn badges and climb up the leaderboard.',
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
                        'All the questions carry a weight equal to the question number displayed at the top left. So, if you answer question 1 correctly, you get 1 point, and if you answer question 10 correctly, you get 10 points added to the score',
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
                          final level = _toPascalCase(entry.key.name);
                          final imageAsset = entry.value;

                          return Row(
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
                          final badge = _toPascalCase(entry.key.name);
                          final imageAsset = entry.value;
                          final String info = badgeToInfo.containsKey(entry.key) ? badgeToInfo[entry.key]! : '';

                          return GestureDetector(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(imageAsset),
                                  radius: 50,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  badge,
                                  style: const TextStyle(fontSize: 16.0),
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
