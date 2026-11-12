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
        for (final label in ['Del. Qty.', 'Challan']) {
          expect(find.descendant(of: card, matching: find.text(label)), findsOneWidget);
        }
        expect(find.descendant(of: card, matching: find.textContaining('View Doc')), findsOneWidget);
        expect(find.descendant(of: card, matching: find.text('View GRN')), findsNothing);
        expect(find.descendant(of: card, matching: find.text('E-Sign')), findsNothing);
        final cards = find.byWidgetPredicate((widget) => widget is Column &&
          widget.key is ValueKey<String> && (widget.key as ValueKey<String>).value.startsWith('po-request-card-issued/'));
        expect(tester.getSize(cards.at(0)).height, tester.getSize(cards.at(1)).height);
        final toggle = find.descendant(of: card, matching: find.byType(IconButton));
        final toggleKey = tester.widget<IconButton>(toggle).key!;
        final delivery = find.descendant(of: card, matching: find.text('Del. Qty.'));
        await tester.tap(delivery);
        await tester.pumpAndSettle();
        expect(find.text('Order Details'), findsOneWidget);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isFalse);
        await tester.tap(find.descendant(of: card, matching: find.textContaining('View Doc')));
        await tester.pumpAndSettle();
        expect(find.text('View Documents'), findsOneWidget);
        await tester.tap(find.text('OKAY'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(toggleKey));
        await tester.pumpAndSettle();
        expect(tester.widget<IconButton>(find.byKey(toggleKey)).isSelected, isTrue);
        for (final label in ['View GRN', 'View Challan']) {
          await tester.tap(find.text(label).first);
          await tester.pumpAndSettle();
          expect(label == 'View GRN' ? find.byType(GrnListingView) : find.byType(ChalanScreen), findsOneWidget);
          if (label == 'View GRN') {
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
        await tester.tap(find.text('E-Sign').first);
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
