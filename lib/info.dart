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
