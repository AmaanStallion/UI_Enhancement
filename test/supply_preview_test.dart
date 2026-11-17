import 'package:stallion/ui/views/statusofsupply/supply_form_loading.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:stallion/models/get_challan_po_order_list.dart';
import 'package:stallion/ui/views/statusofsupply/uploadchallan.dart';
import 'package:flutter/rendering.dart';
import 'package:stallion/ui/views/statusofsupply/supply_style.dart';
import 'package:stallion/ui/views/statusofsupply/inventory_management.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/statusofsupply/supply_preview.dart';
import 'package:stallion/ui/views/statusofsupply/statussupplyview.dart';
import 'package:stallion/ui/views/statusofsupply/suppliesdetails.dart';

void expectSupplyFont(WidgetTester tester) {
  for (final element in find.byType(Text).evaluate()) {
    final render = element.findRenderObject();
    if (render is RenderParagraph) {
      expect((render.text as TextSpan).style?.fontFamily, supplyFontFamily,
          reason: 'Font for ${(element.widget as Text).data}');
    }
  }
  for (final element in find.byType(EditableText).evaluate()) {
    expect((element.widget as EditableText).style.fontFamily, supplyFontFamily);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sample delivery quantities stay within ordered quantities', () {
    final orders = supplyPreviewOrders('250', 'Sample Project');
    expect(orders.map((o) => o.orderStatus).toSet(), {'0', '1', '2', '4'});
    for (final order in orders) {
      expect(double.parse(order.deliveryQuantity!),
          lessThanOrEqualTo(double.parse(order.orderQuantity!)));
      expect(order.projectIdFk, '250');
    }
  });

  testWidgets('supply list renders sample orders without a backend',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: StatusOfSupplyView()));
    await tester.pump();
    expect(find.text('Sample Ready Mix Ltd'), findsNothing);
    await tester
        .tap(find.byKey(const ValueKey('supply-card-toggle-sample-supply-1')));
    await tester.pumpAndSettle();
    expect(find.text('Sample Ready Mix Ltd'), findsWidgets);
    expect(tester.takeException(), isNull);
    expectSupplyFont(tester);
  });

  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('mobile supply cards fit at $width with GRN action',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: StatusOfSupplyView()));
      await tester.pump();
      final dynamic state = tester.state(find.byType(StatusOfSupplyView));
      state.setState(() {
        state.rccBookingHistory.first.grn_active = '1';
      });
      await tester.pump();
      expect(find.text('VIEW GRN'), findsOneWidget);
      final status = tester.renderObject<RenderParagraph>(
          find.text('Partially Delivered').first);
      expect(status.text.style?.fontSize, 13);
      expect(status.text.style?.fontWeight, FontWeight.bold);
      final poStatus =
          tester.renderObject<RenderParagraph>(find.text('Issued').first);
      expect(poStatus.text.style?.fontSize, 13);
      expect(poStatus.text.style?.fontWeight, FontWeight.bold);
      expect(
          status
              .getBoxesForSelection(
                  const TextSelection(baseOffset: 0, extentOffset: 19))
              .length,
          1);
      await tester.tap(
          find.byKey(const ValueKey('supply-card-toggle-sample-supply-1')));
      await tester.pumpAndSettle();
      final vendor = find.byType(SupplyVendorValue).first;
      final vendorName = find.descendant(
          of: vendor, matching: find.text('Sample Ready Mix Ltd'));
      final phone = find.descendant(
          of: vendor, matching: find.byIcon(Icons.local_phone_outlined));
      expect(tester.widget<Icon>(phone).size, 17);
      expect(tester.getRect(phone).left - tester.getRect(vendorName).right,
          inInclusiveRange(6, 12));
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.drag(
          find
              .byWidgetPredicate((w) =>
                  w is Scrollable && w.axisDirection == AxisDirection.down)
              .last,
          const Offset(0, -650));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
    });
  }

  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('mobile supply details fit at $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          home: SuppliesPoDetails(
        projectId: '250',
        towarId: '',
        projectName: 'Sample Project',
        orderDetails: supplyPreviewOrders('250', 'Sample Project').first,
      )));
      await tester.pumpAndSettle();
      expect(find.text('VIEW PO'), findsOneWidget);
      expect(find.text('PARTIALLY DELIVERED'), findsOneWidget);
      final partial = tester.getRect(find
          .ancestor(
              of: find.text('PARTIALLY DELIVERED'),
              matching: find.byType(GestureDetector))
          .first);
      final complete = tester.getRect(find
          .ancestor(
              of: find.text('ORDER COMPLETE'),
              matching: find.byType(GestureDetector))
          .first);
      expect(partial.center.dx, lessThan(complete.center.dx));
      expect(partial.center.dy, complete.center.dy);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.text('Delivered Quantity'));
      await tester.pumpAndSettle();
      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('120 m³'), findsOneWidget);
      expect(find.text('75 m³'), findsOneWidget);
      expect(find.text('45.0 m³'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(tester.getCenter(find.widgetWithText(ElevatedButton, 'CLOSE')).dx,
          closeTo(tester.getCenter(find.byType(AlertDialog)).dx, 1));
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      await tester.drag(
          find.byType(SingleChildScrollView).first, const Offset(0, -1000));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
    });
  }

  for (final width in [360.0, 1440.0]) {
    testWidgets('supply filter search apply and reset at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: StatusOfSupplyView()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('supply-filter')));
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      final reset =
          tester.getRect(find.widgetWithText(OutlinedButton, 'RESET'));
      final apply =
          tester.getRect(find.widgetWithText(ElevatedButton, 'APPLY FILTER'));
      expect(reset.center.dx, lessThan(apply.center.dx));
      expect(reset.center.dy, apply.center.dy);
      await tester.enterText(
          find.descendant(of: dialog, matching: find.byType(TextFormField)),
          'Steel');
      await tester.pump();
      expect(
          find.descendant(
              of: dialog, matching: find.text('Sample Steel Traders')),
          findsOneWidget);
      expect(
          find.descendant(
              of: dialog, matching: find.text('Sample Ready Mix Ltd')),
          findsNothing);
      await tester.tap(find.descendant(
          of: dialog, matching: find.text('Sample Steel Traders')));
      await tester.tap(find.text('APPLY FILTER'));
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(StatusOfSupplyView));
      expect(state.rccBookingHistory.length, 1);
      expect(state.rccBookingHistory.first.venderName, 'Sample Steel Traders');
      await tester.tap(find.byKey(const ValueKey('supply-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();
      expect(state.rccBookingHistory.length, 4);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
    });
  }

  for (final width in [360.0, 1440.0]) {
    testWidgets('tower popup preserves selection and bottom OK at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          onGenerateRoute: (_) => MaterialPageRoute(
                settings: RouteSettings(
                    arguments: NotificationArgs(
                        projectId: '250',
                        projectName: 'Sample Project',
                        towarName: '',
                        response: NotificationResponseData(
                            projectId: '250',
                            towarId: '',
                            navigationFlag: 'Project'))),
                builder: (_) => const StatusOfSupplyView(),
              )));
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(StatusOfSupplyView));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('supply-tower-selector')));
      await tester.pumpAndSettle();
      expect(find.text('SELECT TOWER'), findsOneWidget);
      expect(tester.getCenter(find.text('OK')).dy,
          greaterThan(tester.getCenter(find.text('Tower A')).dy));
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(state.args.response.towarId, '');
      await tester.tap(find.byKey(const ValueKey('supply-tower-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tower A'));
      await tester.pumpAndSettle();
      expect(state.args.response.towarId, 'sample-a');
      expect(find.text('TOWER A'), findsOneWidget);
      expect(find.text('SELECT TOWER'), findsNothing);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
    });
  }

  for (final width in [360.0, 390.0, 430.0, 1440.0]) {
    testWidgets('inventory layout and controls fit at $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(
          home: InventoryManagement(
        projectId: '250',
        projectName: 'Sample Project',
        towarId: '',
        towarName: '',
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      final from = tester.getRect(find.byKey(const ValueKey('inventory-from')));
      final to = tester.getRect(find.byKey(const ValueKey('inventory-to')));
      final submit =
          tester.getRect(find.byKey(const ValueKey('inventory-submit')));
      final reset =
          tester.getRect(find.byKey(const ValueKey('inventory-reset')));
      expect(from.center.dx, lessThan(to.center.dx));
      expect(to.center.dx, lessThan(submit.center.dx));
      expect(submit.center.dx, lessThan(reset.center.dx));
      expect(from.center.dy, to.center.dy);
      expect(to.center.dy, submit.center.dy);
      expect(submit.center.dy, reset.center.dy);
      await tester.enterText(
          find.byKey(const ValueKey('inventory-search')), 'Steel');
      await tester.pumpAndSettle();
      expect(find.text('Ready Mix Concrete'), findsNothing);
      expect(find.text('TMT Steel'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('inventory-item-2')));
      await tester.pumpAndSettle();
      expect(find.text('TMT Steel'), findsNWidgets(2));
      expect(find.textContaining('Stock In Value :'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.byKey(const ValueKey('inventory-item-2')));
      await tester.pumpAndSettle();
      expect(find.text('TMT Steel'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('inventory-from')));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(InventoryManagement));
      state.fromDateControler.text = '16-11-2026';
      state.toDateControler.text = '18-11-2026';
      await tester.tap(find.byKey(const ValueKey('inventory-reset')));
      await tester.pumpAndSettle();
      expect(state.fromDateControler.text, '');
      expect(state.toDateControler.text, '');
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
    });
  }

  for (final width in [360.0, 1440.0]) {
    testWidgets('vendor contact popup and Close fit at $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: StatusOfSupplyView()));
      await tester.pumpAndSettle();
      await tester.tap(
          find.byKey(const ValueKey('supply-card-toggle-sample-supply-1')));
      await tester.pumpAndSettle();
      final phone = find.descendant(
          of: find.byType(SupplyVendorValue).first,
          matching: find.byIcon(Icons.local_phone_outlined));
      await tester.ensureVisible(phone);
      await tester.tap(phone);
      await tester.pumpAndSettle();
      final dialog = find.byKey(const ValueKey('supply-vendor-contacts'));
      expect(dialog, findsOneWidget);
      expect(find.text('Sample Dispatch Contact'), findsOneWidget);
      expect(find.text('Sample Sales Contact'), findsOneWidget);
      expect(find.text('+91 00000 00101'), findsOneWidget);
      final close =
          tester.getRect(find.widgetWithText(ElevatedButton, 'Close'));
      expect(close.center.dx, closeTo(tester.getRect(dialog).center.dx, 1));
      expect(
          close.top,
          greaterThan(
              tester.getRect(find.text('Sample Sales Contact')).bottom));
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(dialog, findsNothing);
      final dynamic state = tester.state(find.byType(StatusOfSupplyView));
      state.setState(() => state.rccBookingHistory.first.venderPhone.clear());
      await tester.pump();
      await tester.tap(phone);
      await tester.pumpAndSettle();
      expect(find.text('No contact details available'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });
  }

  for (final width in [360.0, 390.0, 430.0, 1440.0]) {
    testWidgets('upload challan form and actions fit at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          home: UploadChallanofPo(
        projectId: '250',
        projectName: 'Sample Project',
        towarId: '',
        orderId: 'sample-order',
      )));
      await tester.pumpAndSettle();
      final attach =
          tester.getRect(find.byKey(const ValueKey('challan-attach')));
      final remarks =
          tester.getRect(find.byKey(const ValueKey('challan-remarks')));
      final submit =
          tester.getRect(find.byKey(const ValueKey('challan-submit')));
      expect(attach.right, lessThan(remarks.left));
      expect(submit.top, greaterThan(remarks.bottom));
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();
      expect(find.text('Please upload delivery challan file.'), findsOneWidget);
      expect(
          tester.getSize(find.widgetWithText(ElevatedButton, 'CLOSE')).height,
          32);
      expect(
          tester
              .renderObject<RenderParagraph>(
                  find.text('Please upload delivery challan file.'))
              .text
              .style
              ?.fontSize,
          14);

      expect(tester.getCenter(find.widgetWithText(ElevatedButton, 'CLOSE')).dx,
          closeTo(tester.getCenter(find.byType(AlertDialog)).dx, 1));
      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(UploadChallanofPo));
      state.setState(() {
        state.arrayFiles.add(PlatformFile(
            name: 'sample.pdf',
            size: 4,
            bytes: Uint8List.fromList([37, 80, 68, 70])));
        state.arrayFilesBytes.add(null);
      });
      await tester.pumpAndSettle();
      final remove =
          tester.getRect(find.byKey(const ValueKey('challan-remove')));
      expect(remove.center.dx, lessThan(remarks.left));
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.byKey(const ValueKey('challan-remove')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('challan-attach')), findsOneWidget);
      expect(state.arrayFiles.length, 0);
      state.setState(() {
        state.arrayFiles.add(PlatformFile(
            name: 'sample.pdf',
            size: 4,
            bytes: Uint8List.fromList([37, 80, 68, 70])));
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill challan remark/comments field.'),
          findsOneWidget);
      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('challan-remarks')),
          'Sample delivery received at Tower A.');
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();
      expect(
          find.text('Are you sure you want to submit this delivery challan?'),
          findsOneWidget);
      expect(
          tester
              .renderObject<RenderParagraph>(find.text(
                  'Are you sure you want to submit this delivery challan?'))
              .textAlign,
          TextAlign.center);
      expect(tester.getCenter(find.text('NO')).dx,
          lessThan(tester.getCenter(find.text('YES')).dx));
      expect(tester.getCenter(find.text('NO')).dy,
          tester.getCenter(find.text('YES')).dy);
      await tester.tap(find.text('YES'));
      await tester.pumpAndSettle();
      expect(find.text('Sample data preview — changes are not saved.'),
          findsOneWidget);
      state.setState(() {
        state.challanReportList.add(ChallanReportList(
            poChallanReport: 'sample.pdf',
            poChallanRemarks:
                'Sample saved challan remarks with a longer description.',
            poChallanCretatedAt: DateTime(2026, 11, 16)));
        state.count = 2;
      });
      await tester.pumpAndSettle();
      expect(find.text('16 Nov 2026'), findsOneWidget);
      expect(
          find.text('Sample saved challan remarks with a longer description.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
    });
  }

  for (final width in [360.0, 1440.0]) {
    testWidgets('update progress form controls retain behavior at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          home: SuppliesPoDetails(
        projectId: '250',
        projectName: 'Sample Project',
        towarId: '',
        orderDetails: supplyPreviewOrders('250', 'Sample Project').first,
      )));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('supply-progress-summary')),
          findsOneWidget);
      final grade = find
          .byWidgetPredicate(
              (w) => w is TextField && w.decoration?.hintText == 'Select Grade')
          .last;
      await tester.ensureVisible(grade);
      await tester.tap(grade);
      await tester.pumpAndSettle();
      expect(find.text('SELECT GRADE'), findsOneWidget);
      await tester.tap(find
          .descendant(
              of: find.byType(AlertDialog),
              matching: find.text('Ready Mix Concrete'))
          .last);
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(SuppliesPoDetails));
      expect(state.strGradName, 'Ready Mix Concrete');
      expect(state.gradeDetailsList.length, 2);
      expect(state.contractorList.length, 2);
      expect(state.woList.length, 2);
      // Existing grade selection leaves its picker open until dismissed.
      if (find.byType(AlertDialog).evaluate().isNotEmpty) {
        tester.state<NavigatorState>(find.byType(Navigator).first).pop();
        await tester.pumpAndSettle();
      }
      final quantity = find
          .byWidgetPredicate((w) =>
              w is TextField && w.decoration?.hintText == 'Enter Quantity')
          .last;
      await tester.ensureVisible(quantity);
      expect(tester.widget<TextField>(quantity).enabled, isTrue);
      await tester.enterText(quantity, '12.345');
      expect(tester.widget<TextField>(quantity).controller!.text, '12.345');
      final sameVehicle = find.text('Same Vehicle');
      await tester.ensureVisible(sameVehicle);
      await tester.tap(sameVehicle);
      await tester.pumpAndSettle();
      final vehicle = find
          .byWidgetPredicate((w) =>
              w is TextField && w.decoration?.hintText == 'Enter Vehicle No')
          .last;
      expect(
          tester.widget<TextField>(vehicle).controller!.text, 'MH 01 AB 1234');
      final sameChallan = find.text('Same Challan');
      await tester.ensureVisible(sameChallan);
      await tester.tap(sameChallan);
      await tester.pumpAndSettle();
      final challan = find
          .byWidgetPredicate((w) =>
              w is TextField && w.decoration?.hintText == 'Enter Challan No.')
          .last;
      expect(tester.widget<TextField>(challan).controller!.text, 'DEMO/CH/001');
      final contractor = find
          .byWidgetPredicate((w) =>
              w is TextField &&
              w.decoration?.hintText == 'Select Contractor (Optional)')
          .last;
      await tester.ensureVisible(contractor);
      await tester.tap(contractor);
      await tester.pumpAndSettle();
      expect(find.text('SELECT CONTRACTOR'), findsOneWidget);
      final contractorDialog = find.byType(AlertDialog);
      await tester.enterText(
          find
              .descendant(
                  of: contractorDialog, matching: find.byType(TextField))
              .first,
          'Finishing');
      await tester.pumpAndSettle();
      await tester.tap(find
          .descendant(
              of: contractorDialog,
              matching: find.text('Sample Finishing Contractor'))
          .last);
      await tester.pumpAndSettle();
      expect(state.strContractorId, 'sample-contractor-2');
      await tester.tap(
          find.descendant(of: contractorDialog, matching: find.text('OK')));
      await tester.pumpAndSettle();
      final workOrder = find
          .byWidgetPredicate((w) =>
              w is TextField &&
              w.decoration?.hintText == 'Select Work Order No. (Optional)')
          .last;
      await tester.ensureVisible(workOrder);
      await tester.tap(workOrder);
      await tester.pumpAndSettle();
      expect(find.text('SELECT WORK ORDER NO.'), findsOneWidget);
      final workOrderDialog = find.byType(AlertDialog);
      await tester.tap(find
          .descendant(of: workOrderDialog, matching: find.text('DEMO/WO/002'))
          .last);
      await tester.pumpAndSettle();
      expect(state.strWorkOrderId, 'sample-wo-2');
      await tester
          .tap(find.descendant(of: workOrderDialog, matching: find.text('OK')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
    });
  }

  for (final width in [360.0, 1440.0]) {
    testWidgets(
        'progress confirmation dialogs preserve action positions at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          home: SuppliesPoDetails(
        projectId: '250',
        projectName: 'Sample Project',
        towarId: '',
        orderDetails: supplyPreviewOrders('250', 'Sample Project').first,
      )));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_drop_down_circle_outlined), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down_rounded), findsWidgets);
      await tester.tap(find.text('PARTIALLY DELIVERED'));
      await tester.pumpAndSettle();
      expect(find.byType(SupplyConfirmationDialog), findsOneWidget);
      expect(
          find.text('Are you sure, you want to deliver this order as partial?'),
          findsOneWidget);
      expect(tester.getCenter(find.text('NO')).dx,
          lessThan(tester.getCenter(find.text('YES')).dx));
      expect(
          tester.getRect(find.widgetWithText(OutlinedButton, 'NO')).width,
          closeTo(
              tester.getRect(find.widgetWithText(ElevatedButton, 'YES')).width,
              1));
      final partialMessage = find.descendant(
          of: find.byType(SupplyConfirmationDialog),
          matching: find.byWidgetPredicate(
              (w) => w is Text && (w.data ?? '').startsWith('Are you sure')));
      expect(tester.renderObject<RenderParagraph>(partialMessage).textAlign,
          TextAlign.center);
      expect(tester.getCenter(find.text('NO')).dy,
          closeTo(tester.getCenter(find.text('YES')).dy, 1));
      final partialNo =
          tester.getRect(find.widgetWithText(OutlinedButton, 'NO'));
      final partialYes =
          tester.getRect(find.widgetWithText(ElevatedButton, 'YES'));
      expect(partialNo.width, closeTo(partialYes.width, 1));
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.text('NO'));
      await tester.pumpAndSettle();
      final updateAction = find.text('UPDATE & ADD MORE');
      await tester.ensureVisible(updateAction);
      await tester.tap(updateAction);
      await tester.pumpAndSettle();
      expect(find.text('Please enter quantity.'), findsOneWidget);
      expect(tester.getCenter(find.widgetWithText(ElevatedButton, 'CLOSE')).dx,
          closeTo(tester.getCenter(find.byType(AlertDialog)).dx, 1));
      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      final quantity = find
          .byWidgetPredicate((w) =>
              w is TextField && w.decoration?.hintText == 'Enter Quantity')
          .last;
      await tester.ensureVisible(quantity);
      await tester.enterText(quantity, '10');
      final vehicle = find
          .byWidgetPredicate((w) =>
              w is TextField && w.decoration?.hintText == 'Enter Vehicle No')
          .last;
      await tester.ensureVisible(vehicle);
      await tester.enterText(vehicle, 'MH 01 AB 1234');
      final dynamic state = tester.state(find.byType(SuppliesPoDetails));
      state.setState(() {
        state.orderCompletFlag = '1';
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('ORDER COMPLETE'));
      await tester.pumpAndSettle();
      expect(
          find.text('Are you sure you want to complete this purchase order?'),
          findsOneWidget);
      expect(find.text('Write Your Remarks'), findsOneWidget);
      await tester.enterText(
          find.descendant(
              of: find.byType(SupplyConfirmationDialog),
              matching: find.byType(TextField)),
          'Sample completion remarks');
      expect(tester.getCenter(find.text('NO')).dx,
          lessThan(tester.getCenter(find.text('YES')).dx));
      expect(
          tester.getRect(find.widgetWithText(OutlinedButton, 'NO')).width,
          closeTo(
              tester.getRect(find.widgetWithText(ElevatedButton, 'YES')).width,
              1));
      final completeMessage = find.descendant(
          of: find.byType(SupplyConfirmationDialog),
          matching: find.byWidgetPredicate(
              (w) => w is Text && (w.data ?? '').startsWith('Are you sure')));
      expect(tester.renderObject<RenderParagraph>(completeMessage).textAlign,
          TextAlign.center);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.text('NO'));
      await tester.pumpAndSettle();
      final addMore = find.text('UPDATE & ADD MORE');
      await tester.ensureVisible(addMore);
      await tester.tap(addMore);
      await tester.pumpAndSettle();
      expect(
          find.text(
              'Are you sure, you want to update? Once updated it cannot be amended!'),
          findsOneWidget);
      expect(find.byType(SupplyConfirmationDialog), findsOneWidget);
      expect(tester.getCenter(find.text('NO')).dx,
          lessThan(tester.getCenter(find.text('YES')).dx));
      expect(
          tester.getRect(find.widgetWithText(OutlinedButton, 'NO')).width,
          closeTo(
              tester.getRect(find.widgetWithText(ElevatedButton, 'YES')).width,
              1));
      final updateMessage = find.descendant(
          of: find.byType(SupplyConfirmationDialog),
          matching: find.byWidgetPredicate(
              (w) => w is Text && (w.data ?? '').startsWith('Are you sure')));
      expect(tester.renderObject<RenderParagraph>(updateMessage).textAlign,
          TextAlign.center);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
      await tester.tap(find.text('NO'));
      await tester.pumpAndSettle();
      expect(find.byType(SupplyConfirmationDialog), findsNothing);
    });
  }

  for (final width in [360.0, 1440.0]) {
    testWidgets('minimised supply cards show six fields and toggle at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: StatusOfSupplyView()));
      await tester.pumpAndSettle();
      final first =
          find.byKey(const ValueKey('supply-minimised-sample-supply-1'));
      for (final label in [
        'P.O. No.',
        'P.O. Status',
        'Booking Type',
        'Status Delivery',
        'PO Quantity',
        'Delivered Quantity'
      ]) {
        expect(find.descendant(of: first, matching: find.text(label)),
            findsOneWidget);
      }
      final minimisedWidth =
          tester.getSize(find.byType(SupplyCard).first).width;
      final labelBefore = tester.getTopLeft(
          find.descendant(of: first, matching: find.text('P.O. No.')));
      final valueBefore = tester.getTopLeft(find.descendant(
          of: first,
          matching:
              find.byKey(const ValueKey('supply-po-number-sample-supply-1'))));
      final styleBefore = tester
          .renderObject<RenderParagraph>(find.descendant(
              of: first,
              matching: find
                  .byKey(const ValueKey('supply-po-number-sample-supply-1'))))
          .text
          .style;
      expect(
          find.descendant(
              of: find.byType(SupplyCard).first,
              matching: find.byType(Divider)),
          findsNothing);
      final poParagraph = tester.renderObject<RenderParagraph>(
          find.byKey(const ValueKey('supply-po-number-sample-supply-1')));
      final starRect = tester.getRect(find.descendant(
          of: first, matching: find.byIcon(Icons.star_rounded)));
      final poRect = tester.getRect(
          find.byKey(const ValueKey('supply-po-number-sample-supply-1')));
      expect(poParagraph.maxLines, 1);
      expect(starRect.center.dy, closeTo(poRect.center.dy, 2));
      expect(starRect.right, closeTo(poRect.right, 1));
      final minimisedHeight = tester.getSize(first).height;
      expect(find.text('Sample Ready Mix Ltd'), findsNothing);
      await tester.tap(
          find.byKey(const ValueKey('supply-card-toggle-sample-supply-1')));
      await tester.pumpAndSettle();
      expect(first, findsNothing);
      expect(find.text('Sample Ready Mix Ltd'), findsOneWidget);
      expect(find.byType(SuppliesPoDetails), findsNothing);
      final firstCard = find
          .ancestor(
              of: find.byType(SupplyVendorValue).first,
              matching: find.byType(SupplyCard))
          .first;
      expect(tester.getSize(firstCard).height, greaterThan(minimisedHeight));
      expect(find.descendant(of: firstCard, matching: find.byType(Divider)),
          findsNothing);
      expect(tester.getSize(firstCard).width, minimisedWidth);
      expect(tester.getTopLeft(find.text('P.O. No.').first).dx, labelBefore.dx);
      expect(
          tester
              .getTopLeft(find
                  .byKey(const ValueKey('supply-po-number-sample-supply-1')))
              .dx,
          valueBefore.dx);
      expect(
          tester
              .renderObject<RenderParagraph>(find
                  .byKey(const ValueKey('supply-po-number-sample-supply-1')))
              .text
              .style,
          styleBefore);
      await tester.tap(
          find.byKey(const ValueKey('supply-card-toggle-sample-supply-1')));
      await tester.pumpAndSettle();
      expect(first, findsOneWidget);
      final secondToggle =
          find.byKey(const ValueKey('supply-card-toggle-sample-supply-2'));
      await tester.ensureVisible(secondToggle);
      await tester.tap(secondToggle);
      await tester.pumpAndSettle();
      expect(find.byType(SupplyVendorValue), findsOneWidget);
      expect(find.text('Sample Steel Traders'), findsOneWidget);
      final dynamic state = tester.state(find.byType(StatusOfSupplyView));
      state.setState(() {
        state.flagSortBy = false;
      });
      await state.fetchPoStatusOfSupply();
      await tester.pumpAndSettle();
      expect(find.text('Sample Steel Traders'), findsOneWidget);
      await tester.ensureVisible(secondToggle);
      await tester.tap(secondToggle);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const MaterialApp(
          key: ValueKey('fresh-supply-navigation'),
          home: StatusOfSupplyView()));
      await tester.pumpAndSettle();
      final firstCardContent =
          find.byKey(const ValueKey('supply-minimised-sample-supply-1'));
      await tester.tap(find.descendant(
          of: firstCardContent,
          matching:
              find.byKey(const ValueKey('supply-po-number-sample-supply-1'))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(SupplyFormSkeleton), findsOneWidget);
      expect(find.text('UPDATE PROGRESS'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(SuppliesPoDetails), findsOneWidget);
      expect(tester.takeException(), isNull);
      expectSupplyFont(tester);
    });
  }

  for (final width in [360.0, 1440.0]) {
    testWidgets('supply form skeleton adapts and resolves at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          home: SuppliesPoDetails(
        projectId: '250',
        towarId: '',
        projectName: 'Sample Project',
        orderDetails: supplyPreviewOrders('250', 'Sample Project').first,
      )));
      expect(find.byType(SupplyFormSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(SupplyFormSkeleton), findsOneWidget);
      expect(find.text('UPDATE PROGRESS'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(SupplyFormSkeleton), findsNothing);
      expect(find.text('UPDATE PROGRESS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('sample PO details render without a backend', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: SuppliesPoDetails(
      projectId: '250',
      towarId: '',
      projectName: 'Sample Project',
      orderDetails: supplyPreviewOrders('250', 'Sample Project').first,
    )));
    await tester.pumpAndSettle();
    expect(find.text('DEMO/PO/2026/101'), findsWidgets);
    await tester.tap(find.text('Delivered Quantity'));
    await tester.pumpAndSettle();
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('120 m³'), findsOneWidget);
    expect(find.text('75 m³'), findsOneWidget);
    expect(find.text('45.0 m³'), findsOneWidget);
    expect(tester.getCenter(find.widgetWithText(ElevatedButton, 'CLOSE')).dx,
        closeTo(tester.getCenter(find.byType(AlertDialog)).dx, 1));
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();
    expect(find.text('Order Details'), findsNothing);
    expect(tester.takeException(), isNull);
    expectSupplyFont(tester);
  });
}
