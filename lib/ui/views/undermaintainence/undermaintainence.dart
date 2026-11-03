import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UnderMaintainence extends StatefulWidget {
  const UnderMaintainence({Key? key}) : super(key: key);

  @override
  State<UnderMaintainence> createState() => _UnderMaintainenceState();
}

class _UnderMaintainenceState extends State<UnderMaintainence> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
                child: Image(
              image: AssetImage('images/Icon-512.png'),
              width: 170,
              height: 170,
            )),
            SizedBox(
              width: 400,
              height: 400,
              child: Lottie.asset(
                'assets/animation/anim3.json',
                repeat: true,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text(
                'We are going through Maintenance\n          It won\'t take too long!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
