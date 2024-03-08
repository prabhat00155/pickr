import 'dart:convert';
import 'package:flutter/services.dart';

import 'quiz.dart';
import 'mapper.dart';

Future<List<QuizQuestion>> loadJsonData(String category) async {
  List<QuizQuestion> quizData = [];
  if (mapCategoryToAsset.containsKey(category)) {
    String filename = mapCategoryToAsset[category]!;
    String jsonData = await rootBundle.loadString(filename);
    List<dynamic> data = json.decode(jsonData);
    quizData = data.map((json) => QuizQuestion.fromJson(json)).toList();
  }
  return quizData;
}
