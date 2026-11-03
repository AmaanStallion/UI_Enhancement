import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class RequestAccessForm extends StatefulWidget {
  const RequestAccessForm({super.key});

  @override
  State<RequestAccessForm> createState() => _RequestAccessFormState();
}

class _RequestAccessFormState extends State<RequestAccessForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCompanySize;
  
  final Map<String, String> _companySizeOptions = {
    '1-11': '1',
    '12-50': '2',
    '51-200': '3',
    '200+': '4',
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _companySizeController = TextEditingController();
  final TextEditingController _completedProjectsController = TextEditingController();
  final TextEditingController _ongoingProjectsController = TextEditingController();
  String? _selectedCompanySizeValue;
  Set<String> _selectedFeatureKeys = {};

  String? _selectedFeature;
  final Map<String, String> _featuresMap = {
    'Generate Work Orders': '9',
    'Generate Purchase Orders': '8',
    'Manage Sales Inventory': '10',
    'Order Tracking Management': '13',
    'Inventory Management': '11',
    'Accounting & Invoicing': '12',
    'Project Analysis Management': '14',
  };
  
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final NetworkHandler apiNetworkHandler = NetworkHandler();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companySizeController.dispose();
    _completedProjectsController.dispose();
    _ongoingProjectsController.dispose();
    super.dispose();
  }

  Future<dynamic?> submitCreate() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    final SharedPreferences prefs = await _prefs;

    String selectedFeatureValuesString =
        _selectedFeatureKeys.map((key) => _featuresMap[key]!).join(',');

    if (kDebugMode) {
      print('Selected Feature Values: $selectedFeatureValuesString');
    }

    Map<String, String> data = {
      "mobile_no": _mobileController.text,
      "email": _emailController.text,
      "company_name": _companyNameController.text,
      'company_address': _companyAddressController.text,
      "company_size": _selectedCompanySizeValue ?? '',
      "completed_projects": _completedProjectsController.text,
      "ongoing_projects": _ongoingProjectsController.text,
      "features_nterested": selectedFeatureValuesString,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.newDeveloperAccess, data);
    
    if (!mounted) return null;

    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomLoading.progressDialog(isLoading: false, context: context);

      showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              actionsPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "You have successfully registered.",
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                SizedBox(
                  width: 250,
                  child: ModernDialogButton(
                    text: 'Okay',
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          });
    } else {
      CustomLoading.progressDialog(isLoading: false, context: context);
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;
    final double horizontalPadding = context.isMobile ? 24.0 : 40.0;

    Widget scaffoldContent = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xfff0f0f0),
            height: 1.0,
          ),
        ),
        title: const Text(
          'Register as a Developer',
          style: TextStyle(
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20.0),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xfff0f0f0), width: 1.0),
          ),
        ),
        child: SafeArea(
          child: ModernPrimaryButton(
            text: 'REQUEST ACCESS',
            onTap: () {
              List<String> selectedFeatureValues =
                  _selectedFeatureKeys.map((key) => _featuresMap[key]!).toList();

              if (kDebugMode) {
                print('Selected Feature Values: $selectedFeatureValues');
              }
              
              if (_formKey.currentState!.validate()) {
                CustomLoading.progressDialog(isLoading: true, context: context);

                Future.delayed(const Duration(seconds: 1), () {
                  if (!mounted) return;
                  CustomLoading.progressDialog(isLoading: false, context: context);

                  showDialog<void>(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 36, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(
                              bottom: 24, left: 16, right: 16),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: const Text(
                            "Thank You!\nYou will be notified in the next 48 hrs on your contact information.",
                            style: TextStyle(
                              fontFamily: 'HelveticaNeue',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            SizedBox(
                              width: 250,
                              child: ModernDialogButton(
                                text: 'Okay',
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        );
                      });
                });
              }
            },
          ),
        ),
      ),
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section title
                  const Text(
                    'Developer Registration',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'HelveticaNeue',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fill in the form to request access to stallion dashboard.',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff666666),
                      fontFamily: 'HelveticaNeue',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fields
                  ModernTextField(
                    labelText: 'Full Name',
                    hintText: "What's your name?",
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter Full Name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  ModernTextField(
                    labelText: 'Mobile Number',
                    hintText: "What's your mobile number?",
                    prefixIcon: Icons.phone_outlined,
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    prefixWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.phone_outlined,
                          color: _mobileController.text.isNotEmpty ? Colors.black : const Color(0xff888888),
                          size: 20.0,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1.0,
                          height: 18.0,
                          color: const Color(0xffe0e0e0),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  ModernTextField(
                    labelText: 'Email Address',
                    hintText: "What's your email address?",
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  ModernTextField(
                    labelText: 'Company Name',
                    hintText: "What's your company name?",
                    prefixIcon: Icons.business_outlined,
                    controller: _companyNameController,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 14),

                  ModernTextField(
                    labelText: 'Company Address',
                    hintText: "What's your company address?",
                    prefixIcon: Icons.location_on_outlined,
                    controller: _companyAddressController,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 14),

                  ModernTextField(
                    labelText: 'Completed Projects',
                    hintText: "Number of completed Projects?",
                    prefixIcon: Icons.assignment_turned_in_outlined,
                    controller: _completedProjectsController,
                    keyboardType: TextInputType.number,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 14),

                  ModernTextField(
                    labelText: 'Ongoing Projects',
                    hintText: "Number of ongoing Projects?",
                    prefixIcon: Icons.play_circle_outline,
                    controller: _ongoingProjectsController,
                    keyboardType: TextInputType.number,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 24),

                  // Company Size checkboxes
                  const Text(
                    'Company Size',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'HelveticaNeue',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f9fa),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: const Color(0xffe0e0e0)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Column(
                      children: [
                        for (int i = 0; i < _companySizeOptions.length; i += 2)
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text(
                                    _companySizeOptions.keys.elementAt(i),
                                    style: const TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  value: _selectedCompanySizeValue ==
                                      _companySizeOptions.values.elementAt(i),
                                  activeColor: Colors.black,
                                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      _selectedCompanySizeValue =
                                          selected == true
                                              ? _companySizeOptions.values
                                                  .elementAt(i)
                                              : null;
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                              ),
                              if (i + 1 < _companySizeOptions.length)
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text(
                                      _companySizeOptions.keys.elementAt(i + 1),
                                      style: const TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    value: _selectedCompanySizeValue ==
                                        _companySizeOptions.values
                                            .elementAt(i + 1),
                                    activeColor: Colors.black,
                                    checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        _selectedCompanySizeValue =
                                            selected == true
                                                ? _companySizeOptions.values
                                                    .elementAt(i + 1)
                                                : null;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features checkboxes
                  const Text(
                    'Features Interested In',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'HelveticaNeue',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f9fa),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: const Color(0xffe0e0e0)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Column(
                      children: [
                        for (int i = 0; i < _featuresMap.length; i += 2)
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text(
                                    _featuresMap.keys.elementAt(i),
                                    style: const TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  value: _selectedFeatureKeys.contains(
                                      _featuresMap.keys.elementAt(i)),
                                  activeColor: Colors.black,
                                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      final label =
                                          _featuresMap.keys.elementAt(i);
                                      if (selected == true) {
                                        _selectedFeatureKeys.add(label);
                                      } else {
                                        _selectedFeatureKeys.remove(label);
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                              ),
                              if (i + 1 < _featuresMap.length)
                                Expanded(
                                  child: CheckboxListTile(
                                    title: Text(
                                      _featuresMap.keys.elementAt(i + 1),
                                      style: const TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    value: _selectedFeatureKeys.contains(
                                        _featuresMap.keys.elementAt(i + 1)),
                                    activeColor: Colors.black,
                                    checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        final label = _featuresMap.keys
                                            .elementAt(i + 1);
                                        if (selected == true) {
                                          _selectedFeatureKeys.add(label);
                                        } else {
                                          _selectedFeatureKeys.remove(label);
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Material(
        color: const Color(0xfff7f7f7),
        child: Center(
          child: Container(
            width: 680,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
              border: const Border(
                left: BorderSide(color: Color(0xffe0e0e0), width: 1.0),
                right: BorderSide(color: Color(0xffe0e0e0), width: 1.0),
              ),
            ),
            child: scaffoldContent,
          ),
        ),
      );
    }

    return scaffoldContent;
  }
}

// Modern TextField matching LoginScreen
class ModernTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? prefixWidget;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextInputType keyboardType;
  final String? initialValue;
  final bool obscureText;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;

  const ModernTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.prefixWidget,
    this.focusNode,
    this.validator,
    this.onSaved,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.obscureText = false,
    this.controller,
    this.inputFormatters,
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
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // Only dispose if we created it locally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
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
          color: _isFocused
              ? Colors.white
              : (_isHovered ? const Color(0xfffafafa) : const Color(0xfff8f9fa)),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: _isFocused
                ? Colors.black
                : (_isHovered ? Colors.black38 : const Color(0xffe0e0e0)),
            width: _isFocused ? 1.8 : 1.0,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          validator: widget.validator,
          onSaved: widget.onSaved,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.black,
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.black,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
              color: _isFocused ? Colors.black : const Color(0xff777777),
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color(0xffbbbbbb),
              fontSize: 14.0,
            ),
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 9.0,
              horizontal: 20.0,
            ),
            prefixIcon: widget.prefixWidget ??
                Icon(
                  widget.prefixIcon,
                  color: _isFocused ? Colors.black : const Color(0xff888888),
                  size: 20.0,
                ),
          ),
        ),
      ),
    );
  }
}

// Modern Primary Button matching LoginScreen
class ModernPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const ModernPrimaryButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _ModernPrimaryButtonState createState() => _ModernPrimaryButtonState();
}

class _ModernPrimaryButtonState extends State<ModernPrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
              color: _isHovered ? const Color(0xff222222) : Colors.black,
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [],
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Dialog Button (custom modern styled button for popups)
class ModernDialogButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const ModernDialogButton({Key? key, required this.text, required this.onTap}) : super(key: key);

  @override
  _ModernDialogButtonState createState() => _ModernDialogButtonState();
}

class _ModernDialogButtonState extends State<ModernDialogButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xff222222) : Colors.black,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
