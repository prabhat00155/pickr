import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'advertisement.dart';
import 'completion.dart';
import 'constants.dart';
import 'load_json.dart';
import 'logger.dart';
import 'player.dart';
import 'quiz.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final Player player;

  const QuizScreen({
    super.key,
    required this.title,
    required this.player,
  });

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> quizQuestions = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int noOfQuestions = 0;
  int currentLevel = 1;
  int score = 0;
  List<int?> userSelectedAnswers = List.filled(maxQuestions, null);
  List<int> correctAnswersPerLevel = List.filled(maxLevel, 0);
  Player get player => widget.player;
  int _remainingTimeInSeconds = timePerQuiz;
  late Timer _timer;
  bool autoTransitionActive = true;
  int timeContribution = 0;

  void goToPreviousQuestion() {
    setState(() {
      autoTransitionActive = false;
    });
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  String fetchImageLink(QuizQuestion question) {
    List<String> images = question.urls;
    if (images.isEmpty) {
      return '';
    }
    int randIndex = Random().nextInt(images.length);
    return images[randIndex];
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

  void computeScore() {
    for (int i = 0; i < maxLevel; i++) {
      score += correctAnswersPerLevel[i] * (i + 1);
    }
    int deno = 1 + maxQuestions - correctAnswers;
    timeContribution = _remainingTimeInSeconds ~/ (deno * deno);
    score = score + timeContribution;
  }

  void displayCompletion() {
    String accuracyText = 'N/A';
    if (noOfQuestions > 0) {
      accuracyText = '${100 * correctAnswers ~/ noOfQuestions}% ($correctAnswers/$noOfQuestions)';
    }
    player.addBadge(Badges.perseverence);
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Results'),
              backgroundColor: appBarColour,
            ),
            body: Completion(
              player: player,
              score: score,
              accuracyText: accuracyText,
              correctAnswersPerLevel: correctAnswersPerLevel,
              remainingTimeInSeconds: _remainingTimeInSeconds,
              timeContribution: timeContribution,
              wrongAnswers: maxQuestions - correctAnswers,
            ),
          );
        },
        settings: const RouteSettings(name: 'Completion'),
      ),
    );
  }

  void goToNextQuestion() {
    setState(() {
      autoTransitionActive = false;
    });
    if (currentQuestionIndex == quizQuestions.length - 1) {
      displayCompletion();
    }
    if (currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
    if (currentLevel < quizQuestions[currentQuestionIndex].level) {
      setState(() {
        currentLevel++;
      });
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
    for (var question in allQuestions) {
      if (!questionsByLevel.containsKey(question.level)) {
        questionsByLevel[question.level] = [];
      }
      var (x, y) = fetchOptions(question);
      question.options = x;
      question.correctAnswerIndex = y;
      question.urls = [fetchImageLink(question)];
      questionsByLevel[question.level]!.add(question);
    }

    List<QuizQuestion> selectedQuestions = [];

    // Select and sort questions by level
    List<int> sortedLevels = questionsByLevel.keys.toList()..sort();
    for (var level in sortedLevels) {
      if (questionsByLevel[level]!.length >= questionsPerLevel) {
        selectedQuestions.addAll(questionsByLevel[level]!.sublist(0, questionsPerLevel));
      } else {
        selectedQuestions.addAll(questionsByLevel[level]!);
      }
    }

    setState(() {
      quizQuestions = selectedQuestions;
    });
  }

  void mixQuestions() async {
    Map<int, List<QuizQuestion>> questionsByLevel = {};
    List<QuizQuestion> selectedQuestions = [];

    for (String category in categories.map((category) => category.name).toList()) {
      List<QuizQuestion> categoryQuestions = await loadJsonData(category);
      categoryQuestions.shuffle();

      // Group questions by level
      for (var question in categoryQuestions) {
        if (!questionsByLevel.containsKey(question.level)) {
          questionsByLevel[question.level] = [];
        }
        var (x, y) = fetchOptions(question);
        question.options = x;
        question.correctAnswerIndex = y;
        question.urls = [fetchImageLink(question)];
        questionsByLevel[question.level]!.add(question);
      }
    }
    questionsByLevel.forEach((level, questions) {
      questions.shuffle();
    });

    // Select and sort questions by level
    List<int> sortedLevels = questionsByLevel.keys.toList()..sort();
    for (var level in sortedLevels) {
      if (questionsByLevel[level]!.length >= questionsPerLevel) {
        selectedQuestions.addAll(questionsByLevel[level]!.sublist(0, questionsPerLevel));
      } else {
        selectedQuestions.addAll(questionsByLevel[level]!);
      }
    }
    setState(() {
      quizQuestions = selectedQuestions;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.title == 'Mixed Bag') {
      mixQuestions();
    } else {
      fetchQuestions(widget.title);
    }
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTimeInSeconds > 0) {
          _remainingTimeInSeconds--;
        } else {
          // Timer expired, end quiz
          timer.cancel();
          displayCompletion();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(widget.title),
            backgroundColor: appBarColour,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
    }

    QuizQuestion currentQuestion = quizQuestions[currentQuestionIndex];
    List<String> options = currentQuestion.options;
    String imageLink = currentQuestion.urls[0];

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        computeScore();
        player.updateScore(widget.title, correctAnswers, noOfQuestions, score);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
          backgroundColor: appBarColour,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: calculateProgress(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColours[currentQuestion.level - 1],
                        ),
                        child: Center(
                          child: Text(
                            '${currentQuestion.level}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.timer_sharp, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Time left: $_remainingTimeInSeconds s',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  imageLink,
                  fit: BoxFit.contain,
                  width: 200,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    final String errorMessage = 'Error loading local image: $error';
                    logger('exception', {'title': 'Quiz', 'method': 'build', 'file': 'quiz_timed', 'details': errorMessage});
                    return const Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.error),
                        SizedBox(height: 10),
                        Text(
                          'Failed to load image. Please report this.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    bool isOptionSelected = userSelectedAnswers[currentQuestionIndex] != null;
                    bool isSelected = userSelectedAnswers[currentQuestionIndex] == index;
                    bool isCorrect = index == currentQuestion.correctAnswerIndex;

                    return GestureDetector(
                      onTap: () {
                        if(!isOptionSelected) {
                          setState(() {
                            isOptionSelected = true;
                            userSelectedAnswers[currentQuestionIndex] = index;
                            noOfQuestions++;
                            autoTransitionActive = true;
                          });
                          int l = currentQuestion.level;
                          if(index == currentQuestion.correctAnswerIndex) {
                            setState(() {
                              correctAnswers++;
                              correctAnswersPerLevel[l - 1]++;
                            });
                          }
                          Future.delayed(const Duration(seconds: 1), () {
                            if (mounted && autoTransitionActive) {
                              goToNextQuestion();
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                            ? isCorrect ? Colors.green : Colors.red
                            : isCorrect && isOptionSelected ? Colors.green.withOpacity(0.5) : Colors.transparent,
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
      ),
    );
  }
}
