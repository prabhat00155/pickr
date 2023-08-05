import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'advertisement2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _adIndex = 7;

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
          const ImageIcon(AssetImage('assets/images/mixed.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Animals',
          const ImageIcon(AssetImage('assets/images/animal.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Birds',
          const ImageIcon(AssetImage('assets/images/bird.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Cities',
          const ImageIcon(AssetImage('assets/images/city.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Dishes',
          const ImageIcon(AssetImage('assets/images/dishes.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Flags',
          const ImageIcon(AssetImage('assets/images/flag.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Flowers',
          const ImageIcon(AssetImage('assets/images/flower.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Fruits',
          const ImageIcon(AssetImage('assets/images/fruit.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Logos',
          const ImageIcon(AssetImage('assets/images/logo.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
        _tile(
          'Sports',
          const ImageIcon(AssetImage('assets/images/sport.png'), size: 50, color: Colors.blue),
          context
        ),
        const Divider(),
        _tile(
          'Vegetables',
          const ImageIcon(AssetImage('assets/images/vegetable.png'), size: 50, color: Colors.blue),
          context,
        ),
        const Divider(),
      ];
    return ListView.builder(
      itemCount: listItems.length + listItems.length ~/ _adIndex,
      itemBuilder: (context, index) {
        print('index = ${index}');
        final adIndex = index ~/ (_adIndex + 1);
        if (index != 0 && index % (_adIndex + 1) == 0) {
          print('inside');
          return const BannerAdClass();
        }
        print(index - adIndex);
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
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrendingResults(title: title),
            settings: RouteSettings(name: title),
          ),
        );*/
      },
    );
  }
}
