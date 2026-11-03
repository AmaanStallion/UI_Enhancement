import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
            child: SizedBox(
                height: 200,
                width: 200,
                child:
                    // Lottie.asset(
                    //   'assets/animation/splash_scren.json',
                    //   repeat: true,
                    // ),
                    Image.asset('images/Icon-512.png'))),
      ),
    );
  }
}
