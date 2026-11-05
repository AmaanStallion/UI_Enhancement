import 'package:flutter/material.dart';
import 'account_management_layout.dart';

ThemeData accountManagementTheme(BuildContext context) {
  final theme = Theme.of(context);
  final horizontal = context.accountCompact ? 16.0 : 24.0;
  const capsule = StadiumBorder();
  final textStyle = TextStyle(
      fontFamily: 'HelveticaNeue',
      fontSize: context.accountFont(15, mobile: 13),
      fontWeight: FontWeight.w600);
  return theme.copyWith(
    scaffoldBackgroundColor: const Color(0xfff8f9fa),
    appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textStyle.copyWith(
            color: Colors.white,
            fontSize: context.accountFont(17, mobile: 14))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 46),
            shape: capsule,
            elevation: 2,
            textStyle: textStyle,
            padding:
                EdgeInsets.symmetric(horizontal: horizontal, vertical: 12))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            minimumSize: const Size(0, 46),
            shape: capsule,
            textStyle: textStyle,
            padding:
                EdgeInsets.symmetric(horizontal: horizontal, vertical: 12))),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            minimumSize: const Size(0, 44),
            shape: capsule,
            textStyle: textStyle,
            padding:
                EdgeInsets.symmetric(horizontal: horizontal, vertical: 10))),
    dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        insetPadding: EdgeInsets.symmetric(
            horizontal: context.accountCompact ? 16 : 40, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textStyle.copyWith(
            fontSize: context.accountFont(18, mobile: 16), color: Colors.black),
        contentTextStyle: textStyle.copyWith(
            fontWeight: FontWeight.w400, color: Colors.black87)),
    cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: const Color(0x18000000),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xffe9ecef)))),
    listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
            horizontal: context.accountCompact ? 12 : 20, vertical: 8),
        titleTextStyle: textStyle.copyWith(color: Colors.black87),
        subtitleTextStyle: textStyle.copyWith(
            fontWeight: FontWeight.w400, color: Colors.black54)),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffe0e0e0))),
        hintStyle: textStyle.copyWith(
            color: Colors.black45, fontWeight: FontWeight.w400)),
  );
}

class AccountManagementSurface extends StatelessWidget {
  const AccountManagementSurface({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Theme(data: accountManagementTheme(context), child: child);
}

Future<T?> showAccountDialog<T>(
        {required BuildContext context,
        required WidgetBuilder builder,
        bool barrierDismissible = true,
        Color? barrierColor,
        String? barrierLabel,
        bool useSafeArea = true,
        bool useRootNavigator = true,
        RouteSettings? routeSettings,
        Offset? anchorPoint}) =>
    showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor ?? Colors.black54,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        anchorPoint: anchorPoint,
        builder: (dialogContext) => Theme(
            data: accountManagementTheme(dialogContext),
            child: Builder(builder: builder)));

class AccountActionButton extends StatelessWidget {
  const AccountActionButton(
      {super.key,
      required this.lblText,
      required this.color,
      required this.onTap});
  final String lblText;
  final Color color;
  final Function onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: () => onTap(),
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
          child: Text(lblText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: context.accountFont(16, mobile: 13),
                  fontWeight: FontWeight.w600))));
}

class AccountCard extends StatefulWidget {
  const AccountCard({super.key, required this.child});
  final Widget child;
  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
          margin: EdgeInsets.symmetric(
              horizontal: context.accountCompact ? 12 : 40, vertical: 8),
          transform: Matrix4.translationValues(0, hovered ? -2 : 0, 0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffe9ecef)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0x16000000),
                    blurRadius: hovered ? 16 : 8,
                    offset: Offset(0, hovered ? 7 : 3))
              ]),
          child:
              Material(type: MaterialType.transparency, child: widget.child)));
}
