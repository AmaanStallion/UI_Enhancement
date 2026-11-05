import 'package:flutter/material.dart';
import 'po_action_feedback.dart';

/// Account layouts respond to available space, including narrow desktop windows.
extension AccountLayoutContext on BuildContext {
  bool get accountCompact {
    final size = MediaQuery.sizeOf(this);
    return size.width < 720 || size.shortestSide < 600;
  }

  double accountFont(double desktop, {double? mobile}) {
    if (!accountCompact) {
      return desktop;
    }
    final width = MediaQuery.sizeOf(this).width;
    final size = mobile ?? desktop;
    return size * (width / 390).clamp(0.92, 1.0);
  }
}

/// Preserves the desktop detail layout and gives labels and values bounded
/// space on phones. Values and their actions may wrap onto multiple lines.
class AccountDetailRow extends StatelessWidget {
  const AccountDetailRow(
      {super.key,
      required this.children,
      required this.valueStart,
      this.trailing,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.mainAxisSize = MainAxisSize.max,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.textDirection,
      this.verticalDirection = VerticalDirection.down,
      this.textBaseline});

  final List<Widget> children;
  final int valueStart;
  final Widget? trailing;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  @override
  Widget build(BuildContext context) {
    if (!context.accountCompact) {
      return Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: [...children, if (trailing != null) trailing!]);
    }
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (!width.isFinite || children.isEmpty) {
        return Column(children: children);
      }
      final labelWidth = (width * 0.35).clamp(76.0, 120.0);
      final values = children
          .skip(valueStart)
          .where((child) => child is! Spacer)
          .map((child) => _compact(child, context))
          .toList();
      return Row(
          crossAxisAlignment: trailing == null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: labelWidth,
                child: _compact(children.first, context, label: true)),
            const SizedBox(width: 10),
            Expanded(
                child: trailing != null
                    ? Row(children: [
                        Expanded(
                            child: Wrap(
                                spacing: 6, runSpacing: 6, children: values)),
                        const SizedBox(width: 6),
                        trailing!,
                      ])
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: values)),
          ]);
    });
  }

  Widget _compact(Widget child, BuildContext context, {bool label = false}) {
    if (child is Flexible) {
      return _compact(child.child, context, label: label);
    }
    if (child is SizedBox) {
      if (child.child == null) {
        return SizedBox(
            width: child.width == null ? null : 4, height: child.height);
      }
      return _compact(child.child!, context, label: label);
    }
    if (child is Center) {
      return _compact(child.child ?? const SizedBox.shrink(), context,
          label: label);
    }
    if (child is Padding) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _compact(child.child ?? const SizedBox.shrink(), context,
              label: label));
    }
    if (child is Text) {
      final style = (child.style ?? const TextStyle())
          .copyWith(fontSize: context.accountFont(14, mobile: 13));
      return Text.rich(child.textSpan ?? TextSpan(text: child.data),
          style: style,
          strutStyle: child.strutStyle,
          textAlign: child.textAlign,
          textDirection: child.textDirection,
          locale: child.locale,
          softWrap: true,
          overflow: child.overflow,
          textScaler: child.textScaler,
          maxLines: child.maxLines,
          semanticsLabel: child.semanticsLabel,
          textWidthBasis: child.textWidthBasis,
          textHeightBehavior: child.textHeightBehavior);
    }
    if (child is Row) {
      return Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: child.children
              .where((c) => c is! Spacer)
              .map((c) => _compact(c, context, label: label))
              .toList());
    }
    return child;
  }
}

/// Keeps the two date fields and their actions on a single toolbar row.
class AccountFilterBar extends StatelessWidget {
  const AccountFilterBar(
      {super.key,
      required this.children,
      this.compactLabel,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.mainAxisSize = MainAxisSize.max});
  final List<Widget> children;
  final String? compactLabel;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (!context.accountCompact) {
      return Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: children);
    }
    final controls = children
        .where((child) =>
            child is Flexible ||
            child is ButtonStyleButton ||
            child is PoActionFeedback)
        .toList();
    return LayoutBuilder(builder: (context, constraints) {
      // Very narrow displays can scroll the toolbar instead of clipping controls.
      final minimumWidth = MediaQuery.textScalerOf(context).scale(12) > 16
          ? 380.0
          : compactLabel == null
              ? 300.0
              : 330.0;
      final width = constraints.maxWidth < minimumWidth
          ? minimumWidth
          : constraints.maxWidth;
      return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              width: width,
              child: Row(children: [
                if (compactLabel != null) ...[
                  SizedBox(
                      width: 30,
                      child: Text(compactLabel!,
                          style: TextStyle(
                              fontSize: context.accountFont(13, mobile: 12),
                              color: Colors.black87))),
                  const SizedBox(width: 4),
                ],
                for (var i = 0; i < controls.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                      flex: controls[i] is Flexible ? 3 : 2,
                      child: controls[i] is Flexible
                          ? (controls[i] as Flexible).child
                          : controls[i]),
                ],
              ])));
    });
  }
}

InputDecoration accountDateInputDecoration(BuildContext context, String label) {
  final compact = context.accountCompact;
  final hint = compact ? (label.contains('From') ? 'From' : 'To') : label;
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffe0e0e0)));
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        fontFamily: 'HelveticaNeue',
        color: Colors.black54,
        fontSize: context.accountFont(13, mobile: 12)),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding:
        EdgeInsets.symmetric(horizontal: compact ? 6 : 14, vertical: 12),
    suffixIcon: Icon(Icons.calendar_month_outlined,
        size: compact ? 14 : 20, color: Colors.black54),
    suffixIconConstraints: BoxConstraints(minWidth: compact ? 20 : 40),
    border: border,
    enabledBorder: border,
    disabledBorder: border,
    focusedBorder:
        border.copyWith(borderSide: const BorderSide(color: Colors.black)),
  );
}

/// Content and action groups can flow onto another line on compact displays.
class AccountFlowRow extends StatelessWidget {
  const AccountFlowRow(
      {super.key,
      required this.children,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.mainAxisSize = MainAxisSize.max,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.textDirection,
      this.verticalDirection = VerticalDirection.down,
      this.textBaseline});
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  @override
  Widget build(BuildContext context) {
    if (!context.accountCompact) {
      return Row(
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          children: children);
    }
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width - 24;
      final count = children.whereType<Flexible>().length.clamp(1, 2);
      final itemWidth = (width - 8 * (count - 1)) / count;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: mainAxisAlignment == MainAxisAlignment.center
            ? WrapAlignment.center
            : mainAxisAlignment == MainAxisAlignment.end
                ? WrapAlignment.end
                : WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final child in children)
            if (child is! Spacer && !(child is SizedBox && child.child == null))
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width),
                  child: child is Flexible
                      ? SizedBox(width: itemWidth, child: child.child)
                      : child),
        ],
      );
    });
  }
}

class AccountIntrinsicHeight extends StatelessWidget {
  const AccountIntrinsicHeight({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      context.accountCompact ? child : IntrinsicHeight(child: child);
}
