import 'package:flutter/material.dart';

import 'account.dart';
import 'advertisement.dart';
import 'quiz.dart';
import 'user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _adIndex = 7;
  User currentUser = User('foo', 'bar');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Pickr'),
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
              icon: Icon(Icons.info_outline),
              label: 'Info',
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
                showInfo(context);
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
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Account'),
            ),
            body: Account(user: currentUser),
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
            ),
            //body: const FeedbackForm(),
          );
        },
        settings: const RouteSettings(name: 'Feedback'),
      ),
    );
  }

  void showInfo(context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Info'),
            ),
            //body: const Info(),
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
            builder: (context) => QuizScreen(title: title, user: currentUser),
            settings: RouteSettings(name: title),
          ),
        );
      },
    );
  }
}
