import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/accountmanagement/porequested.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final width in [390.0, 1920.0]) {
    testWidgets('Assigned collapsed actions and signing permission at $width', (tester) async {
      tester.view.physicalSize = Size(width, width < 720 ? 900 : 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(MaterialApp(onGenerateRoute: (_) => MaterialPageRoute(
          settings: RouteSettings(arguments: NotificationArgs(
            projectId: 'preview', projectName: 'Sample Project', towarName: 'Tower A',
            response: NotificationResponseData(towarId: 'preview',
                assignToId: '', flagRedirect: 'Assigned'))),
          builder: (_) => const PoRequestedView(),
        )));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('po-list-filter')));
        await tester.pumpAndSettle();
        expect(find.text('Sample options · UI preview'), findsOneWidget);
        expect(find.text('Metro Steel Supplies'), findsOneWidget);
        await tester.tap(find.text('Metro Steel Supplies'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
        await tester.enterText(find.widgetWithText(TextField, 'Search'), 'Prime');
        await tester.pumpAndSettle();
        expect(find.text('Metro Steel Supplies'), findsNothing);
        expect(find.text('Prime Cement Traders'), findsOneWidget);
        await tester.tap(find.text('RESET'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_box_rounded), findsNothing);
        expect(find.text('Metro Steel Supplies'), findsOneWidget);
        expect(tester.getCenter(find.text('RESET')).dy,
          closeTo(tester.getCenter(find.text('APPLY FILTER')).dy, 1));
        await tester.tap(find.text('APPLY FILTER'));
        await tester.pumpAndSettle();
        expect(find.text('FILTER'), findsNothing);
        Finder card(String number) => find.ancestor(
          of: find.text(number), matching: find.byWidgetPredicate((widget) =>
              widget is Column && widget.key is ValueKey<String> &&
              (widget.key as ValueKey<String>).value.startsWith('po-request-card-assigned/')));
        final firstCard = card('PREVIEW-001');
        final toggle = find.descendant(of: firstCard, matching: find.byType(IconButton));
        final toggleKey = tester.widget<IconButton>(toggle).key!;
        expect(tester.widget<IconButton>(toggle).isSelected, isFalse);
        for (final label in ['PO No', 'PO created date', 'PO Status', 'Booking type', 'Delivery status']) {
          expect(find.descendant(of: firstCard, matching: find.text(label)), findsOneWidget);
        }
        final doc = find.descendant(of: firstCard, matching: find.textContaining('View Doc'));
        final sign = find.descendant(of: firstCard, matching: find.text('E-Sign'));
        expect(doc, findsOneWidget);
        expect(sign, findsOneWidget);
        expect(tester.getCenter(doc).dx, closeTo(tester.getCenter(sign).dx, 1));
        expect(tester.getRect(sign).top, greaterThan(tester.getRect(doc).bottom));
        await tester.tap(doc);
        await tester.pumpAndSettle();
        expect(find.text('View Documents'), findsOneWidget);
        await tester.tap(find.text('OKAY'));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isFalse);
        await tester.tap(sign);
        await tester.pumpAndSettle();
        expect(find.text('SIGNATURE'), findsOneWidget);
        await tester.tap(find.text('CLOSE'));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isFalse);
        final secondCard = card('PREVIEW-002');
        final disabledSign = find.descendant(of: secondCard, matching: find.text('E-Sign'));
        await tester.ensureVisible(disabledSign);
        final disabledInk = find.ancestor(of: disabledSign, matching: find.byType(InkWell)).first;
        expect(tester.widget<InkWell>(disabledInk).onTap, isNull);
        await tester.ensureVisible(find.byKey(toggleKey));
        await tester.tap(find.byKey(toggleKey));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isTrue);
        expect(find.text('P.O. No.'), findsWidgets);
        expect(tester.getRect(find.text('P.O. No.').first).top,
            greaterThanOrEqualTo(tester.getRect(find.byKey(toggleKey)).bottom));
        await tester.tap(find.byKey(toggleKey));
        await tester.pumpAndSettle();
        expect(find.text('P.O. No.'), findsNothing);
        expect(find.textContaining('View Doc'), findsWidgets);
        expect(find.text('E-Sign'), findsWidgets);
        expect(tester.takeException(), isNull);
      }, createHttpClient: (_) => throw StateError('Network disabled for Assigned UI tests'));
    });
  }
}
