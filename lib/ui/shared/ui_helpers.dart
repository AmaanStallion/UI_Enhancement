import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Widget horizontalSpaceVeryTiny = SizedBox(width: 3.0);
const Widget horizontalSpaceTiny = SizedBox(width: 5.0);
const Widget horizontalSpaceSmall = SizedBox(width: 10.0);
const Widget horizontalSpaceMedium = SizedBox(width: 25.0);
const Widget horizontalSpaceLarge = SizedBox(width: 35.0);

const Widget verticalSpaceVeryTiny = SizedBox(height: 3.0);
const Widget verticalSpaceTiny = SizedBox(height: 5.0);
const Widget verticalSpaceSmall = SizedBox(height: 10.0);
const Widget verticalSpaceSmall15 = SizedBox(height: 15.0);
const Widget verticalSpaceMedium = SizedBox(height: 25.0);
const Widget verticalSpaceLarge = SizedBox(height: 50.0);
const Widget verticalSpaceMassive = SizedBox(height: 120.0);

// colors
const Color kcPrimaryColor = Color(0xff000000);
const Color kcPrimaryDarkColor = Color(0xff07aba5);
const Color kcSecondaryBlueColor = Color(0xff3c59b0);
const Color kcSecondaryLightBlueColor = Color(0xff5386ed);
const Color kcMediumGreyColor = Color(0xff868686);
const Color kcTextFieldGreyColor = Color(0xffcccbca);
const Color kcOtpBoxColor = Color(0xffFBFBFB);
const Color kcTextFieldColor = Color(0xfff5f5f5);

const TextStyle boldText =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.black);
const TextStyle boldText13 =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0);
const TextStyle normalText = TextStyle(
    fontWeight: FontWeight.normal, fontSize: 16.0, color: Colors.black);
const TextStyle normalText12 =
    TextStyle(fontWeight: FontWeight.normal, fontSize: 13.0);
const TextStyle normalText14GreyColor = TextStyle(
    fontWeight: FontWeight.normal, fontSize: 14.0, color: Colors.grey);
const TextStyle normalTextRedColor =
    TextStyle(fontWeight: FontWeight.normal, fontSize: 15.0, color: Colors.red);
const TextStyle normalTextBlueColor = TextStyle(
    fontWeight: FontWeight.normal, fontSize: 15.0, color: Colors.blueAccent);

var currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  name: "",
  decimalDigits: 2, // change it to get decimal places
  symbol: '₹ ',
);
var currencyFormatWothoutSymbol = NumberFormat.currency(
  locale: 'en_IN',
  name: "",
  decimalDigits: 2, // change it to get decimal places
  symbol: '',
);

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension ExtendedString on String {
  /// The string without any whitespace.
  String removeAllWhitespace() {
    // Remove all white space.
    return this.replaceAll(RegExp(r"\s+"), "");
  }
}

Widget fadeAlertAnimation(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return Align(
    child: FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}
