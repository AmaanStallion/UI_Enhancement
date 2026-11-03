import 'dart:io';
import 'package:stallion/ui/views/accountmanagement/grnlistingview.dart';
import 'package:stallion/ui/views/accountmanagement/chalan_Screen.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/viewchallan.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/invoicelist.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/views/accountmanagement/porequested.dart';
import 'package:stallion/ui/views/accountmanagement/worequested.dart';
import 'package:stallion/ui/views/accountmanagement/payment_request.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/paymentduelist.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/paymentcompanylist.dart';
import 'package:stallion/ui/views/accountmanagement/paymentdue/track_account_management.dart';
import 'package:stallion/ui/views/accountmanagement/account_dashboard/account_dashboard.dart';
import 'package:stallion/ui/views/accountmanagement/podetails.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview_network.dart';
import 'package:stallion/models/get_po_details_by_status.dart' as m0;
import 'package:stallion/models/get_project_wo_request.dart' as m1;
import 'package:stallion/models/get_payment_details_by_status.dart' as m2;
import 'package:stallion/models/get_payment_due_list.dart' as m3;
import 'package:stallion/models/get_payment_details_by_vendor.dart' as m4;
import 'package:stallion/models/track_assign.dart' as m5;
import 'package:stallion/models/get_developer_po_dashboard.dart' as m6;
import 'package:stallion/models/get_developer_po_dashboard.dart' as m7;
import 'package:stallion/models/getDeveloperRawMaterialDashboard.dart' as m8;
import 'package:stallion/models/sales_lead_filter.dart' as m9;
import 'package:stallion/models/sales_lead_filter.dart' as m10;
import 'package:stallion/models/po_delivery_details.dart' as m11;
import 'package:stallion/models/get_po_preview_html.dart' as m12;
import 'package:stallion/models/get_wo_preview_html.dart' as m13;
import 'package:stallion/models/get_purchase_order_default_request.dart' as m14;
import 'package:stallion/models/get_po_requistion_vendor_list.dart' as m15;
import 'package:stallion/models/grade_description.dart' as m16;
import 'package:stallion/models/get_grn_list.dart' as m17;
import 'package:stallion/models/get_chalan_list.dart' as m18;
import 'package:stallion/models/get_po_viewchallan.dart' as m19;
import 'package:stallion/models/get_po_invoice_list.dart' as m20;
import 'package:stallion/models/po_vendor_quotation_pdf.dart' as m21;
import 'package:stallion/models/get_po_requistion_vendor_list.dart' as m22;
import 'package:stallion/models/get_po_requistion_vendor_list.dart' as m23;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  test('wspodetailsbystatus fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wspodetailsbystatus,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m0.GetPoDetailsByStatus.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('getprojectworequested fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.getprojectworequested,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m1.GetProjectWoRequest.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('wspaymentdetailsbystatus fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wspaymentdetailsbystatus,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m2.GetPaymentDetailsStatus.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('wsvenderpaymentduelist fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wsvenderpaymentduelist,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m3.GetPaymentDueList.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('wsvenderpaymenthistory fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wsvenderpaymenthistory,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(
        () => m4.GetPaymentDetailsByVendor.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('webTrackingAssignToList fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.webTrackingAssignToList,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m5.TrackAssign.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('getDeveloperPoDashboard fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.getDeveloperPoDashboard,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m6.GetDeveloperPoDashboard.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('getDeveloperWoDashboard fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.getDeveloperWoDashboard,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m7.GetDeveloperPoDashboard.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('getDeveloperRawMaterialDashboard fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.getDeveloperRawMaterialDashboard,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(
        () => m8.GetDeveloperRawMaterialDashboard.fromJson(
            jsonDecode(response.body)),
        returnsNormally);
  });
  test('wsPoFilter fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wsPoFilter,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m9.SalesLeadFilter.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('wsWoFilter fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wsWoFilter,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m10.SalesLeadFilter.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('wsPoDeliveryDetails fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wsPoDeliveryDetails,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m11.PoDeliveryDetails.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('wspostructurebyorder fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wspostructurebyorder,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m12.GetPoPreviewHtml.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('getprojectwopreview fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.getprojectwopreview,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m13.GetWoPreviewHtml.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('getGetDefaultPoCreate fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.getGetDefaultPoCreate,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(
        () =>
            m14.PurchaseDefaultOrderRequest.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('webGetPoRequisitonVendorList fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.webGetPoRequisitonVendorList,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m15.GetPoRequistionForm.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('webGetDescriptionByPoGrade fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.webGetDescriptionByPoGrade,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m16.GradeDescription.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('wsgetgrnlist fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wsgetgrnlist,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m17.GetGrnList.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('getGetPoChallan fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.getGetPoChallan,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m18.GetChalanList.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('webgetpochallan fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.webgetpochallan,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m19.GetPoViewChallan.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('wsvenderpoinvoicelist fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wsvenderpoinvoicelist,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m20.GetInvoiceList.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('getPoVendorQuotationPdf fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.getPoVendorQuotationPdf,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m21.PoVendorQuotationPdf.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('webSetPoAssignTo fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.webSetPoAssignTo,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m22.GetPoRequistionForm.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });
  test('webSetWoAssignTo fixture parses', () async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.webSetWoAssignTo,
        {'po_status': '0', 'project_id': 'preview', 'towar_id': 'preview'});
    expect(response.statusCode, 200);
    expect(() => m23.GetPoRequistionForm.fromJson(jsonDecode(response.body)),
        returnsNormally);
  });

  test('Preview actions cannot access the network', () async {
    await HttpOverrides.runZoned(() async {
      final response = await AccountManagementPreviewNetwork()
          .post(AppUrl.webChangePoStatus, {'status': 'approved'});
      expect(jsonDecode(response.body)['Response']['error_code'], '0');
    }, createHttpClient: (_) => throw StateError('Unexpected network access'));
  });
  testWidgets('GRN list loads offline', (tester) async {
    await pumpPreview(
        tester,
        GrnListingView(
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            orderId: '1'),
        '');
  });
  testWidgets('Challan list loads offline', (tester) async {
    await pumpPreview(
        tester,
        const ChalanScreen(
            towarName: 'Tower A',
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            orderId: '1'),
        '');
  });
  testWidgets('Payment challans load offline', (tester) async {
    await pumpPreview(
        tester,
        const ViewChallanList(
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            orderId: '1'),
        '');
  });
  testWidgets('Invoices load offline', (tester) async {
    await pumpPreview(
        tester,
        const InvoiceList(
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            orderId: '1'),
        '');
  });
  for (final status in ['Verified', 'Assigned', 'Issued']) {
    testWidgets('PO $status screen loads offline', (tester) async {
      await pumpPreview(tester, const PoRequestedView(), status);
      expect(find.textContaining('PREVIEW-001'), findsWidgets);
    });
  }
  for (final status in ['Requested', 'Assigned', 'Issued']) {
    testWidgets('WO $status screen loads offline', (tester) async {
      await pumpPreview(tester, const WoRequestedView(), status);
      expect(find.textContaining('PREVIEW-001'), findsWidgets);
    });
  }
  for (final status in ['Requested', 'Approved']) {
    testWidgets('Payment $status screen loads offline', (tester) async {
      await pumpPreview(
          tester,
          PaymentRequestedView(
              projectId: 'preview',
              towarId: 'preview',
              projectName: 'Sample Project',
              flagRedirect: status),
          status);
      expect(find.textContaining('Sample Supplies'), findsWidgets);
    });
  }
  testWidgets('Payment due screen loads offline', (tester) async {
    await pumpPreview(
        tester,
        PaymentDueList(
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            totalDue: '1250000',
            dueType: '0',
            flagRedirect: 'PaymentDue'),
        '');
    expect(find.textContaining('Sample Supplies'), findsWidgets);
  });
  testWidgets('Vendor payment history loads offline', (tester) async {
    await pumpPreview(
        tester,
        const PaymentCompanyList(
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            vendorId: '1',
            vendorName: 'Sample Supplies'),
        '');
  });
  testWidgets('Tracking loads offline', (tester) async {
    await pumpPreview(
        tester,
        const TrackAccountManagement(
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            towarName: 'Tower A'),
        '');
    expect(find.textContaining('Aarav Shah'), findsWidgets);
  });
  testWidgets('Dashboard loads offline', (tester) async {
    await pumpPreview(
        tester,
        const AccountDashboard(
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            towarName: 'Tower A'),
        '');
  });
  testWidgets('PO details loads offline', (tester) async {
    final response = await AccountManagementPreviewNetwork().post(
        AppUrl.wspodetailsbystatus,
        {'project_id': 'preview', 'towar_id': 'preview'});
    final record = m0.GetPoDetailsByStatus.fromJson(jsonDecode(response.body))
        .response!
        .rccBookingHistory!
        .first;
    await pumpPreview(
        tester,
        PoDetails(
            projectId: 'preview',
            towarId: 'preview',
            projectName: 'Sample Project',
            poId: 'Verified',
            orderDetails: record),
        '');
  });
}

Future<void> pumpPreview(
    WidgetTester tester, Widget screen, String status) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
      onGenerateRoute: (_) => MaterialPageRoute(
            settings: RouteSettings(
                arguments: NotificationArgs(
                    projectId: 'preview',
                    projectName: 'Sample Project',
                    towarName: 'Tower A',
                    response: NotificationResponseData(
                        towarId: 'preview',
                        assignToId: '',
                        flagRedirect: status))),
            builder: (_) => screen,
          )));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}
