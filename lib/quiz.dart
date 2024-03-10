import 'dart:math';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:json_annotation/json_annotation.dart';

import 'advertisement.dart';
import 'constants.dart';
import 'load_json.dart';
import 'logger.dart';
import 'player.dart';
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
  int maxAnsweredIndex = -1;
  int correctAnswers = 0;
  int noOfQuestions = 0;
  int currentLevel = 1;
  int correctLevelAnswers = 0;
  int score = 0;
  bool isOptionSelected = false;
  bool quizCompleted = false;
  List<int?> userSelectedAnswers = List.filled(maxQuestions, null);
  Player get player => widget.player;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

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
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_upward, color: Colors.green),
              SizedBox(width: 10),
              Text('Level Up!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(width: 10),
              Icon(Icons.arrow_upward, color: Colors.green),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Well done! You have reached the next level.'),
              const SizedBox(height: 10),
              Text('Current Score: $score'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void displayCompletion() {
    int accuracy = 100 * correctAnswers ~/ noOfQuestions;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Completed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Congratulations on completing the quiz!'),
              const SizedBox(height: 10),
              Text('Your Score: $score'),
              const SizedBox(height: 10),
              Text('Accuracy: $accuracy %'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
    player.addBadge(Badges.perseverence);
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
      if (currentLevel % 3 == 0) {
        _showInterstitialAd();
      }
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

  void mixQuestions() async {
    Map<int, List<QuizQuestion>> questionsByLevel = {};
    List<QuizQuestion> selectedQuestions = [];

    for (String category in categories.map((category) => category.name).toList()) {
      List<QuizQuestion> categoryQuestions = await loadJsonData(category);
      categoryQuestions.shuffle();

      // Group questions by level
      categoryQuestions.forEach((question) {
          if (!questionsByLevel.containsKey(question.level)) {
              questionsByLevel[question.level] = [];
          }
          var (x, y) = fetchOptions(question);
          question.options = x;
          question.correctAnswerIndex = y;
          question.urls = [fetchImageLink(question)];
          questionsByLevel[question.level]!.add(question);
      });
    }
    questionsByLevel.forEach((level, questions) {
      questions.shuffle();
    });

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

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    if (widget.title == 'Mixed Bag') {
      mixQuestions();
    } else {
      fetchQuestions(widget.title);
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _createInterstitialAd() {
    // TODO: replace this test ad unit with your own ad unit.
    final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          logger('exception', {'title': 'Quiz', 'method': '_createInterstitialAd', 'file': 'quiz', 'details': error.toString()});
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        },
      ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      const String message = 'Warning: attempt to show interstitial before it has loaded.';
      logger('exception', {'title': 'Quiz', 'method': '_showInterstitialAd', 'file': 'quiz', 'details': message});
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          logger('onAdShowedFullScreenContent', {'title': 'Quiz', 'method': '_showInterstitialAd', 'file': 'quiz', 'details': ad.toString()}),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        logger('onAdDismissedFullScreenContent', {'title': 'Quiz', 'method': '_showInterstitialAd', 'file': 'quiz', 'details': ad.toString()});
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        logger('onAdFailedToShowFullScreenContent', {'title': 'Quiz', 'method': '_showInterstitialAd', 'file': 'quiz', 'details': '$ad: $error'});
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
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

    return WillPopScope(
      onWillPop: () async {
        if (!quizCompleted) {
          score += currentLevel * correctLevelAnswers;
        }
        player.updateScore(widget.title, correctAnswers, noOfQuestions, score);
        return true;
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Level: ${currentQuestion.level}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Score: $correctAnswers/$noOfQuestions',
                        style: const TextStyle(color: Colors.white),
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
                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                      strokeWidth: 5,
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    final String message = 'Error processing $url: $error';
                    logger('exception', {'title': 'Quiz', 'method': 'build', 'file': 'quiz', 'details': message});
                    return const Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.error),
                        SizedBox(height: 10),
                        Text(
                          'Please ensure that you are connected to the internet!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    bool isSelected = userSelectedAnswers[currentQuestionIndex] == index;
                    bool isCorrect = index == currentQuestion.correctAnswerIndex;

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
