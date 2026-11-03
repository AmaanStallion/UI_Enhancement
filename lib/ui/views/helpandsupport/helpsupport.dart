import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpSupport extends StatefulWidget {
  final VoidCallback? onBack;
  HelpSupport({Key? key, this.onBack});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  String url = "";
  String? kLocalExamplePage = '';
  bool flagcalled = false;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xfff0f0f0),
              height: 1.0,
            ),
          ),
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
                  onPressed: widget.onBack,
                )
              : null,
          title: const Text(
            'Help & Support',
            style: TextStyle(
              fontFamily: 'HelveticaNeue',
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: const SafeArea(
            child: Center(
              child: Text(
                'Contact admin',
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ));
  }
}
