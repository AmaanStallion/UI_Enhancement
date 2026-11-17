import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import '../../../models/get_status_of_supply_list.dart';

/// Local UI preview, matching Account Management. Release builds use live data.

const bool useSupplyTestData = kDebugMode;

bool supplyPreviewAction(BuildContext context) {
  if (!useSupplyTestData) return false;

  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Sample data preview — changes are not saved.'),
  ));

  return true;
}

List<RccBookingHistory> supplyPreviewOrders(
    String projectId, String projectName) {
  const vendors = [
    'Sample Ready Mix Ltd',
    'Sample Steel Traders',
    'Sample Cement Co',
    'Sample Aggregates'
  ];

  const materials = ['Ready Mix Concrete', 'TMT Steel', 'Cement', 'River Sand'];

  const units = ['m³', 'MT', 'Bags', 'm³'];

  const quantities = ['120', '40', '500', '80'];

  const delivered = ['75', '40', '0', '20'];

  const statuses = ['4', '2', '0', '1'];

  return List.generate(
      4,
      (i) => RccBookingHistory.fromJson({
            'supplier_from': '',
            'user_id_fk': '',
            'slab_id_fk': '',
            'project_id_fk': projectId,
            'project_name': projectName,
            'order_id': 'sample-supply-${i + 1}',
            'po_no': 'DEMO/PO/2026/${101 + i}',
            'vender_id_fk': '${i + 1}',
            'vender_name': vendors[i],
            'grade_name': materials[i],
            'grade_type_name': materials[i],
            'grade_unit': units[i],
            'casting_unit': units[i],
            'order_quantity': quantities[i],
            'delivery_quantity': delivered[i],
            'order_status': statuses[i],
            'po_status': '2',
            'po_approve_status': '1',
            'chalan_complet_status': i == 1 ? '1' : '0',
            'po_created_at': '12-11-2026',
            'casting_date': '${16 - i}-11-2026',
            'casting_for': 'Tower A / Slab ${i + 1}',
            'slab_name': 'Slab ${i + 1}',
            'po_sign_date': '13-11-2026',
            'order_delivery_date': '18-11-2026',
            'order_deliver_date': '16-11-2026',
            'po_amount': '${(i + 1) * 125000}',
            'invoice_amount': '${(i + 1) * 125000}',
            'gst_per': '18',
            'raised_by': 'Sample Site Engineer',
            'checked_by': 'Sample Storekeeper',
            'po_checked_by': 'Sample Project Manager',
            'po_checked_by_date': '13-11-2026',
            'po_approve_by': 'Sample Accounts Manager',
            'remarks': 'Sample order for UI review',
            'order_remark': 'Deliver to Tower A material storage area.',
            'is_star_marked': i == 0 ? '1' : '0',
            'grn_active': '0',
            'vender_phone': [
              {
                'vender_name': 'Sample Dispatch Contact',
                'vender_phone_number': '+91 00000 00101'
              },
              {
                'vender_name': 'Sample Sales Contact',
                'vender_phone_number': '+91 00000 00102'
              },
            ],
            'order_details': [
              {
                'casting_unit': units[i],
                'casting_unit_name': units[i],
                'casting_unit_id': '${i + 1}',
                'brand_supplier_name': vendors[i],
                'casting_date': '2026-11-16',
                'grade_type_name': materials[i],
                'grade_type_id': '${i + 1}',
                'supplie_id': '${i + 1}',
                'order_quantity': quantities[i],
                'casting_for': 'Tower A',
                'unit_price': '1250',
                'delivery_quantity': delivered[i],
              }
            ],
          }));
}
