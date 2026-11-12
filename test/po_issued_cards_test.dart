import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/accountmanagement/porequested.dart';
import 'package:stallion/ui/views/accountmanagement/grnlistingview.dart';
import 'package:stallion/ui/views/accountmanagement/chalan_Screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final width in [390.0, 1920.0]) {
    testWidgets('Issued collapsed actions and filters at $width', (tester) async {
      tester.view.physicalSize = Size(width, width < 720 ? 900 : 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(MaterialApp(onGenerateRoute: (_) => MaterialPageRoute(
          settings: RouteSettings(arguments: NotificationArgs(projectId: 'preview',
            projectName: 'Sample Project', towarName: 'Tower A',
            response: NotificationResponseData(towarId: 'preview', assignToId: '', flagRedirect: 'Issued'))),
          builder: (_) => const PoRequestedView())));
        await tester.pumpAndSettle();
        final card = find.byWidgetPredicate((widget) => widget is Column &&
          widget.key is ValueKey<String> && (widget.key as ValueKey<String>).value.startsWith('po-request-card-issued/')).first;
        for (final label in ['DEL. QTY.', 'CHALLAN', 'E-SIGN']) {
          expect(find.descendant(of: card, matching: find.text(label)), findsOneWidget);
        }
        expect(find.descendant(of: card, matching: find.text('DOC.')), findsNothing);
        expect(find.descendant(of: card, matching: find.text('GRN')), findsNothing);
        for (final label in ['DEL. QTY.', 'CHALLAN', 'E-SIGN']) {
          final control = find.ancestor(of: find.descendant(of: card, matching: find.text(label)),
            matching: find.byWidgetPredicate((widget) => widget is Container && widget.constraints?.maxHeight == 30)).first;
          expect(tester.getSize(control), Size(width < 720 ? 56 : 64, 30));
        }
        final cards = find.byWidgetPredicate((widget) => widget is Column &&
          widget.key is ValueKey<String> && (widget.key as ValueKey<String>).value.startsWith('po-request-card-issued/'));
        expect(tester.getSize(cards.at(0)).height, tester.getSize(cards.at(1)).height);
        final deliveryBadge = find.ancestor(
          of: find.descendant(of: card, matching: find.text('Order Pending')),
          matching: find.byWidgetPredicate((widget) => widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).borderRadius == BorderRadius.circular(5))).first;
        final summaryViewport = find.descendant(of: card, matching: find.byType(SingleChildScrollView)).first;
        expect(tester.getRect(deliveryBadge).bottom,
          lessThanOrEqualTo(tester.getRect(summaryViewport).bottom));
        final toggle = find.descendant(of: card, matching: find.byType(IconButton));
        final toggleKey = tester.widget<IconButton>(toggle).key!;
        final delivery = find.descendant(of: card, matching: find.text('DEL. QTY.'));
        await tester.tap(delivery);
        await tester.pumpAndSettle();
        expect(find.text('Order Details'), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isFalse);
        await tester.tap(find.descendant(of: card, matching: find.text('E-SIGN')));
        await tester.pumpAndSettle();
        expect(find.text('SIGNATURE'), findsOneWidget);
        await tester.tap(find.text('CLOSE'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(toggleKey));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isTrue);
        await tester.tap(find.text('DOC.').first);
        await tester.pumpAndSettle();
        expect(find.text('View Documents'), findsOneWidget);
        await tester.tap(find.text('OKAY'));
        await tester.pumpAndSettle();

        for (final label in ['GRN', 'CHALLAN']) {
          await tester.tap(find.text(label).first);
          await tester.pumpAndSettle();
          expect(label == 'GRN' ? find.byType(GrnListingView) : find.byType(ChalanScreen), findsOneWidget);
          if (label == 'GRN') {
            await tester.enterText(find.byKey(const ValueKey('grn-search')), 'no-such-grn');
            await tester.pumpAndSettle();
            expect(find.text('No matching GRNs'), findsOneWidget);
            await tester.enterText(find.byKey(const ValueKey('grn-search')), '');
            await tester.pumpAndSettle();
            expect(find.text('GRN. No.'), findsWidgets);
          }
          tester.state<NavigatorState>(find.byType(Navigator).first).pop();
          await tester.pumpAndSettle();
          expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isTrue);
        }
        await tester.tap(find.text('E-SIGN').first);
        await tester.pumpAndSettle();
        expect(find.text('SIGNATURE'), findsOneWidget);
        await tester.tap(find.text('CLOSE'));
        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('P.O. No.').first).top,
          greaterThanOrEqualTo(tester.getRect(find.byKey(toggleKey)).bottom));
        await tester.tap(find.byKey(toggleKey));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('po-list-filter')));
        await tester.pumpAndSettle();
        expect(find.text('Sample options · UI preview'), findsOneWidget);
        await tester.tap(find.text('Metro Steel Supplies'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
        await tester.tap(find.text('APPLY FILTER'));
        await tester.pumpAndSettle();
        expect(find.text('FILTER'), findsNothing);
        expect(tester.takeException(), isNull);
      }, createHttpClient: (_) => throw StateError('Network disabled for Issued UI tests'));
    });
  }
}
