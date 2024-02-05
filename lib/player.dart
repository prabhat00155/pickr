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
  int _xpScore = 0;
  int score = 0;
  Map<String, int> _perCategoryTotalCorrect = Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0);
  Map<String, int> _perCategoryScores = Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0);
  Map<String, int> _perCategoryAttempts = Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0);

  Player(this.playerId, {this.name, this.email, this.photoUrl, this.score = 0});

  factory Player.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Player(
      doc.id,
      name: data['name'],
      score: data['score'],
    );
  }

  int getScore() => score;

  int getCategoryTotalCorrect(String category) => _perCategoryTotalCorrect[category]!;

  int getCategoryScores(String category) => _perCategoryScores[category]!;

  int getAttempts(String category) => _perCategoryAttempts[category]!;

  void updateScore(String category, int correctAnswers, int attempts, int new_score) {
    _perCategoryTotalCorrect[category] = _perCategoryTotalCorrect[category]! + correctAnswers;
    _perCategoryScores[category] = _perCategoryScores[category]! + score;
    _perCategoryAttempts[category] = _perCategoryAttempts[category]! + attempts;
    score += new_score;
  }

  List<Badges> get badges => _badges;

  void addBadge(Badges badge) {
    _badges.add(badge);
  }
}
