import 'package:flutter/material.dart';
import 'package:stallion/ui/widgets/app_text.dart';

Widget cardTitleIcon({
  required BuildContext context,
  required String title,
  List<Widget>? listWidget,
}) {
  return Row(
    children: [
      AppText(
        title: title,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        titleColor: Colors.black,
      ),
      ...?listWidget,
    ],
  );
}
