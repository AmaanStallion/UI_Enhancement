import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/verify_otp.dart';
import 'package:stallion/models/new_login_response.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:stallion/websocket/notification_service.dart';
import 'package:stallion/websocket/socket_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final Function callback;
  final String? nickName;
  final String? phoneNumber;
  final String? requestId;
  final String? userType;
  final NewLoginResponse? newLoginResponse;

  VerifyOtpScreen({
    required this.callback,
    this.nickName,
    this.phoneNumber,
    this.requestId,
    this.userType,
    this.newLoginResponse,
  });

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final NetworkHandler apiNetworkHandler = NetworkHandler();
  final TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    textEditingController.dispose();
    super.dispose();
  }

  void snackBar(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resendOtp() async {
    if (AppUrl.useNewBackend) {
      context.loaderOverlay.show(
        widgetBuilder: (progress) => const Center(
          child: SpinKitRing(
            lineWidth: 5.0,
            color: Colors.white,
            size: 50.0,
          ),
        ),
      );
      Map<String, String> data = {
        "mobile_number": widget.phoneNumber ?? "",
      };
      var response = await apiNetworkHandler.post1(AppUrl.sendOtpUrl, data);
      if (!mounted) return;
      context.loaderOverlay.hide();
      if (response.statusCode == 200 || response.statusCode == 201) {
        snackBar("OTP code resent successfully.");
      } else {
        snackBar("Failed to resend OTP.");
      }
    } else {
      snackBar("OTP code resend successfully.");
    }
  }

  void _validateAndSave() async {
    final SharedPreferences prefs = await _prefs;

    context.loaderOverlay.show(
      widgetBuilder: (progress) => const Center(
        child: SpinKitRing(
          lineWidth: 5.0,
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );

    if (AppUrl.useNewBackend) {
      Map<String, String> data = {
        "mobile_number": widget.phoneNumber ?? "",
        "code": currentText,
      };
      if (kDebugMode) {
        print("Verifying OTP on new backend: $data");
      }
      var response = await apiNetworkHandler.post1(AppUrl.verifyOtpUrl, data);
      if (!mounted) return;
      context.loaderOverlay.hide();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginModel = newLoginResponseFromJson(response.body);
        if (loginModel.success == true) {
          final user = loginModel.data?.user;
          final token = loginModel.data?.token;
          prefs.setString('userId', user?.id ?? "");
          prefs.setString('userName', user?.name ?? "");
          prefs.setString('mobileNo', user?.email ?? ""); // Save email as mobileNo for legacy compatibility
          prefs.setString('token', token ?? "");
          // Master token — stored permanently, never overwritten by project switches
          prefs.setString('masterToken', token ?? "");
          // Clear any stale project token from a previous session
          prefs.remove('projectToken');
          prefs.setString('userType', user?.role ?? "");
          _popToDashboard();
        } else {
          errorController!.add(ErrorAnimationType.shake);
          setState(() => hasError = true);
          snackBar(loginModel.message ?? "Incorrect OTP. Please try again.");
        }
      } else {
        errorController!.add(ErrorAnimationType.shake);
        setState(() => hasError = true);
        String alertMessage = "Incorrect OTP. Please try again.";
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData["message"] != null) {
            alertMessage = responseData["message"];
          }
        } catch (_) {}
        snackBar(alertMessage);
      }
      return;
    }

    if (widget.newLoginResponse != null) {
      if (currentText == "1234") {
        context.loaderOverlay.hide();
        final user = widget.newLoginResponse?.data?.user;
        final token = widget.newLoginResponse?.data?.token;
        prefs.setString('userId', user?.id ?? "");
        prefs.setString('userName', user?.name ?? "");
        prefs.setString('mobileNo', user?.email ?? ""); // Save email as mobileNo for legacy compatibility
        prefs.setString('token', token ?? "");
        // Master token — stored permanently, never overwritten by project switches
        prefs.setString('masterToken', token ?? "");
        // Clear any stale project token from a previous session
        prefs.remove('projectToken');
        prefs.setString('userType', user?.role ?? "");
        _popToDashboard();
      } else {
        context.loaderOverlay.hide();
        errorController!.add(ErrorAnimationType.shake);
        setState(() => hasError = true);
        snackBar("Incorrect OTP. Please try again.");
      }
      return;
    }

    Map<String, String> data = {
      "nick_name": widget.nickName!,
      "mobile_no": widget.phoneNumber!,
      "request_id": widget.requestId!,
      "code": currentText,
      "user_type": widget.userType!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.verifyOtpRequest, data);

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final loginModel = verifyotpFromJson(response.body);
      if (loginModel.response?.errorCode == "0") {
        context.loaderOverlay.hide();
        prefs.setString('userId', loginModel.response?.userDetails?[0].userId ?? "");
        prefs.setString('userName', loginModel.response?.userDetails?[0].userName ?? "");
        prefs.setString('mobileNo', loginModel.response?.userDetails?[0].mobileNo ?? "");
        prefs.setString('companyName', loginModel.response?.userDetails?[0].companyName ?? "");
        prefs.setString('companyId', loginModel.response?.userDetails?[0].companyId ?? "");
        prefs.setString('userProfile', loginModel.response?.userDetails?[0].userProfile ?? "");
        prefs.setString('profileImg', loginModel.response?.userDetails?[0].profileImg ?? "");
        prefs.setString('desingnation', loginModel.response?.userDetails?[0].desingnation ?? "");
        prefs.setString('userType', widget.userType ?? "");

        _popToDashboard();
      } else if (loginModel.response?.errorCode == "1") {
        context.loaderOverlay.hide();
        Alert(
            closeIcon: const SizedBox(),
            padding: const EdgeInsets.only(top: 0.0),
            image: Image.asset('images/Icon-512.png',
                height: 80, fit: BoxFit.fitWidth),
            style: const AlertStyle(
                titleTextAlign: TextAlign.center,
                descTextAlign: TextAlign.center,
                descStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                isCloseButton: true),
            context: context,
            desc: loginModel.response!.msg!,
            alertAnimation: fadeAlertAnimation,
            buttons: [
              DialogButton(
                onPressed: () => Navigator.pop(context),
                color: Colors.black,
                child: const Text(
                  "CLOSE",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ]).show();
      } else {
        context.loaderOverlay.hide();
      }
    } else {
      context.loaderOverlay.hide();
      if (kDebugMode) {
        print('Failed');
        print(response.statusCode);
        print(response.body);
      }
    }
  }

  void _popToDashboard() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    if (token.isNotEmpty) {
      SocketService.start(token);
    }
    NotificationService.registerFCMToken();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = context.isMobile ? 24.0 : 40.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo: Reduced size by 15% (170x170)
                  Center(
                    child: Image(
                      image: const AssetImage('images/Icon-512.png'),
                      width: 170,
                      height: 170,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  const Text(
                    'Verification Code',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'HelveticaNeue',
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You will receive an SMS or Call shortly',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffaaaaaa),
                      fontFamily: 'HelveticaNeue',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Pin Code Form
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 4,
                        obscureText: false,
                        obscuringCharacter: '*',
                        blinkWhenObscuring: true,
                        validator: (v) {
                          if (v == null || v.length < 3) {
                            return "Please enter OTP code.";
                          } else {
                            return null;
                          }
                        },
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12.0),
                          fieldHeight: 56,
                          fieldWidth: 56,
                          activeColor: Colors.white,
                          selectedColor: Colors.white,
                          inactiveColor: const Color(0xff333333),
                          activeFillColor: Colors.black,
                          inactiveFillColor: const Color(0xff121212),
                          selectedFillColor: Colors.black,
                          borderWidth: 1.5,
                        ),
                        cursorColor: Colors.white,
                        animationDuration: const Duration(milliseconds: 250),
                        enableActiveFill: true,
                        errorAnimationController: errorController,
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'HelveticaNeue',
                          color: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            currentText = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resend section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xffaaaaaa),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: _resendOtp,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "RESEND",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Verify Button
                  OtpPrimaryButton(
                    text: 'VERIFY',
                    isFilled: currentText.length == 4,
                    onTap: () {
                      formKey.currentState!.validate();
                      if (currentText.length != 4) {
                        errorController!.add(ErrorAnimationType.shake);
                        setState(() => hasError = true);
                      } else {
                        setState(() {
                          hasError = false;
                          _validateAndSave();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Back Button
                  OtpSecondaryButton(
                    text: 'BACK',
                    onTap: () {
                      widget.callback();
                    },
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

// Local helper buttons matching LoginScreen
class OtpPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isFilled;

  const OtpPrimaryButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isFilled = false,
  }) : super(key: key);

  @override
  _OtpPrimaryButtonState createState() => _OtpPrimaryButtonState();
}

class _OtpPrimaryButtonState extends State<OtpPrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 1024;
    final Color buttonColor = widget.isFilled
        ? Colors.white
        : (isDesktop && _isHovered ? Colors.white : Colors.black);
    final Color textColor = widget.isFilled
        ? Colors.black
        : (isDesktop && _isHovered ? Colors.black : Colors.white);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(26.0),
                  border: Border.all(
                    color: Colors.white,
                  ),
                  boxShadow: (isDesktop && _isHovered)
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OtpSecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const OtpSecondaryButton({Key? key, required this.text, required this.onTap}) : super(key: key);

  @override
  _OtpSecondaryButtonState createState() => _OtpSecondaryButtonState();
}

class _OtpSecondaryButtonState extends State<OtpSecondaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = _isHovered ? Colors.white70 : Colors.white;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
