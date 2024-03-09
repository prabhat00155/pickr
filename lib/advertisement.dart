import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'logger.dart';

class BannerAdClass extends StatefulWidget {
  const BannerAdClass({super.key});

  @override
  BannerAdState createState() => BannerAdState();
}

class BannerAdState extends State<BannerAdClass>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final String adUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/6300978111'
    : 'ca-app-pub-3940256099942544/2934735716';

  late BannerAd myBanner;

  @override
  void initState() {
    super.initState();
    myBanner = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) =>
          logger('onAdLoaded', {'title': 'advertisement', 'method': 'initState', 'file': 'advertisement', 'details': 'Ad loaded: $ad'}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          logger('onAdFailedToLoad', {'title': 'advertisement', 'method': 'initState', 'file': 'advertisement', 'details': 'Ad failed to load: $ad'});
        },
        onAdOpened: (ad) =>
          logger('onAdOpened', {'title': 'advertisement', 'method': 'initState', 'file': 'advertisement', 'details': 'Ad opened: $ad'}),
        onAdClosed: (ad) =>
          logger('onAdClosed', {'title': 'advertisement', 'method': 'initState', 'file': 'advertisement', 'details': 'Ad closed: $ad'}),
        onAdImpression: (ad) =>
          logger('onAdImpression', {'title': 'advertisement', 'method': 'initState', 'file': 'advertisement', 'details': 'Ad impression: $ad'}),
      ),
    )..load();
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      margin: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: AdWidget(ad: myBanner),
    );
  }
}
