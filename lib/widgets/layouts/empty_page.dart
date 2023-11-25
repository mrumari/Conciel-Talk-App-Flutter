import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyPage extends StatelessWidget {
  final bool loading;
  const EmptyPage({this.loading = false, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final width = min(1.sw, 300.w) / 2;
    return Scaffold(
      // Add invisible appbar to make status bar on Android tablets bright.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Hero(
              tag: 'info-logo',
              child: Image.asset(
                'assets/favicon.png',
                width: width,
                height: width,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          if (loading)
            Center(
              child: SizedBox(
                width: width,
                child: const LinearProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
