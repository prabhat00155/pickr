import 'package:json_annotation/json_annotation.dart';

part 'quiz.g.dart'; // Generated code file

@JsonSerializable()
class QuizQuestion {
  final int level;
  final String name;
  List<String> options;
  List<String> urls;
  int correctAnswerIndex = 0;

  QuizQuestion({required this.level, required this.name, required this.options, required this.urls});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => _$QuizQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}
