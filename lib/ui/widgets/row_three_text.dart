import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/utils/responsive.dart';

Widget rowThreeText({
  required BuildContext context,
  required String title,
  required String titleValue,
  double? titleWidth,
  String? buttonText,
  IconData? buttonIcon,
  VoidCallback? onTapButton,
  String? titleSubValue = "",
  String? subTitleValue,
  Color? titleValueColor = Colors.black,
  Color? titleSubValueColor = Colors.black,
  bool isActionButtonBlack = false,
}) {
  final isMobile = context.isMobile;
  final fontSize = isMobile ? 13.0 : 15.0;
  final effectiveTitleWidth = titleWidth ?? (isMobile ? 85.0 : 130.0);
  return Container(
    padding: EdgeInsets.only(top: isMobile ? 4 : 8, left: isMobile ? 8 : 22),
    child: Row(
      children: [
        SizedBox(
          width: effectiveTitleWidth,
          child: Text(
            title,
            style: TextStyle(fontSize: fontSize, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 4),
        Center(child: Icon(Icons.remove, size: isMobile ? 12 : 16, color: Colors.black54)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            titleValue,
            style: TextStyle(
              fontSize: fontSize,
              color: titleValueColor ?? Colors.black,
            ),
          ),
        ),
        if (titleSubValue != null && titleSubValue.isNotEmpty)
          Text(
            titleSubValue,
            style: TextStyle(
              fontSize: fontSize,
              color: titleSubValueColor ?? Colors.black,
            ),
          ),
        if (buttonIcon != null)
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            onPressed: onTapButton,
            icon: Icon(
              buttonIcon,
              size: isMobile ? 16 : 18,
              color: Colors.black87,
            ),
          )
        else if (buttonText?.isNotEmpty ?? false)
          OutlinedButton(
            onPressed: onTapButton,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 16, vertical: isMobile ? 4 : 9),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor:
                  isActionButtonBlack ? Colors.black : Colors.white,
              side: const BorderSide(
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(buttonText ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 11.5 : 13.5,
                  color: isActionButtonBlack ? Colors.white : Colors.black,
                )),
          ),
        if (subTitleValue != null && subTitleValue.isNotEmpty)
          Text(
            subTitleValue,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey,
            ),
          ),
      ],
    ),
  );
}
