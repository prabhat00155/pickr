import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'advertisement.dart';
import 'load_json.dart';
import 'user.dart';
part 'quiz.g.dart'; // Generated code file

const String defaultUrl = 'https://picsum.photos/200';
const int questionsPerLevel = 10;
const int maxQuestions = 100;

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

class QuizScreen extends StatefulWidget {
  final String title;
  final User user;

  const QuizScreen({
    Key? key,
    required this.title,
    required this.user,
  }): super(key: key);

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> quizQuestions = [];
  int currentQuestionIndex = 0;
  int maxAnsweredIndex = -1;
  int correctAnswers = 0;
  int noOfQuestions = 0;
  int currentLevel = 1;
  int correctLevelAnswers = 0;
  int score = 0;
  bool isOptionSelected = false;
  bool quizCompleted = false;
  List<int?> userSelectedAnswers = List.filled(maxQuestions, null);
  User get user => widget.user;

  void goToPreviousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      }
    });
  }

  String fetchImageLink(QuizQuestion question) {
    try {
      List<String> images = question.urls;
      int randIndex = Random().nextInt(images.length);
      return images[randIndex];
    } catch (e) {
      return defaultUrl;
    }
  }

  (List<String>, int) fetchOptions(QuizQuestion question) {
    List<String> shuffledOptions = [];
    List<String> options = question.options;
    final random = Random();
    final shuffledList = List.from(options)..shuffle(random);
    shuffledOptions = shuffledList.sublist(0, 3).cast<String>();
    String correctAnswer = question.name;
    int correctAnswerIndex = Random().nextInt(4);
    shuffledOptions.insert(correctAnswerIndex, correctAnswer);
    return (shuffledOptions, correctAnswerIndex);
  }

  void displayLevelUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Level Up!'),
          content: Column(
            children: [
              Text('Level up...'),
              // Add other completion details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void displayCompletion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Completed!'),
          content: Column(
            children: [
              Text('Your Score: $score'),
              // Add other completion details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void goToNextQuestion() {
    if (isOptionSelected) {
      if (currentQuestionIndex < quizQuestions.length - 1) {
        setState(() {
          maxAnsweredIndex++;
          isOptionSelected = false;
        });
      } else {
        setState(() {
          score += currentLevel * correctLevelAnswers;
          isOptionSelected = false;
          quizCompleted = true;
        });
        print('Complete!');
        displayCompletion();
      }
    }
    if (currentQuestionIndex <= maxAnsweredIndex && currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
    if (currentLevel < quizQuestions[currentQuestionIndex].level) {
      setState(() {
        score += currentLevel * correctLevelAnswers;
        correctLevelAnswers = 0;
        currentLevel++;
      });
      displayLevelUp();
      print('Level up');
      // InterstitialAdClass();
    }
  }

  double calculateProgress() {
    return (currentQuestionIndex + 1) / quizQuestions.length;
  }

  void fetchQuestions(String category) async {
    List<QuizQuestion> allQuestions = await loadJsonData(category);
    allQuestions.shuffle();

    Map<int, List<QuizQuestion>> questionsByLevel = {};

    // Group questions by level
    allQuestions.forEach((question) {
        if (!questionsByLevel.containsKey(question.level)) {
            questionsByLevel[question.level] = [];
        }
        var (x, y) = fetchOptions(question);
        question.options = x;
        question.correctAnswerIndex = y;
        question.urls = [fetchImageLink(question)];
        questionsByLevel[question.level]!.add(question);
    });

    List<QuizQuestion> selectedQuestions = [];

    // Select and sort questions by level
    List<int> sortedLevels = questionsByLevel.keys.toList()..sort();
    sortedLevels.forEach((level) {
        if (questionsByLevel[level]!.length >= questionsPerLevel) {
            selectedQuestions.addAll(questionsByLevel[level]!.sublist(0, questionsPerLevel));
        } else {
            selectedQuestions.addAll(questionsByLevel[level]!);
        }
    });

    setState(() {
      quizQuestions = selectedQuestions;
    });
  }

  void mixQuestions(List<String> categories, int questionsPerCategory, [int levels = 10]) async {
    List<QuizQuestion> mixedQuestions = [];

    for (int level = 1; level <= levels; level++) {
      for (String category in categories) {
        List<QuizQuestion> categoryQuestions = await loadJsonData(category);

        // Shuffle the questions to mix them randomly
        categoryQuestions.shuffle();

        // Select questions for the current level
        List<QuizQuestion> levelQuestions = categoryQuestions
            .where((question) => question.level == level)
            .take(questionsPerCategory)
            .toList();

        mixedQuestions.addAll(levelQuestions);
      }
    }

    setState(() {
      quizQuestions = mixedQuestions;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.title == 'All Categories')
      mixQuestions(['Animals'], 5);
    else
      fetchQuestions(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.length == 0) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.title),
          ),
          body: CircularProgressIndicator(),
        );
    }

    QuizQuestion currentQuestion = quizQuestions[currentQuestionIndex];
    List<String> options = currentQuestion.options;
    String imageLink = currentQuestion.urls[0];

    return WillPopScope(
      onWillPop: () async {
        if (!quizCompleted) {
          score += currentLevel * correctLevelAnswers;
          print('score updated');
        }
        user.updateScore(widget.title, correctAnswers, noOfQuestions, score);
        return true;
      },
      child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: calculateProgress(),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Level: ${currentQuestion.level}',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Score: $correctAnswers/$noOfQuestions',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CachedNetworkImage(
              imageUrl: imageLink,
              fit: BoxFit.contain,
              width: 200,
              height: 200,
              errorWidget: (context, url, error) {
                print('Error processing $url: $error');
                return const Icon(Icons.error);
              }
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if(!isOptionSelected && currentQuestionIndex > maxAnsweredIndex) {
                      setState(() {
                        isOptionSelected = true;
                        userSelectedAnswers[currentQuestionIndex] = index;
                        noOfQuestions++;
                      });
                      if(index == currentQuestion.correctAnswerIndex) {
                        setState(() {
                          correctAnswers++;
                          correctLevelAnswers++;
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: userSelectedAnswers[currentQuestionIndex] == index
                        ? (index == currentQuestion.correctAnswerIndex
                            ? Colors.green
                            : Colors.red)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      options[index],
                      style: TextStyle(
                        color: userSelectedAnswers[currentQuestionIndex] == index ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  ElevatedButton(
                  onPressed: goToPreviousQuestion,
                  child: const Text('<'),
                ),
                ElevatedButton(
                  onPressed: goToNextQuestion,
                  child: const Text('>'),
                ),
              ],
            ),
            const BannerAdClass(),
          ],
        ),
      ),
      ),
    );
  }
}
