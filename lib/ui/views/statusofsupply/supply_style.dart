import 'package:flutter/material.dart';
import '../accountmanagement/account_management_style.dart';

const supplyBackground = Color(0xfff8f9fa);
const supplyFontFamily = 'HelveticaNeue';

ThemeData supplyTheme(BuildContext context) {
  final theme = accountManagementTheme(context);
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: supplyFontFamily),
    primaryTextTheme:
        theme.primaryTextTheme.apply(fontFamily: supplyFontFamily),
  );
}

Widget supplyPickerTheme(BuildContext context, Widget? child) =>
    Theme(data: supplyTheme(context), child: child ?? const SizedBox());
bool supplyCompact(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 720;

/// Responsive form columns; action rows retain their children and alignment.
class SupplyFormRow extends StatelessWidget {
  const SupplyFormRow(
      {super.key,
      required this.children,
      this.verified = false,
      this.inputFlex = 1,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.mainAxisSize = MainAxisSize.max});
  final List<Widget> children;
  final bool verified;
  final int inputFlex;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final compact = supplyCompact(context);
    if (verified && children.isNotEmpty && children.first is SizedBox) {
      final label = children.first as SizedBox;
      Widget? text = label.child;
      if (text is Padding) text = text.child;
      if (text is Text && label.width == 230 && children.length >= 3) {
        final title = SizedBox(
          height:
              MediaQuery.textScalerOf(context).scale(compact ? 14 : 15) * 1.5 +
                  14,
          child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('${text.data ?? ''} -',
                    maxLines: 1,
                    style: TextStyle(
                        fontFamily: supplyFontFamily,
                        fontSize: compact ? 12 : 14,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              )),
        );
        final values = children.skip(2).toList();
        if (!compact) {
          return Row(
              key: ValueKey('supply-progress-${text.data}'),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 110, child: title),
                const SizedBox(width: 8),
                ...values
              ]);
        }
        return Row(
            key: ValueKey('supply-progress-${text.data}'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 88, child: title),
              const SizedBox(width: 8),
              Expanded(
                  child: Row(children: [
                Expanded(flex: inputFlex, child: _unwrap(values.first)),
                for (final value in values.skip(1))
                  if (value is Text || value is Center)
                    Flexible(child: value)
                  else
                    _gap(value),
              ])),
            ]);
      }
    }
    if (children.length == 2 &&
        children.first is Column &&
        children.last is Icon) {
      return Row(crossAxisAlignment: crossAxisAlignment, children: [
        Expanded(child: children.first),
        const SizedBox(width: 8),
        children.last,
      ]);
    }
    if (compact && children.isNotEmpty) {
      final first = children.first;
      if (first is SizedBox && first.width == 230 && children.length >= 3) {
        final values = children.skip(2).toList();
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: 88, child: first.child),
          const SizedBox(width: 8),
          Expanded(
              child: Row(children: [
            Expanded(child: _unwrap(values.first)),
            for (final value in values.skip(1))
              if (value is Text || value is Center)
                Flexible(child: value)
              else
                _gap(value),
          ])),
        ]);
      }
      // Summary columns, quantity columns, and the order-details table.
      final columns =
          children.where((w) => w is! SizedBox || w.child != null).toList();
      if (columns.length == 2 &&
          columns.first is Column &&
          columns.last is Icon) {
        return Row(crossAxisAlignment: crossAxisAlignment, children: [
          Expanded(child: columns.first),
          const SizedBox(width: 8),
          columns.last,
        ]);
      }
      final isColumns = columns.isNotEmpty &&
          (columns.every((w) => w is Column) ||
              columns.every(
                  (w) => w is Container && w.constraints?.maxWidth == 120) ||
              (columns.length == 3 &&
                  columns.take(2).every((w) => w is SizedBox)));
      if (isColumns) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final column in columns)
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: column)),
        ]);
      }
    }
    return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: compact ? children.map(_gap).toList() : children);
  }

  Widget _unwrap(Widget widget) => widget is Flexible ? widget.child : widget;
  Widget _gap(Widget widget) =>
      widget is SizedBox && widget.child == null && widget.width != null
          ? SizedBox(
              width: widget.width! > 8 ? 8 : widget.width,
              height: widget.height)
          : widget;
}

