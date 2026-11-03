import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import 'account_management_fixtures.dart';
import 'account_management_preview.dart';

/// A module-scoped adapter. No Account Management request reaches the server
/// while local preview mode is enabled; normal behavior is retained otherwise.
class AccountManagementPreviewNetwork extends NetworkHandler {
  @override
  Future<http.Response> post(String url, Map<String, String> body) async {
    if (!useAccountManagementTestData) return super.post(url, body);

    final fixture = accountManagementFixture(url);
    final data = fixture == null
        ? <String, dynamic>{
            'Response': {
              'error_code': '0',
              'msg': 'Preview action completed locally',
              'assing_to_list': [],
              'finishing_unit': [],
              'similar_description': [],
            },
          }
        : jsonDecode(jsonEncode(fixture)) as Map<String, dynamic>;
    final response = data['Response'] as Map<String, dynamic>;
    if (url == AppUrl.wspodetailsbystatus) {
      for (final order in response['rcc_booking_history'] as List) {
        order['po_status'] = body['po_status'] ?? '0';
        order['project_id_fk'] = body['project_id'] ?? 'preview';
        order['towar_id_fk'] = body['towar_id'] ?? '';
      }
    }
    if (url == AppUrl.getprojectworequested) {
      for (final order in response['wo_order_list'] as List) {
        order['project_id_fk'] = body['project_id'] ?? 'preview';
        order['towar_id_fk'] = body['towar_id'] ?? '';
      }
    }
    // The demo is a single local page. Searching and loading more never fall
    // through to production requests or append duplicate sample records.
    for (final key in ['rcc_booking_history', 'wo_order_list']) {
      if (response[key] is! List) continue;
      final rows = response[key] as List;
      final query = (body['search_data'] ?? '').trim().toLowerCase();
      rows.removeWhere((row) =>
          query.isNotEmpty &&
          !(row as Map).values.join(' ').toLowerCase().contains(query));
      if ((int.tryParse(body['offset'] ?? '0') ?? 0) > 0) rows.clear();
    }
    return http.Response(jsonEncode(data), 200,
        headers: {'content-type': 'application/json'});
  }
}
