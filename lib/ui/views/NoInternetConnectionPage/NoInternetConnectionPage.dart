import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../shared/ui_helpers.dart';
import '../../widgets/simple_button.dart';

class NoInternetConnectionPage extends StatefulWidget {
  NoInternetConnectionPage({Key? key, required this.callback})
      : super(key: key);

  Function callback;
  @override
  State<NoInternetConnectionPage> createState() =>
      _NoInternetConnectionPageState();
}

class _NoInternetConnectionPageState extends State<NoInternetConnectionPage>
    with TickerProviderStateMixin {
  int _fps = 30;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Center(
                    child: Image(
                  image: AssetImage('images/Icon-512.png'),
                  width: 150,
                  height: 150,
                )),
                SizedBox(
                  width: 400,
                  height: 300,
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
                    'No Internet Connection',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Center(
                  child: Text(
                    'There is no internet connection!. Please check your internet signal.',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 40,
                    child: SimpleButton(
                      lblText: 'REFRESH NOW',
                      color: kcPrimaryColor,
                      onTap: () async {
                        widget.callback();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
