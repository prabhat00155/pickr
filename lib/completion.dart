import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'advertisement.dart';
import 'constants.dart';
import 'logger.dart';
import 'player.dart';

class Completion extends StatefulWidget {
  final Player player;
  final int score;
  final String accuracyText;
  final List<int> correctAnswersPerLevel;

  const Completion({
    super.key,
    required this.player,
    required this.score,
    required this.accuracyText,
    required this.correctAnswersPerLevel,
  });

  @override
  State<Completion> createState() => _CompletionState();
}

class _CompletionState extends State<Completion> {
  Player get currentPlayer => widget.player;
  int get score => widget.score;
  String get accuracyText => widget.accuracyText;
  List<int> get correctAnswersPerLevel => widget.correctAnswersPerLevel;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void scoreDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Score Details'),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Question')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Multiplier')),
                DataColumn(label: Text('Weighted Score')),
              ],
              rows: List.generate(correctAnswersPerLevel.length, (index) {
                int value = correctAnswersPerLevel[index];
                int multiplier = index + 1;
                int product = value * multiplier;
                return DataRow(cells: [
                  DataCell(Text(multiplier.toString())),
                  DataCell(Text(value.toString())),
                  DataCell(Text(multiplier.toString())),
                  DataCell(Text(product.toString())),
                ]);
              }),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        _showInterstitialAd();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Your Score: $score',
                      style: const TextStyle(fontSize: 24),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info,
                        size: 20.0,
                      ),
                      tooltip: 'Score details',
                      onPressed: scoreDetails,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Accuracy: $accuracyText',
                  style: const TextStyle(fontSize: 24),
                ),
                const BannerAdClass(),
              ],
            ),
          ),
        ),
      ),
    );
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
          logger('exception', {'title': 'Quiz', 'method': '_createInterstitialAd', 'file': 'completion', 'details': error.toString()});
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
      logger('exception', {'title': 'Quiz', 'method': '_showInterstitialAd', 'file': 'completion', 'details': message});
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          logger('onAdShowedFullScreenContent', {'title': 'Quiz', 'method': '_showInterstitialAd', 'file': 'completion', 'details': ad.toString()}),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        logger('onAdDismissedFullScreenContent', {'title': 'Quiz', 'method': '_showInterstitialAd', 'file': 'completion', 'details': ad.toString()});
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        logger('onAdFailedToShowFullScreenContent', {'title': 'Quiz', 'method': '_showInterstitialAd', 'file': 'completion', 'details': '$ad: $error'});
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
