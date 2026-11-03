import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/submit_deactivte_account.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../../websocket/portal_access_service.dart';
import '../../shared/ui_helpers.dart';

class MyProfileView extends StatefulWidget {
  final VoidCallback? onBack;
  MyProfileView({Key? key, this.onBack});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;

  String? strName = '';
  String? strDesignation = '';
  String? strProfile = '';
  String? strCompanyName = '';
  String? strMobileNo = '';
  String? ProfileImg = "";
  String? token = "";

  Future<ResponseSubmitDeactivateAccount?> submitDeleteAccount() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "mobile_no": userId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.websubmitdeactivateaccount, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = submitDeactivateAccountFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        logout();
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  void logout() async {
    if (kDebugMode) {
      print('logoutCalled');
    }
    final SharedPreferences prefs = await _prefs;
    prefs.setString('userId', "");
    prefs.setString('userName', "");
    prefs.setString('mobileNo', "");
    prefs.setString('companyName', "");
    prefs.setString('companyId', "");
    prefs.setString('profileImg', "");
    prefs.setString('desingnation', "");
    prefs.setString('userType', "");
    prefs.setString('userProfile', "");
    await prefs.clear();
    await IsFirstRun.reset();
    await Future.delayed(const Duration(seconds: 1));
    _pop();
  }

  _pop() {
    Navigator.of(context).pushReplacementNamed('/tutorial');
  }

  @override
  void initState() {
    super.initState();
    flagcalled = true;
    fetchMyProfile();
  }

