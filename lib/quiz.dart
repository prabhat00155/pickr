import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class QuizQuestion {
  String imageLink;
  List<String> options;
  int correctAnswerIndex;

  QuizQuestion({required this.imageLink, required this.options, required this.correctAnswerIndex});
}

class QuizScreen extends StatefulWidget {
  final String title;

  const QuizScreen({
    Key? key,
    required this.title,
  }): super(key: key);

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> quizQuestions = [
    QuizQuestion(
      imageLink: 'https://cdn.pixabay.com/photo/2013/10/15/09/12/flower-195893_150.jpg',
      options: ['Berlin', 'London', 'Paris', 'Flower'],
      correctAnswerIndex: 2,
    ),
    QuizQuestion(
      imageLink: 'https://cdn.pixabay.com/user/2013/11/05/02-10-23-764_250x250.jpg',
      options: ['Berlin', 'London', 'Paris', 'Flower'],
      correctAnswerIndex: 3,
    ),
    QuizQuestion(
      imageLink: 'https://pixabay.com/photos/big-ben-bridge-city-sunrise-river-2393098/',
      options: ['Berlin', 'London', 'Paris', 'Rome'],
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      imageLink: 'https://pixabay.com/photos/brand-front-of-the-brandenburg-gate-5117579/',
      options: ['Berlin', 'London', 'Paris', 'Rome'],
      correctAnswerIndex: 0,
    ),
    QuizQuestion(
      imageLink: 'https://pixabay.com/photos/rome-architecture-sunlight-building-4989538/',
      options: ['Berlin', 'London', 'Paris', 'Rome'],
      correctAnswerIndex: 3,
    ),
    // Add more quiz questions here...
  ];

  int currentQuestionIndex = 0;
  int maxAnsweredIndex = -1;
  int correctAnswers = 0;
  bool isOptionSelected = false;
  List<int?> userSelectedAnswers = List.filled(5, null);

  void goToPreviousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      }
    });
  }

  void goToNextQuestion() {
    if (isOptionSelected) {
      setState(() {
        if (currentQuestionIndex < quizQuestions.length - 1) {
          maxAnsweredIndex++;
          isOptionSelected = false;
        }
      });
    }
    if (currentQuestionIndex <= maxAnsweredIndex && currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  double calculateProgress() {
    return (currentQuestionIndex + 1) / quizQuestions.length;
  }

  @override
  Widget build(BuildContext context) {
    QuizQuestion currentQuestion = quizQuestions[currentQuestionIndex];
    List<String> options = currentQuestion.options;

    return Scaffold(
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
            const SizedBox(height: 20),
            CachedNetworkImage(
              imageUrl: currentQuestion.imageLink,
              fit: BoxFit.cover,
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
                      });
                      if(index == currentQuestion.correctAnswerIndex) {
                        setState(() {
                          correctAnswers++;
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
          ],
        ),
      ),
    );
  }
}
