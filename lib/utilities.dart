import 'package:flutter/material.dart';

Color fetchColour(int score) {
  if (score > 500) {
    return Colors.lightBlue[200]!;
  } else if (score > 400) {
    return Colors.cyan[200]!;
  } else if (score > 300) {
    return Colors.teal[200]!;
  } else if (score > 200) {
    return Colors.green[200]!;
  } else if (score > 100) {
    return Colors.lightGreen[200]!;
  } else if (score > 50) {
    return Colors.lime[200]!;
  } else if (score > 25) {
    return Colors.yellow[200]!;
  } else if (score > 10) {
    return Colors.amber[200]!;
  } else {
    return Colors.orange[200]!;
  }
}
