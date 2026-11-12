import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/accountmanagement/porequested.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final status in ['Verified', 'Assigned', 'Issued']) {
    for (final width in [390.0, 1920.0]) {
      testWidgets('Only one $status card expands at $width', (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = Size(width, 1080);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await HttpOverrides.runZoned(() async {
          await tester.pumpWidget(MaterialApp(onGenerateRoute: (_) => MaterialPageRoute(
            settings: RouteSettings(arguments: NotificationArgs(projectId: 'preview',
              projectName: 'Sample Project', towarName: 'Tower A',
              response: NotificationResponseData(towarId: 'preview', assignToId: '', flagRedirect: status))),
            builder: (_) => const PoRequestedView())));
          await tester.pumpAndSettle();
          if (width >= 720) {
            expect(tester.getTopLeft(find.text('PREVIEW-001')).dx -
              tester.getTopLeft(find.text('PO No').first).dx, closeTo(244, 1));
          }
          final toggles = find.byWidgetPredicate((widget) => widget is IconButton &&
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('po-request-toggle-'));
          final first = tester.widget<IconButton>(toggles.at(0)).key!;
          final second = tester.widget<IconButton>(toggles.at(1)).key!;
          final collapsedArrowX = tester.getCenter(find.byKey(first)).dx;
          final collapsedValueX = tester.getTopLeft(find.text('PREVIEW-001')).dx;
          final action = status == 'Issued' ? find.text('E-SIGN').first : find.textContaining('VIEW DOC').first;
          final collapsedActionX = tester.getCenter(action).dx;
          Future<void> tap(Key key) async {
            await tester.ensureVisible(find.byKey(key));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(key));
            await tester.pumpAndSettle();
          }
          await tap(first);
          expect(tester.widget<IconButton>(find.byKey(first)).isSelected, isTrue);
          expect(tester.getCenter(find.byKey(first)).dx, closeTo(collapsedArrowX, 1));
          expect(tester.getTopLeft(find.text('PREVIEW-001')).dx, closeTo(collapsedValueX, 1));
          expect(tester.getCenter(action).dx, closeTo(collapsedActionX, 1));
          await tap(second);
          expect(tester.widget<IconButton>(find.byKey(second)).isSelected, isTrue);
          await tester.ensureVisible(find.byKey(first));
          await tester.pumpAndSettle();
          expect(tester.widget<IconButton>(find.byKey(first)).isSelected, isFalse);
          await tap(first);
          await tester.ensureVisible(find.byKey(second));
          await tester.pumpAndSettle();
          expect(tester.widget<IconButton>(find.byKey(second)).isSelected, isFalse);
          await tap(first);
          expect(tester.widget<IconButton>(find.byKey(first)).isSelected, isFalse);
          expect(tester.takeException(), isNull);
        }, createHttpClient: (_) => throw StateError('Network disabled for expansion checks'));
      });
    }
  }
}
