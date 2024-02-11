import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'account.dart';
import 'advertisement.dart';
import 'constants.dart';
import 'quiz.dart';
import 'player.dart';
import 'drawer.dart';
import 'leaderboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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
        setState(() {
          currentPlayer = Player(
            currentUser.uid,
            name: currentUser.displayName,
            email: currentUser.email,
            photoUrl: currentUser.photoURL,
            countryCode: country,
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
      print('Error initializing player data: $e');
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
    WidgetsBinding.instance!.addObserver(this);
    initialisePlayerData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // The app is going to the background. Call your function here.
      updateScore();
    }
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

  Future<void> updateScore() async {
    if (currentPlayer == null) {
      print('currentPlayer is null.');
      return;
    }
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userRef = firestore.collection('users').doc(currentPlayer!.playerId);
      await userRef.set(
        {
          'name': currentPlayer!.name,
          'score': currentPlayer!.getScore(),
          'highestScore': currentPlayer!.getHighestScore(),
          'photoUrl': currentPlayer!.photoUrl,
          'avatar': currentPlayer!.avatar,
          'level': currentPlayer!.level.toString(),
          'countryCode': currentPlayer!.countryCode,
          'perCategoryHighestScore': currentPlayer!.perCategoryHighestScore,
          'perCategoryTotalCorrect': currentPlayer!.perCategoryTotalCorrect,
          'perCategoryScores': currentPlayer!.perCategoryScores,
          'perCategoryAttempts': currentPlayer!.perCategoryAttempts,
        },
        SetOptions(merge: true),
      );
      print('score updated');
    } catch (e) {
      print('Error updating score: $e');
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
                showAccount(context);
              }
              break;
            }
          },
        ),
      ), 
    );
  }

  void showAccount(context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          if (currentPlayer == null) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('Account'),
                backgroundColor: appBarColour,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Account'),
              backgroundColor: appBarColour,
            ),
            body: Account(player: currentPlayer!),
          );
        },
        settings: const RouteSettings(name: 'Account'),
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
            //body: const FeedbackForm(),
          );
        },
        settings: const RouteSettings(name: 'Feedback'),
      ),
    );
  }

  void showLeaderboard(context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Leaderboard'),
              backgroundColor: appBarColour,
            ),
            body: const Leaderboard(),
          );
        },
        settings: const RouteSettings(name: 'Info'),
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
        //logger('click', {'title': title, 'method': '_tile', 'file': 'home_screen'});
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