/// Keeps each action on its original row while bounding detail text on phones.
class SupplyDetailRow extends StatelessWidget {
  const SupplyDetailRow(
      {super.key,
      required this.children,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.mainAxisSize = MainAxisSize.max});
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (!supplyCompact(context) || children.isEmpty) {
      return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: children);
    }
    // The PO status row has its action outside the nested detail row.
    if (children.first is SupplyDetailRow) {
      return Row(children: [
        Expanded(child: children.first),
        const SizedBox(width: 8),
        ...children.skip(1)
      ]);
    }
    final label = children.first;
    if (label is! SizedBox || label.width != 200 || children.length < 5) {
      return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: children);
    }
    final values = children.skip(4).toList();
    return LayoutBuilder(
        builder: (context, constraints) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: (constraints.maxWidth * .36).clamp(62.0, 105.0),
                    child: _compact(label.child ?? const SizedBox())),
                const SizedBox(width: 8),
                Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: _compact(values.first))),
                      for (final value in values.skip(1))
                        if (value is Text)
                          Flexible(child: _compact(value))
                        else
                          _compact(value),
                    ])),
              ],
            ));
  }

  Widget _compact(Widget widget) {
    if (widget is Flexible) return _compact(widget.child);
    if (widget is Text) {
      return Text(widget.data ?? '',
          style: widget.style?.copyWith(fontSize: 13),
          textAlign: widget.textAlign,
          softWrap: true);
    }
    if (widget is Padding) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: _compact(widget.child ?? const SizedBox()));
    }
    if (widget is Container) {
      return Container(
          decoration: widget.decoration,
          constraints: widget.constraints,
          padding: widget.padding,
          margin: widget.margin,
          alignment: widget.alignment,
          child: _compact(widget.child ?? const SizedBox()));
    }
    if (widget is SizedBox && widget.child == null && widget.width != null) {
      return SizedBox(
          width: widget.width! > 8 ? 8 : widget.width, height: widget.height);
    }
    return widget;
  }
}

const supplyCardLabel = TextStyle(
  fontFamily: supplyFontFamily,
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.black54,
);
const supplyCardValue = TextStyle(
  fontFamily: supplyFontFamily,
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.black87,
);
const supplyCardEmphasis = TextStyle(
  fontFamily: supplyFontFamily,
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

class SupplyVendorValue extends StatelessWidget {
  const SupplyVendorValue(
      {super.key, required this.name, required this.action});
  final String name;
  final Widget action;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              fit: FlexFit.loose,
              child: Text(name,
                  style: supplyCardValue.copyWith(
                      fontSize: supplyCompact(context) ? 13 : 16))),
          const SizedBox(width: 6),
          action,
        ],
      );
}

/// Uses the same visual language as the updated management modules.
class SupplySurface extends StatelessWidget {
  const SupplySurface({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Theme(data: supplyTheme(context), child: child);
}

/// Matches the compact, borderless input interiors of the verified PO form.
class SupplyProgressSurface extends StatelessWidget {
  const SupplyProgressSurface({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
        data: supplyTheme(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        child: child,
      );
}

class SupplyCard extends StatelessWidget {
  const SupplyCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xfff4f6f8)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffe1e5e9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0xccffffff),
              blurRadius: 6,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      );
}

Future<T?> showSupplyDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) =>
    showAccountDialog<T>(
      context: context,
      builder: (dialogContext) =>
          SupplySurface(child: Builder(builder: builder)),
      barrierDismissible: barrierDismissible,
    );

class SupplyConfirmationDialog extends StatelessWidget {
  const SupplyConfirmationDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.actions,
      this.actionsAlignment = MainAxisAlignment.end});
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final MainAxisAlignment actionsAlignment;

  @override
  Widget build(BuildContext context) => AlertDialog(
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        actionsAlignment: actionsAlignment,
        title: Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: DefaultTextStyle(
                style: const TextStyle(
                    fontFamily: supplyFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
                textAlign: TextAlign.center,
                child: title)),
        content: SizedBox(
            width: 420,
            child: DefaultTextStyle.merge(
                textAlign: TextAlign.center, child: content)),
        actions: actions,
      );
}
