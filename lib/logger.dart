import 'package:firebase_analytics/firebase_analytics.dart';

void logger(eventName, eventParam) {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics.logEvent(
    name: eventName,
    parameters: eventParam,
  );
}
