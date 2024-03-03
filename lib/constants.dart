import 'package:flutter/material.dart';

enum PlayerLevels {
  beginner,
  novice,
  apprentice,
  intermediate,
  experienced,
  legend,
  wizard,
}

enum Badges {
  allrounder,
  zoologist,
  ornithologist,
  traveller,
  gourmet,
  vexillologist,
  pomologist,
  logo,
  archaeologist,
  people,
  sports,
  tenInARow,
  twentyInARow,
  twentyfiveInARow,
  fiftyInARow,
  fiftyCorrectAnswers,
  hundredCorrectAnswers,
  fivehundredCorrectAnswers,
  thousandCorrectAnswers,
  perseverence,
}

Map<PlayerLevels, String> levelToImage = {
  PlayerLevels.beginner: 'assets/images/badges/beginner.JPG',
  PlayerLevels.novice: 'assets/images/badges/novice.png',
  PlayerLevels.apprentice: 'assets/images/badges/apprentice.png',
  PlayerLevels.intermediate: 'assets/images/badges/intermediate.JPG',
  PlayerLevels.experienced: 'assets/images/badges/experienced.JPG',
  PlayerLevels.legend: 'assets/images/badges/legend.JPG',
  PlayerLevels.wizard: 'assets/images/badges/wizard.png',
};

Map<Badges, String> badgeToImage = {
  Badges.allrounder: 'assets/images/badges/allrounder.JPG',
  Badges.zoologist: 'assets/images/badges/zoologist.JPG',
  Badges.ornithologist: 'assets/images/badges/ornithologist.png',
  Badges.traveller: 'assets/images/badges/traveller.JPG',
  Badges.gourmet: 'assets/images/badges/gourmet.JPG',
  Badges.vexillologist: 'assets/images/badges/vexillologist.JPG',
  Badges.pomologist: 'assets/images/badges/pomologist.JPG',
  Badges.logo: 'assets/images/badges/logo.JPG',
  Badges.archaeologist: 'assets/images/badges/archaeologist.JPG',
  Badges.people: 'assets/images/badges/people.JPG',
  Badges.sports: 'assets/images/badges/sports.JPG',
  Badges.tenInARow: 'assets/images/badges/ten_in_a_row.JPG',
  Badges.twentyInARow: 'assets/images/badges/twenty_in_a_row.JPG',
  Badges.twentyfiveInARow: 'assets/images/badges/twentyfive_in_a_row.JPG',
  Badges.fiftyInARow: 'assets/images/badges/fifty_in_a_row.JPG',
  Badges.fiftyCorrectAnswers: 'assets/images/badges/fifty_correct_answers.JPG',
  Badges.hundredCorrectAnswers: 'assets/images/badges/hundred_correct_answers.JPG',
  Badges.fivehundredCorrectAnswers: 'assets/images/badges/fivehundred_correct_answers.JPG',
  Badges.thousandCorrectAnswers: 'assets/images/badges/thousand_correct_answers.JPG',
  Badges.perseverence: 'assets/images/badges/perseverence.JPG',
};

Map<String, Badges> categoryToBadge = {
  'Mixed Bag': Badges.allrounder,
  'Animals': Badges.zoologist,
  'Birds': Badges.ornithologist,
  'Cities': Badges.traveller,
  'Dishes': Badges.gourmet,
  'Flags': Badges.vexillologist,
  'Fruits': Badges.pomologist,
  'Logos': Badges.logo,
  'Monuments': Badges.archaeologist,
  'People': Badges.people,
  'Sports': Badges.sports,
};

class Category {
  final String name;
  final String iconfile;

  const Category(this.name, this.iconfile);
}

const categories = [
  Category('Mixed Bag', 'assets/images/categories/mixed.png'),
  Category('Animals', 'assets/images/categories/animal.png'),
  Category('Birds', 'assets/images/categories/bird.png'),
  Category('Cities', 'assets/images/categories/city.png'),
  Category('Dishes', 'assets/images/categories/dishes.png'),
  Category('Flags', 'assets/images/categories/flag.png'),
  Category('Fruits', 'assets/images/categories/fruit.png'),
  Category('Logos', 'assets/images/categories/logo.png'),
  Category('Monuments', 'assets/images/categories/monument.png'),
  Category('People', 'assets/images/categories/people.png'),
  Category('Sports', 'assets/images/categories/sport.png'),
];

