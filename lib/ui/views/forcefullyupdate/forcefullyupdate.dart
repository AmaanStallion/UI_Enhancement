import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:version_check/version_check.dart';
import '../../shared/ui_helpers.dart';
import '../../widgets/simple_button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class ForcefullyUpdate extends StatefulWidget {
  const ForcefullyUpdate({Key? key}) : super(key: key);

  @override
  State<ForcefullyUpdate> createState() => _ForcefullyUpdateState();
}

class _ForcefullyUpdateState extends State<ForcefullyUpdate>
    with TickerProviderStateMixin {
  // VersionCheck versionCheck = VersionCheck();

  @override
  void initState() {
    super.initState();
  }

  // Future checkVersion() async {
  //   versionCheck = await VersionCheck(
  //     packageName: Platform.isMacOS
  //         ? 'com.stallionbuildllp.stallion'
  //         : 'com.stallionbuildllp.stallion',
  //     packageVersion: '1.0.0',
  //     showUpdateDialog: customShowUpdateDialog,
  //     country: 'in',
  //   ).checkVersion(context);
  // }

  bool isUpdateAvailable(String currentVersion, String latestVersion) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> latestParts = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > (i < currentParts.length ? currentParts[i] : 0)) {
        return true; // A higher version is available
      }
    }
    return false;
  }

  void customShowUpdateDialog(BuildContext context, String versionCheck) {
    // if (versionCheck.packageVersion != null &&
    //     versionCheck.storeVersion != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('New Update Available'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Do you really want to update to ${versionCheck}?'),
              Text('(current version ${versionCheck})'),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: SizedBox(
              width: 150,
              height: 40,
              child: SimpleButton(
                lblText: 'UPDATE NOW',
                color: kcPrimaryColor,
                onTap: () async {
                  if (Platform.isMacOS) {
                    // await versionCheck.launchStore();
                    Navigator.of(context).pop();
                  } else {
                    _launchURL();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                  'assets/animation/anim2.json',
                  repeat: true,
                ),
              ),
              const Center(
                child: Text(
                  'We have hit the streak and reached optimum level.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              verticalSpaceMedium,
              Container(
                width: 200,
                height: 45,
                child: SimpleButton(
                  lblText: 'UPDATE NOW',
                  color: kcPrimaryColor,
                  onTap: () async {
                    // if (versionCheck.packageVersion != null) {
                    //   if (Platform.isMacOS) {
                    //     await versionCheck.launchStore();
                    //   } else {
                    //     _launchURL();
                    //   }
                    // } else {
                    if (Platform.isMacOS) {
                      _launchURLMacOs();
                    } else {
                      _launchURL();
                    }
                    // }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://stallion.build/download-center/index.html';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURLMacOs() async {
    const url = 'https://apps.apple.com/in/app/stallion-build/id6443916435';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
