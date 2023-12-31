import 'constants.dart';

class User {
  String name;
  String userId;
  String avatar = '100';
  String countryCode = 'in';
  PlayerLevels level = PlayerLevels.beginner;
  List<Badges> _badges = [];
  int _xpScore = 0;
  int _score = 0;
  Map<String, int> _perCategoryScores = Map.fromIterable(categories.map((category) => category.name).toList(),  value: (_) => 0);
  Map<String, int> _perCategoryAttempts = Map.fromIterable(categories.map((category) => category.name).toList(), value: (_) => 0);

  User(this.name, this.userId);

  int getScore(String category) => _perCategoryScores[category]!;

  int getAttempts(String category) => _perCategoryAttempts[category]!;

  void updateScore(String category, int score, int attempts) {
    _perCategoryScores[category] = _perCategoryScores[category]! + score;
    _perCategoryAttempts[category] = _perCategoryAttempts[category]! + attempts;
  }

  List<Badges> get badges => _badges;

  void addBadge(Badges badge) {
    _badges.add(badge);
  }
}
