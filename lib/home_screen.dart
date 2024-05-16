import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import 'advertisement.dart';
import 'constants.dart';
import 'drawer.dart';
import 'logger.dart';
import 'player.dart';
import 'quiz_timed.dart';
import 'utilities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _adIndex = 7;
  Player? currentPlayer;

  Future<void> initialisePlayerData() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final playerId = currentUser.uid;

    try {
      final player = await getPlayerData(playerId);
      if (player != null && mounted) {
        setState(() {
          currentPlayer = player;
        });
      } else if (mounted) {
        final String country = getCountry();
        final String avatarIndex = fetchRandom();
        final String displayName = currentUser.displayName ?? WordPair.random().asPascalCase;

        setState(() {
          currentPlayer = Player(
            currentUser.uid,
            name: displayName,
            email: currentUser.email,
            photoUrl: currentUser.photoURL,
            avatar: avatarIndex,
            countryCode: country,
            badges: {},
            perCategoryHighestScore: Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0),
            perCategoryTotalCorrect: Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0),
            perCategoryScores: Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0),
            perCategoryAttempts: Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0),
          );
        });
        currentPlayer?.updateScoreInFirebase();
      }
    } catch (e) {
      // Handle error fetching player data
      logger('exception', {'title': 'HomeScreen', 'method': 'initialisePlayerData', 'file': 'home_screen', 'details': e.toString()});
    }
  }

  String getCountry() {
    String timeZone = DateTime.now().timeZoneName.toLowerCase();
    return timeZoneToCountryCode[timeZone] ?? 'in';
  }

  @override
  void initState() {
    super.initState();
    initialisePlayerData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Player?> getPlayerData(playerId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await firestore
      .collection(documentName)
      .doc(playerId)
      .get();

    if (snapshot.exists) {
      return Player.fromFirestore(snapshot);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentPlayer == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Pickr'),
          backgroundColor: appBarColour,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return MaterialApp(
      title: 'Pickr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        drawer: MyDrawer(player: currentPlayer!),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Pickr'),
          backgroundColor: appBarColour,
        ),
        body: Column(
          children: [
            Expanded(child: _buildList(context)),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.ios_share),
              label: 'Share',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_sharp),
              label: 'Account',
            ),
          ],
          currentIndex: 0,
          onTap: (int index) {
            // Handle tap events here
            switch (index) {
              case 0: {
                shareGame();
              }
              break;
              case 1: {
                showLeaderboard(context, currentPlayer);
              }
              break;
              case 2: {
                showAccount(context, currentPlayer);
              }
              break;
            }
          },
        ),
      ), 
    );
  }

  void shareGame() {
    logger('screen_view', {'firebase_screen': 'Share', 'firebase_screen_class': 'Share', 'file': 'home_screen'});
    Share.share('Check out this awesome game, Pickr!\nDownload it now from the Google Play Store: https://play.google.com/store/apps/details?id=com.playcraft.pickr&pcampaignid=web_share');
  }

  Widget _buildList(BuildContext context) {
    List<Widget> listItems = [
        _tile(
          'Mixed Bag',
          const ImageIcon(AssetImage('assets/images/categories/mixed.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Animals',
          const ImageIcon(AssetImage('assets/images/categories/animal.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Birds',
          const ImageIcon(AssetImage('assets/images/categories/bird.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Cities',
          const ImageIcon(AssetImage('assets/images/categories/city.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Dishes',
          const ImageIcon(AssetImage('assets/images/categories/dishes.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Flags',
          const ImageIcon(AssetImage('assets/images/categories/flag.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Fruits',
          const ImageIcon(AssetImage('assets/images/categories/fruit.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Logos',
          const ImageIcon(AssetImage('assets/images/categories/logo.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Monuments',
          const ImageIcon(AssetImage('assets/images/categories/monument.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'People',
          const ImageIcon(AssetImage('assets/images/categories/people.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Sports',
          const ImageIcon(AssetImage('assets/images/categories/sport.png'), size: 50, color: Colors.blue),
          context
        ),
        const Divider(),
      ];
    return ListView.builder(
      itemCount: listItems.length + listItems.length ~/ _adIndex,
      itemBuilder: (context, index) {
        final adIndex = index ~/ _adIndex;
        if (index != 0 && index % _adIndex == 0) {
          return const BannerAdClass();
        }
        return listItems[index - adIndex];
      }
    );
  }
  
  ListTile _tile(title, icon, context) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      leading: icon,
      onTap: () {
        logger('screen_view', {'firebase_screen': title, 'firebase_screen_class': 'QuizScreen', 'file': 'home_screen'});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(title: title, player: currentPlayer!),
            settings: RouteSettings(name: title),
          ),
        );
      },
    );
  }
}
