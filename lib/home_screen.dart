import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'account.dart';
import 'advertisement.dart';
import 'constants.dart';
import 'drawer.dart';
import 'logger.dart';
import 'player.dart';
import 'quiz.dart';
import 'user_feedback.dart';
import 'utilities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _adIndex = 7;
  Player? currentPlayer;
  bool _isLoading = true;

  Future<void> initialisePlayerData() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final playerId = currentUser.uid;

    try {
      final player = await getPlayerData(playerId);
      if (player != null && mounted) {
        setState(() {
          currentPlayer = player;
          _isLoading = false;
        });
      } else if (mounted) {
        String country = getCountry();
        String avatarIndex = fetchRandom();
        setState(() {
          currentPlayer = Player(
            currentUser.uid,
            name: currentUser.displayName,
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
          _isLoading = false;
        });
      }
     } catch (e) {
      // Handle error fetching player data
      logger('exception', {'title': 'HomeScreen', 'method': 'initialisePlayerData', 'file': 'home_screen', 'details': e.toString()});
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              icon: Icon(Icons.feedback),
              label: 'Feedback',
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
                showFeedback(context);
              }
              break;
              case 1: {
                showLeaderboard(context);
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

  void showFeedback(context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Feedback'),
              backgroundColor: appBarColour,
            ),
            body: FeedbackForm(player: currentPlayer!),
          );
        },
        settings: const RouteSettings(name: 'Feedback'),
      ),
    );
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
        logger('click', {'title': title, 'method': '_tile', 'file': 'home_screen'});
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
