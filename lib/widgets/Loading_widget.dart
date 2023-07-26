import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.white]),
            Text('Please Wait, Retrieving Data..')
          ],
        ),
      ),
    );
  }
}