  void fetchMyProfile() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      strMobileNo = prefs.getString('mobileNo') ?? "";
      strName = prefs.getString('userName') ?? "";
      strCompanyName = prefs.getString('companyName') ?? "";
      ProfileImg = prefs.getString('profileImg') ?? "";
      strDesignation = prefs.getString('desingnation') ?? "";
      strProfile = prefs.getString('userProfile') ?? "";
      token = prefs.getString('token') ?? "";
    });

    if (AppUrl.useNewBackend) {
      try {
        var response = await apiNetworkHandler.get("${AppUrl.baseURL}auth/me");
        if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            var data = decoded['data'];
            setState(() {
              strName = data['name'] ?? "";
              strMobileNo = data['mobile_no'] ?? data['email'] ?? "";
              strDesignation = data['designation'] ?? "";
              strProfile = data['role'] ?? "";
              strCompanyName = data['company_name'] ?? "";
              ProfileImg = data['profile_image_url'] ?? "";
            });
            prefs.setString('userName', strName ?? "");
            prefs.setString('mobileNo', strMobileNo ?? "");
            prefs.setString('desingnation', strDesignation ?? "");
            prefs.setString('userProfile', strProfile ?? "");
            prefs.setString('companyName', strCompanyName ?? "");
            prefs.setString('profileImg', ProfileImg ?? "");
            prefs.setString('parentDeveloperId', data['parent_developer_id']?.toString() ?? "");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching profile: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('MY PROFILE',
            style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
      ),
      body: Container(
          height: double.infinity,
          color: Colors.black,
          child: flagcalled == true
              ? Builder(builder: (context) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 80.0 : 16.0,
                      vertical: isDesktop ? 40.0 : 16.0,
                    ),
                    child: Center(
                      child: Container(
                        width: isDesktop ? 400.0 : double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isDesktop) verticalSpaceMedium,
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 120,
                                    maxWidth: 120,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 16,
                                          spreadRadius: 4,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: ProfileImg == null || ProfileImg!.isEmpty
                                          ? Image.asset('images/profile-icon.png', fit: BoxFit.cover)
                                          : AppUrl.useNewBackend
                                              ? CachedNetworkImage(
                                                  width: 120,
                                                  height: 120,
                                                  imageUrl: ProfileImg!.startsWith('http')
                                                      ? ProfileImg!
                                                      : "${AppUrl.baseURL}${ProfileImg!.startsWith('/') ? ProfileImg!.substring(1) : ProfileImg!}",
                                                  httpHeaders: token != null && token!.isNotEmpty
                                                      ? {"Authorization": "Bearer $token"}
                                                      : null,
                                                  placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                                                  errorWidget: (context, url, error) => Image.asset('images/profile-icon.png', fit: BoxFit.cover),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  AppUrl.globalProfileImgURLThumbs + ProfileImg!,
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Image.asset('images/profile-icon.png', fit: BoxFit.cover),
                                                ),
                                    ),
                                  ),
                                ),
                              ),
                              verticalSpaceMedium,
                              Text(
                                'NAME',
                                style: boldText.copyWith(color: Colors.white),
                              ),
                              verticalSpaceSmall,
                              Text(
                                strName!,
                                style: normalText.copyWith(color: Colors.white),
                              ),
                              const Divider(height: 32, thickness: 1, color: Color(0xFF333333)),
                              Text(
                                'DESIGNATION',
                                style: boldText.copyWith(color: Colors.white),
                              ),
                              verticalSpaceSmall,
                              Text(
                                strDesignation!,
                                style: normalText.copyWith(color: Colors.white),
                              ),
                              const Divider(height: 32, thickness: 1, color: Color(0xFF333333)),
                              Text(
                                'PROFILE',
                                style: boldText.copyWith(color: Colors.white),
                              ),
                              verticalSpaceSmall,
                              Text(
                                strProfile!,
                                style: normalText.copyWith(color: Colors.white),
                              ),
                              const Divider(height: 32, thickness: 1, color: Color(0xFF333333)),
                              Text(
                                'COMPANY NAME',
                                style: boldText.copyWith(color: Colors.white),
                              ),
                              verticalSpaceSmall,
                              Text(
                                strCompanyName!,
                                style: normalText.copyWith(color: Colors.white),
                              ),
                              const Divider(height: 32, thickness: 1, color: Color(0xFF333333)),
                              Text(
                                'MOBILE NUMBER',
                                style: boldText.copyWith(color: Colors.white),
                              ),
                              verticalSpaceSmall,
                              Text(
                                strMobileNo!,
                                style: normalText.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })
              : const Center(child: CircularProgressIndicator(color: Colors.white))),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Row(
                children: [
                  Expanded(
                    child: _ProfileActionButton(
                      text: 'DELETE ACCOUNT',
                      onTap: () {
                        Alert(
                            closeIcon: const SizedBox(),
                            padding:
                                const EdgeInsets.only(top: 0.0, left: 18, right: 18),
                            image: Image.asset('images/Icon-512.png',
                                height: 80, fit: BoxFit.fitWidth),
                            style: const AlertStyle(
                                titleTextAlign: TextAlign.center,
                                descTextAlign: TextAlign.center,
                                descStyle: TextStyle(
                                    fontWeight: FontWeight.normal, fontSize: 16),
                                isCloseButton: true),
                            context: context,
                            desc:
                                'Are you sure, you want to delete the account?\n(Recommend to delete only after the management\'s approval.)',
                            alertAnimation: fadeAlertAnimation,
                            buttons: [
                              DialogButton(
                                onPressed: () => Navigator.pop(context),
                                color: Colors.black,
                                child: const Text(
                                  "NO",
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ),
                              DialogButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  submitDeleteAccount();
                                },
                                color: Colors.black,
                                child: const Text(
                                  "YES",
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ]).show();
                      },
                    ),
                  ),
                  horizontalSpaceTiny,
                  Expanded(
                    child: _ProfileActionButton(
                      text: 'LOGOUT',
                      onTap: () {
                        Alert(
                            closeIcon: const SizedBox(),
                            padding: const EdgeInsets.only(top: 0.0),
                            image: Image.asset('images/Icon-512.png',
                                height: 80, fit: BoxFit.fitWidth),
                            style: const AlertStyle(
                                titleTextAlign: TextAlign.center,
                                descTextAlign: TextAlign.center,
                                descStyle: TextStyle(
                                    fontWeight: FontWeight.normal, fontSize: 16),
                                isCloseButton: true),
                            context: context,
                            desc: 'Are you sure, you want to logout?',
                            alertAnimation: fadeAlertAnimation,
                            content: Column(
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DialogButton(
                                        onPressed: () => Navigator.pop(context),
                                        color: Colors.black,
                                        child: const Text(
                                          "NO",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: DialogButton(
                                        onPressed: () {
                                          logout();
                                          Navigator.pop(context);
                                        },
                                        color: Colors.black,
                                        child: const Text(
                                          "YES",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                DialogButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    PortalAccessService.performLogoutAllDevices();
                                  },
                                  color: Colors.red,
                                  child: const Text(
                                    "LOGOUT OF ALL DEVICES",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            buttons: []).show();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _ProfileActionButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  __ProfileActionButtonState createState() => __ProfileActionButtonState();
}

class __ProfileActionButtonState extends State<_ProfileActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : Colors.black,
            border: Border.all(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: _isHovered ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
