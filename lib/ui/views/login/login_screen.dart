import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:stallion/models/login_otp_request.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/request_access/request_access.dart';
import 'package:stallion/ui/views/verifyotp/verifyotp_screen.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

import '../cms/cms_details.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void btnBack() {
    setState(() {
      _flagVerifyOtp = false;
    });
  }

  NetworkHandler apiNetworkHandler = NetworkHandler();

  final _formKey = GlobalKey<FormState>();
  String _fullname = '';
  String _mobilenumber = '';
  String? _requestId;
  String? _userType;
  late BuildContext? dialogContext;

  late FocusNode txtFullname;
  late FocusNode txtMobilenumber;

  bool _flagVerifyOtp = false;
  bool _isLoading = false;
  String _fullnameVal = '';
  String _mobilenumberVal = '';

  void _validateAndSave() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      if (kDebugMode) {
        print('Form is valid');
      }
      _formKey.currentState!.save();

      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });
      CustomLoading.progressDialog(isLoading: true, context: context, skeletonType: CustomLoading.skeletonVerifyOtp, isDark: true);

      if (AppUrl.useNewBackend) {
        Map<String, String> data = {
          "mobile_number": _mobilenumber,
        };
        var response = await apiNetworkHandler.post1(AppUrl.sendOtpUrl, data);
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData["success"] == true) {
            CustomLoading.progressDialog(isLoading: false, context: context);
            setState(() {
              _flagVerifyOtp = true;
            });
          } else {
            CustomLoading.progressDialog(isLoading: false, context: context);
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
                desc: responseData["message"] ?? "Failed to send OTP",
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
          }
        } else {
          CustomLoading.progressDialog(isLoading: false, context: context);
          String alertMessage = "Failed to send OTP. Please try again later.";
          try {
            final Map<String, dynamic> responseData = json.decode(response.body);
            if (responseData["message"] != null) {
              alertMessage = responseData["message"];
            }
          } catch (_) {}

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
              desc: alertMessage,
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
        }
        return;
      }

      Map<String, String> data = {
        "nick_name": _fullname,
        "mobile_no": _mobilenumber,
        "company_name": ""
      };

      if (kDebugMode) {
        print(data);
      }
      var response = await apiNetworkHandler.post(AppUrl.loginOtpRequest, data);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginModel = loginModelFromJson(response.body);
        if (loginModel.response?.errorCode == "0") {
          CustomLoading.progressDialog(isLoading: false, context: context);
          _requestId = loginModel.response?.requestId;
          _userType = loginModel.response?.userType;
          setState(() {
            _flagVerifyOtp = true;
          });
        } else if (loginModel.response?.errorCode == "1") {
          CustomLoading.progressDialog(isLoading: false, context: context);
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
        }
      } else {
        context.loaderOverlay.hide();
        CustomLoading.progressDialog(isLoading: false, context: context);
        if (kDebugMode) {
          print('Failed');
          print(response.statusCode);
          print(response.body);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    txtFullname = FocusNode();
    txtMobilenumber = FocusNode();
  }

  @override
  void dispose() {
    txtFullname.dispose();
    txtMobilenumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flagVerifyOtp == true) {
      return VerifyOtpScreen(
        callback: btnBack,
        nickName: _fullname,
        phoneNumber: _mobilenumber,
        requestId: _requestId,
        userType: _userType,
        newLoginResponse: null,
      );
    }

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
                  // Logo: Changed height and width to 160
                  Center(
                    child: Image(
                      image: const AssetImage('images/Icon-512.png'),
                      width: 160,
                      height: 160,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Welcome Section
                  const Text(
                    'Sign in to continue with Stallion',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'HelveticaNeue',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Form Inputs
                  Form(
                    key: _formKey,
                    child: Column(
                      children: AppUrl.useNewBackend
                          ? [
                              ModernTextField(
                                labelText: 'Name',
                                hintText: 'Enter name',
                                prefixIcon: Icons.person_outline,
                                focusNode: txtFullname,
                                nextFocusNode: txtMobilenumber,
                                onChanged: (value) =>
                                    setState(() => _fullnameVal = value),
                                onSaved: (value) =>
                                    setState(() => _fullname = value ?? ''),
                              ),
                              const SizedBox(height: 16),
                              ModernTextField(
                                labelText: 'Mobile Number',
                                hintText: 'Mobile Number',
                                prefixIcon: Icons.phone_outlined,
                                focusNode: txtMobilenumber,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 10,
                                prefixWidget: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.phone_outlined,
                                      color: txtMobilenumber.hasFocus ? Colors.white : const Color(0xff888888),
                                      size: 20.0,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      '+91',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 1.0,
                                      height: 18.0,
                                      color: const Color(0xff333333),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                                validator: (value) {
                                  if (value == null) return 'Mobile Number should not be empty';
                                  String num = value.replaceAll('+91 - ', '').trim();
                                  return validateMobile(num);
                                },
                                onChanged: (value) =>
                                    setState(() => _mobilenumberVal = value),
                                onSaved: (value) {
                                  if (value != null) {
                                    _mobilenumber = value.replaceAll("+91 - ", '').trim();
                                  }
                                },
                              ),
                            ]
                          : [
                              ModernTextField(
                                labelText: 'Name',
                                hintText: 'Enter name',
                                prefixIcon: Icons.person_outline,
                                focusNode: txtFullname,
                                nextFocusNode: txtMobilenumber,
                                validator: (value) =>
                                    value == null || value.isEmpty ? "Name can't be empty" : null,
                                onChanged: (value) =>
                                    setState(() => _fullnameVal = value),
                                onSaved: (value) =>
                                    setState(() => _fullname = value ?? ''),
                              ),
                              const SizedBox(height: 16),
                              ModernTextField(
                                labelText: 'Mobile Number',
                                hintText: 'Mobile Number',
                                prefixIcon: Icons.phone_outlined,
                                focusNode: txtMobilenumber,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 10,
                                prefixWidget: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.phone_outlined,
                                      color: txtMobilenumber.hasFocus ? Colors.white : const Color(0xff888888),
                                      size: 20.0,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      '+91',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 1.0,
                                      height: 18.0,
                                      color: const Color(0xff333333),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                                validator: (value) {
                                  if (value == null) return 'Mobile Number should not be empty';
                                  String num = value.replaceAll('+91 - ', '');
                                  return validateMobile(num);
                                },
                                onChanged: (value) =>
                                    setState(() => _mobilenumberVal = value),
                                onSaved: (value) {
                                  if (value != null) {
                                    _mobilenumber = value.replaceAll("+91 - ", '');
                                  }
                                },
                              ),
                            ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sign In Button
                  ModernPrimaryButton(
                    text: 'Sign In',
                    isLoading: _isLoading,
                    isFilled: _fullnameVal.trim().isNotEmpty && _mobilenumberVal.trim().length >= 10,
                    onTap: _validateAndSave,
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[800], thickness: 1)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffaaaaaa),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[800], thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Developer Section
                  Column(
                    children: [
                      const Text(
                        'New to Stallion?',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xffaaaaaa),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ModernSecondaryButton(
                        text: 'Register as a Developer',
                        onTap: goToUrl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Terms & Conditions at the bottom
                  _buildTermsAndConditions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12.0,
            color: Color(0xff999999),
            height: 1.5,
            fontFamily: 'HelveticaNeue',
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms & Conditions',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CmsPageHtml(
                        cmsId: '4',
                        navigationFlag: "Home",
                      ),
                    ),
                  );
                },
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CmsPageHtml(
                        cmsId: '3',
                        navigationFlag: 'Home',
                      ),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  void goToUrl() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RequestAccessForm(),
      ),
    );
  }

  String? validateMobile(String value) {
    if (value.isEmpty) {
      return 'Mobile Number should not be empty';
    } else if (value.length != 10) {
      return 'Mobile Number must be of 10 digit';
    } else {
      return null;
    }
  }
}

// Custom Modern Form Inputs with Focus/Hover transitions
class ModernTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? prefixWidget;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final String? initialValue;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const ModernTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.prefixWidget,
    required this.focusNode,
    this.nextFocusNode,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.obscureText = false,
    this.inputFormatters,
    this.maxLength,
  }) : super(key: key);

  @override
  _ModernTextFieldState createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _isFocused = false;
  bool _isHovered = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.text,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: _isFocused
                  ? Colors.white
                  : (_isHovered ? Colors.white54 : const Color(0xff333333)),
              width: _isFocused ? 1.8 : 1.0,
            ),
          ),
        ),
        child: TextFormField(
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          validator: widget.validator,
          onSaved: widget.onSaved,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.white,
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.white,
          textInputAction: widget.nextFocusNode != null
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (widget.nextFocusNode != null) {
              FocusScope.of(context).requestFocus(widget.nextFocusNode);
            } else {
              _focusNode.unfocus();
            }
          },
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
              color: _isFocused ? Colors.white : const Color(0xff666666),
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color(0xff666666),
              fontSize: 14.0,
            ),
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 9.0,
              horizontal: 4.0,
            ),
            prefixIcon: widget.prefixWidget ??
                Icon(
                  widget.prefixIcon,
                  color: _isFocused ? Colors.white : const Color(0xff888888),
                  size: 20.0,
                ),
            counterText: "",
          ),
        ),
      ),
    );
  }
}

// Modern Primary Button with Hover & Press effect
class ModernPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isFilled;

  const ModernPrimaryButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isFilled = false,
  }) : super(key: key);

  @override
  _ModernPrimaryButtonState createState() => _ModernPrimaryButtonState();
}

class _ModernPrimaryButtonState extends State<ModernPrimaryButton> {
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
            onTap: widget.isLoading ? null : widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(24.0),
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
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: textColor,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
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

// Modern Secondary (Outlined) Button with Hover & Press effect
class ModernSecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const ModernSecondaryButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  _ModernSecondaryButtonState createState() => _ModernSecondaryButtonState();
}

class _ModernSecondaryButtonState extends State<ModernSecondaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 1024;
    final Color buttonColor = isDesktop
        ? (_isHovered ? Colors.white : Colors.black)
        : Colors.black;
    final Color textColor = isDesktop
        ? (_isHovered ? Colors.black : Colors.white)
        : Colors.white;

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
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(24.0),
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
