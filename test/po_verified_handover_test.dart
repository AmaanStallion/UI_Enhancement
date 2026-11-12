import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_loading.dart';
import 'package:stallion/ui/views/accountmanagement/accountmanagement.dart';
import 'package:stallion/ui/views/accountmanagement/podetails.dart';
import 'package:stallion/ui/views/accountmanagement/porequested.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final width in [390.0, 1920.0]) {
    testWidgets('Verified handover main screen and skeleton at $width', (tester) async {
      _viewport(tester, width);
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: AccountMainSkeleton())));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Loading Account Management'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await _offline(() async {
        await tester.pumpWidget(MaterialApp(home: AccountManagementView(
            projectId: 'preview', towarId: 'preview', projectName: 'Sample Project',
            towarName: 'Tower A', navigationFlag: 'Project')));
        await tester.pumpAndSettle();
        expect(find.text('Verified'), findsOneWidget);
        expect(find.text('PURCHASE ORDER STATUS'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('Verified handover navigation and editing at $width', (tester) async {
      _viewport(tester, width);
      await _offline(() async {
        await tester.pumpWidget(MaterialApp(onGenerateRoute: (_) => MaterialPageRoute(
          settings: RouteSettings(arguments: NotificationArgs(
              projectId: 'preview', projectName: 'Sample Project', towarName: 'Tower A',
              response: NotificationResponseData(towarId: 'preview',
                  assignToId: '', flagRedirect: 'Verified'))),
          builder: (_) => const PoRequestedView(),
        )));
        await tester.pumpAndSettle();
        for (final label in ['PO No', 'PO created date', 'PO Status', 'Booking type', 'Delivery status']) {
          expect(find.text(label), findsWidgets);
        }
        final toggles = find.byWidgetPredicate((widget) => widget is IconButton &&
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('po-request-toggle-'));
        final toggleKey = tester.widget<IconButton>(toggles.first).key!;
        await tester.tap(find.textContaining('VIEW DOC').first);
        await tester.pumpAndSettle();
        expect(find.text('View Documents'), findsOneWidget);
        await tester.tap(find.text('OKAY'));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isFalse);
        await tester.tap(find.text('PO No').first);
        await tester.pumpAndSettle();
        for (final entry in {
          'Requirement Type': 'Also know as Requirement/Product type',
          'Description / Sub type': 'Grade name: Also known as Description/Sub type',
        }.entries) {
          final tip = find.byKey(ValueKey('po-grade-info-${entry.key}'));
          await tester.ensureVisible(tip);
          await tester.pumpAndSettle();
          expect(find.descendant(of: tip, matching: find.byIcon(Icons.info_outline)), findsOneWidget);
          await tester.tap(tip);
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text(entry.value), findsOneWidget);
          Tooltip.dismissAllToolTips();
          await tester.pumpAndSettle();
          if (width >= 720) {
            final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
            await mouse.addPointer(location: Offset.zero);
            await mouse.moveTo(tester.getCenter(tip));
            await tester.pump(const Duration(milliseconds: 700));
            expect(find.text(entry.value), findsOneWidget);
            await mouse.removePointer();
            Tooltip.dismissAllToolTips();
            await tester.pumpAndSettle();
          }
        }
        expect(find.byType(PoDetails), findsOneWidget);
        final summary = tester.widget<Container>(find.byKey(const ValueKey('verify-po-summary-card')));
        expect((summary.decoration as BoxDecoration).color, Colors.black);
        for (final entry in {
          'Enter Description': 'Custom subtype',
          'Enter requirement for': 'Custom requirement',
          'Enter Quantity': '2',
          'Enter Unit Price (Optional)': '10',
          'Enter Other Remarks': 'Integration UI check',
        }.entries) {
          final field = find.byWidgetPredicate((widget) => widget is TextField &&
              widget.decoration?.hintText == entry.key);
          await tester.ensureVisible(field);
          await tester.enterText(field, entry.value);
          await tester.pump(const Duration(seconds: 2));
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          expect(tester.widget<TextField>(field).controller?.text, entry.value);
        }
        final total = find.byWidgetPredicate((widget) => widget is TextField &&
            widget.decoration?.hintText == 'Total Price');
        expect(tester.widget<TextField>(total).controller?.text, '20.00');
        expect(find.text('ASSIGN TO'), findsOneWidget);
        expect(find.text('GET VENDOR QUOTE'), findsOneWidget);
        tester.state<NavigatorState>(find.byType(Navigator).first).pop();
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isFalse);
        await tester.tap(find.byKey(toggleKey));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isTrue);
        expect(find.text('PREVIEW-001'), findsOneWidget);
        await tester.tap(find.byKey(toggleKey));
        await tester.pumpAndSettle();
        expect(find.text('P.O. No.'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  }
}

Future<void> _offline(Future<void> Function() action) => HttpOverrides.runZoned(
    action, createHttpClient: (_) => throw StateError('Network disabled for UI handover tests'));

void _viewport(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, width < 720 ? 900 : 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