const List<String> countryCodes = [
  'af',
  'al',
  'dz',
  'as',
  'ad',
  'ao',
  'ai',
  'aq',
  'ag',
  'ar',
  'am',
  'aw',
  'au',
  'at',
  'az',
  'bs',
  'bh',
  'bd',
  'bb',
  'by',
  'be',
  'bz',
  'bj',
  'bm',
  'bt',
  'bo',
  'ba',
  'bw',
  'bv',
  'br',
  'io',
  'bn',
  'bg',
  'bf',
  'bi',
  'cv',
  'kh',
  'cm',
  'ca',
  'ky',
  'cf',
  'td',
  'cl',
  'cn',
  'cx',
  'cc',
  'co',
  'km',
  'cd',
  'cg',
  'ck',
  'cr',
  'hr',
  'cu',
  'cw',
  'cy',
  'cz',
  'ci',
  'dk',
  'dj',
  'dm',
  'do',
  'ec',
  'eg',
  'sv',
  'gq',
  'er',
  'ee',
  'sz',
  'et',
  'fk',
  'fo',
  'fj',
  'fi',
  'fr',
  'pf',
  'tf',
  'ga',
  'gm',
  'ge',
  'de',
  'gh',
  'gi',
  'gr',
  'gl',
  'gd',
  'gp',
  'gu',
  'gt',
  'gg',
  'gn',
  'gw',
  'gy',
  'ht',
  'hm',
  'va',
  'hn',
  'hk',
  'hu',
  'is',
  'in',
  'id',
  'ir',
  'iq',
  'ie',
  'im',
  'il',
  'it',
  'jm',
  'jp',
  'je',
  'jo',
  'kz',
  'ke',
  'ki',
  'kp',
  'kr',
  'kw',
  'kg',
  'la',
  'lv',
  'lb',
  'ls',
  'lr',
  'ly',
  'li',
  'lt',
  'lu',
  'mo',
  'mg',
  'mw',
  'my',
  'mv',
  'ml',
  'mt',
  'mh',
  'mq',
  'mr',
  'mu',
  'yt',
  'mx',
  'fm',
  'md',
  'mc',
  'mn',
  'me',
  'ms',
  'ma',
  'mz',
  'mm',
  'na',
  'nr',
  'np',
  'nl',
  'nc',
  'nz',
  'ni',
  'ne',
  'ng',
  'nu',
  'nf',
  'mp',
  'no',
  'om',
  'pk',
  'pw',
  'ps',
  'pa',
  'pg',
  'py',
  'pe',
  'ph',
  'pn',
  'pl',
  'pt',
  'pr',
  'qa',
  'mk',
  'ro',
  'ru',
  'rw',
  're',
  'bl',
  'sh',
  'kn',
  'lc',
  'mf',
  'pm',
  'vc',
  'ws',
  'sm',
  'st',
  'sa',
  'sn',
  'rs',
  'sc',
  'sl',
  'sg',
  'sx',
  'sk',
  'si',
  'sb',
  'so',
  'za',
  'gs',
  'ss',
  'es',
  'lk',
  'sd',
  'sr',
  'sj',
  'se',
  'ch',
  'sy',
  'tw',
  'tj',
  'tz',
  'th',
  'tl',
  'tg',
  'tk',
  'to',
  'tt',
  'tn',
  'tr',
  'tm',
  'tc',
  'tv',
  'ug',
  'ua',
  'ae',
  'gb',
  'us',
  'uy',
  'uz',
  'vu',
  've',
  'vn',
  'vg',
  'vi',
  'wf',
  'eh',
  'ye',
  'zm',
  'zw',
  'ax',
];

const Color appBarColour = Colors.green;
const List<String> languages = <String>[
  'English',
];
const String documentName = 'users';
const String defaultUrl = 'https://picsum.photos/200';
const int questionsPerLevel = 10;
const int maxQuestions = 100;

Map<String, String> timeZoneToCountryCode = {
  'gmt': 'gb',
  'bst': 'gb',
  'ist': 'in',
  'pst': 'us',
  'pdt': 'us',
  'est': 'us',
  'edt': 'us',
  'hst': 'us',
  'hdt': 'us',
  'akst': 'us',
  'akdt': 'us',
  'mst': 'us',
  'mdt': 'us',
  'cst': 'us',
  'cdt': 'us',
  'eat': 'ke',
  'cet': 'es',
  'wat': 'ng',
  'sast': 'za',
  'eet': 'ly',
  'cat': 'zw',
  'jst': 'jp',
  'ast': 'ca',
  'nst': 'ca',
  'ndt': 'ca',
  'nzst': 'nz',
  'nzdt': 'nz',
  'hkt': 'hk',
  'wib': 'id',
  'wit': 'id',
  'wita': 'id',
  'pkt': 'pk',
  'kst': 'kr',
  'sst': 'as',
  'awst': 'au',
  'msk': 'ru',
  'chst': 'gu',
};
