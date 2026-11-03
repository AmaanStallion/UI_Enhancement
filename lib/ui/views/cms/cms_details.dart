import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../models/get_cms_details.dart';
import '../../shared/ui_helpers.dart';

class CmsPageHtml extends StatefulWidget {
  const CmsPageHtml({
    super.key,
    this.cmsId,
    this.navigationFlag,
    this.onBack,
  });

  final String? cmsId;
  final String? navigationFlag;
  final VoidCallback? onBack;

  @override
  State<CmsPageHtml> createState() => _CmsPageHtmlState();
}

class _CmsPageHtmlState extends State<CmsPageHtml> {
  String url = "";
  String? kLocalExamplePage = '';
  bool flagcalled = false;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  late BuildContext dialogContext;

  Future<ResponseGetCmsDetails?> fetchCmsDetailsHtml() async {
    Map<String, String> data = {
      "cms_id": widget.cmsId!,
    };

    if (kDebugMode) {
      print(data);
    }
    var response = await apiNetworkHandler.post(AppUrl.webCmsDetails, data);
    
    if (!mounted) return null;

    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getCmsDetailsFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          flagcalled = true;
          kLocalExamplePage = dataModel.response?.cmsDetails?[0].pageContent!;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.cmsId == '1') {
      kLocalExamplePage = "Specialist in Real Estate Technology Solutions! Stallion is made by Livingstone Group";
      flagcalled = true;
    } else {
      fetchCmsDetailsHtml();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.cmsId! == '1'
        ? 'About Us'
        : widget.cmsId! == '4'
            ? 'Terms & Conditions'
            : 'Privacy Policy';

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
        title: Text(
          titleText,
          style: const TextStyle(
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
                onPressed: widget.onBack,
              )
            : widget.navigationFlag == 'SideMenu'
                ? const SizedBox()
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20.0),
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                  ),
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: flagcalled == true
              ? TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 15 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  HtmlWidget(
                                    kLocalExamplePage!,
                                    textStyle: const TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: 14.5,
                                      height: 1.6,
                                      color: Color(0xff333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                    ],
                  ),
                )
              : Center(
                  child: SizedBox(
                    height: 64,
                    child: OverflowBox(
                      minHeight: 100,
                      maxHeight: 100,
                      child: Lottie.asset(
                        'assets/animation/running2.json',
                        repeat: true,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
