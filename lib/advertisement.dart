import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdClass extends StatefulWidget {
  const BannerAdClass({Key? key}) : super(key: key);

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
        onAdLoaded: (ad) => print('Ad loaded.'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load .');
        },
        onAdOpened: (ad) => print('Ad opened.'),
        onAdClosed: (ad) => print('Ad closed.'),
        onAdImpression: (ad) => print('Ad impression.'),
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
