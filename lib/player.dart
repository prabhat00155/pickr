import 'package:cloud_firestore/cloud_firestore.dart';

import 'constants.dart';

class Player {
  String? name;
  String playerId;
  String? email;
  String? photoUrl;
  String avatar = '100';
  String countryCode = 'in';
  PlayerLevels level = PlayerLevels.beginner;
  List<Badges> _badges = [];
  int score = 0;
  int highestScore = 0;
  int totalAttempts = 0;
  Map<String, int> perCategoryHighestScore = Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0);
  Map<String, int> perCategoryTotalCorrect = Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0);
  Map<String, int> perCategoryScores = Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0);
  Map<String, int> perCategoryAttempts = Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0);

  Player(
    this.playerId, {
    this.name,
    this.email,
    this.photoUrl,
    this.score = 0,
    this.highestScore = 0,
    this.totalAttempts = 0,
    this.avatar = '100',
    this.level = PlayerLevels.beginner,
    this.countryCode = 'in',
    required this.perCategoryHighestScore,
    required this.perCategoryTotalCorrect,
    required this.perCategoryScores,
    required this.perCategoryAttempts,
  });

  factory Player.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, int> perCategoryHighestScore = Map<String, int>.from(data['perCategoryHighestScore'] ?? Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0));
    Map<String, int> perCategoryTotalCorrect = Map<String, int>.from(data['perCategoryTotalCorrect'] ?? Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0));
    Map<String, int> perCategoryScores = Map<String, int>.from(data['perCategoryScores'] ?? Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0));
    Map<String, int> perCategoryAttempts = Map<String, int>.from(data['perCategoryAttempts'] ?? Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0));

    return Player(
      doc.id,
      name: data['name'],
      score: data['score'],
      highestScore: data['highestScore'],
      totalAttempts: data['totalAttempts'],
      photoUrl: data['photoUrl'],
      avatar: data['avatar'],
      level: PlayerLevels.values.firstWhere((e) => e.toString() == data['level']),
      countryCode: data['countryCode'],
      perCategoryHighestScore: perCategoryHighestScore,
      perCategoryTotalCorrect: perCategoryTotalCorrect,
      perCategoryScores: perCategoryScores,
      perCategoryAttempts: perCategoryAttempts,
    );
  }

  Future<void> updateScoreInFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userRef = firestore.collection('users').doc(playerId);
      await userRef.set(
        {
          'name': name,
          'score': score,
          'highestScore': highestScore,
          'totalAttempts': totalAttempts,
          'photoUrl': photoUrl,
          'avatar': avatar,
          'level': level.toString(),
          'countryCode': countryCode,
          'perCategoryHighestScore': perCategoryHighestScore,
          'perCategoryTotalCorrect': perCategoryTotalCorrect,
          'perCategoryScores': perCategoryScores,
          'perCategoryAttempts': perCategoryAttempts,
        },
        SetOptions(merge: true),
      );
      print('score updated');
    } catch (e) {
      print('Error updating score: $e');
    }
  }

  int getScore() => score;

  int getHighestScore() => highestScore;

  int getCategoryTotalCorrect(String category) => perCategoryTotalCorrect[category]!;

  int getCategoryScores(String category) => perCategoryScores[category]!;

  int getAttempts(String category) => perCategoryAttempts[category]!;

  void updateScore(String category, int correctAnswers, int attempts, int newScore) {
    perCategoryTotalCorrect[category] = perCategoryTotalCorrect[category]! + correctAnswers;
    perCategoryScores[category] = perCategoryScores[category]! + newScore;
    perCategoryAttempts[category] = perCategoryAttempts[category]! + attempts;
    score += newScore;
    totalAttempts += attempts;
    if (newScore >= highestScore) {
      highestScore = newScore;
    }
    if (newScore >= perCategoryHighestScore[category]!) {
      perCategoryHighestScore[category] = newScore;
    }
    updateScoreInFirebase();
  }

  List<Badges> get badges => _badges;

  void addBadge(Badges badge) {
    _badges.add(badge);
  }

  double getAccuracy(String category) {
    if (perCategoryAttempts[category] == 0) {
      return 0;
    }
    return 100.0 * perCategoryTotalCorrect[category]! / perCategoryAttempts[category]!;
  }
}
