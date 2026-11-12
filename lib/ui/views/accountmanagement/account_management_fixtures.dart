import '../../../utils/app_url.dart';

// Demonstration choices only; IDs are never used by the live integration.
List<Map<String, dynamic>> assignedPoFilterSamples() => [
  {'id': 'sample-vendors', 'name': 'Vendor', 'details': [
    {'id': 'sample-v1', 'name': 'Sample Vendor'},
    {'id': 'sample-v2', 'name': 'Metro Steel Supplies'},
    {'id': 'sample-v3', 'name': 'Prime Cement Traders'},
    {'id': 'sample-v4', 'name': 'Buildwell Materials'},
  ]},
  {'id': 'sample-materials', 'name': 'Booking Type', 'details': [
    {'id': 'sample-m1', 'name': 'Steel FE500'},
    {'id': 'sample-m2', 'name': 'Cement'},
    {'id': 'sample-m3', 'name': 'RMC M25'},
    {'id': 'sample-m4', 'name': 'Sand'},
  ]},
  {'id': 'sample-delivery', 'name': 'Delivery Status', 'details': [
    {'id': 'sample-d1', 'name': 'Order Pending'},
    {'id': 'sample-d2', 'name': 'Partially Delivered'},
    {'id': 'sample-d3', 'name': 'Delivered'},
  ]},
];

// Local fixtures matching the existing Account Management response models.
Map<String, dynamic>? accountManagementFixture(String url) => {
      AppUrl.wspodetailsbystatus: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "offset": "20",
          "rcc_booking_history": [
            {
              "po_hand_sign_img": "",
              "po_hand_sign_user_id": "1",
              "po_hand_sign_date": "2026-11-03",
              "po_assing_to": "1",
              "po_assing_date": "2026-11-03",
              "casting_unit": "1",
              "po_verify_date": "2026-11-03",
              "po_checked_by_date": "2026-11-03",
              "po_verify_flag": "1",
              "po_verify_by": "Aarav Shah",
              "project_id_fk": "1",
              "supplier_from": "1",
              "po_sign_date": "2026-11-03",
              "order_remark": "Sample material for Tower A",
              "remarks": "Sample material for Tower A",
              "chalan_complet_status": "0",
              "po_approve_status": "1",
              "po_approve_by": "Aarav Shah",
              "user_id_fk": "1",
              "po_created_at": "2026-11-03",
              "invoice_amount": "125000",
              "gst_per": "0",
              "order_status": "0",
              "order_delivery_date": "2026-11-03",
              "order_quantity": "100",
              "order_id": "1",
              "grade_name": "Steel FE500",
              "grade_unit": "MT",
              "grade_type_name": "Steel FE500",
              "casting_date": "2026-11-03",
              "casting_for": "Sample material for Tower A",
              "slab_id_fk": "1",
              "po_no": "PREVIEW-001",
              "vender_id_fk": "1",
              "po_status": "0",
              "po_amount": "125000",
              "towar_id_fk": "1",
              "po_document": ["Sample order.pdf"],
              "grn_active": "0",
              "slab_selected": [
                {"po_slab_id_fk": "1", "po_slab_name": "1"}
              ],
              "is_star_marked": "0",
              "sort_dt": "2026-11-03",
              "po_requsition": "0",
              "vender_name": "Sample Supplies Pvt Ltd",
              "vender_phone": [
                {
                  "vender_name": "Sample Supplies Pvt Ltd",
                  "vender_phone_number": "9000000000"
                }
              ],
              "raised_by": "Aarav Shah",
              "po_checked_by": "Aarav Shah",
              "po_assing_to_name": "Aarav Shah",
              "re_approved_reson": "",
              "re_approved_date": "2026-11-03",
              "order_deliver_date": "2026-11-03",
              "slab_name": "1",
              "project_name": "Sample Project",
              "order_details": [
                {
                  "casting_unit": "1",
                  "grade_type_name": "Steel FE500",
                  "brand_supplier_name": "1",
                  "grade_type_id": "1",
                  "supplie_id": "1",
                  "order_quantity": "100",
                  "casting_for": "Sample material for Tower A",
                  "unit_price": "1250",
                  "grade_name": "Steel FE500",
                  "grade_id": "1",
                  "casting_unit_name": "MT",
                  "casting_unit_id": "1",
                  "delivery_quantity": "100"
                }
              ],
              "checked_by": "Aarav Shah",
              "delivery_quantity": "100",
              "arr_po_doc": [
                {
                  "file_name": "Sample order.pdf",
                  "created_at": "2026-11-03",
                  "is_pdf": "1",
                  "file_path": "preview://document"
                }
              ],
              "project_delivered": "1",
              "authorize_flag": "1"
            },
            {
              "po_hand_sign_img": "",
              "po_hand_sign_user_id": "1",
              "po_hand_sign_date": "2026-11-03",
              "po_assing_to": "1",
              "po_assing_date": "2026-11-03",
              "casting_unit": "1",
              "po_verify_date": "2026-11-03",
              "po_checked_by_date": "2026-11-03",
              "po_verify_flag": "1",
              "po_verify_by": "Aarav Shah",
              "project_id_fk": "1",
              "supplier_from": "1",
              "po_sign_date": "2026-11-03",
              "order_remark": "Sample material for Tower A",
              "remarks": "Sample material for Tower A",
              "chalan_complet_status": "0",
              "po_approve_status": "1",
              "po_approve_by": "Aarav Shah",
              "user_id_fk": "1",
              "po_created_at": "2026-11-03",
              "invoice_amount": "125000",
              "gst_per": "0",
              "order_status": "0",
              "order_delivery_date": "2026-11-03",
              "order_quantity": "100",
              "order_id": "2",
              "grade_name": "Steel FE500",
              "grade_unit": "MT",
              "grade_type_name": "Steel FE500",
              "casting_date": "2026-11-03",
              "casting_for": "Sample material for Tower A",
              "slab_id_fk": "1",
              "po_no": "PREVIEW-002",
              "vender_id_fk": "1",
              "po_status": "0",
              "po_amount": "125000",
              "towar_id_fk": "1",
              "po_document": ["Sample order.pdf"],
              "grn_active": "0",
              "slab_selected": [
                {"po_slab_id_fk": "1", "po_slab_name": "1"}
              ],
              "is_star_marked": "0",
              "sort_dt": "2026-11-03",
              "po_requsition": "0",
              "vender_name": "Metro Concrete Pvt Ltd",
              "vender_phone": [
                {
                  "vender_name": "Sample Supplies Pvt Ltd",
                  "vender_phone_number": "9000000000"
                }
              ],
              "raised_by": "Aarav Shah",
              "po_checked_by": "Aarav Shah",
              "po_assing_to_name": "Aarav Shah",
              "re_approved_reson": "",
              "re_approved_date": "2026-11-03",
              "order_deliver_date": "2026-11-03",
              "slab_name": "1",
              "project_name": "Sample Project",
              "order_details": [
                {
                  "casting_unit": "1",
                  "grade_type_name": "Steel FE500",
                  "brand_supplier_name": "1",
                  "grade_type_id": "1",
                  "supplie_id": "1",
                  "order_quantity": "100",
                  "casting_for": "Sample material for Tower A",
                  "unit_price": "1250",
                  "grade_name": "Steel FE500",
                  "grade_id": "1",
                  "casting_unit_name": "MT",
                  "casting_unit_id": "1",
                  "delivery_quantity": "100"
                }
              ],
              "checked_by": "Aarav Shah",
              "delivery_quantity": "100",
              "arr_po_doc": [
                {
                  "file_name": "Sample order.pdf",
                  "created_at": "2026-11-03",
                  "is_pdf": "1",
                  "file_path": "preview://document"
                }
              ],
              "project_delivered": "1",
              "authorize_flag": "0"
            }
          ],
          "vender_list": [
            {
              "vender_id": "1",
              "vender_company_name": "Sample Supplies Pvt Ltd",
              "vender_name": "Sample Supplies Pvt Ltd"
            }
          ],
          "booking_type": [
            {
              "grade_id": "1",
              "name": "Sample Vendor",
              "count": "3",
              "details": [
                {"grade_type_id": "1", "grade_type_name": "Steel FE500"}
              ]
            }
          ],
          "hand_sign_url": ""
        }
      },
      AppUrl.getprojectworequested: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "offset": "20",
          "wo_mask_flag": "0",
          "invoice_filter_list": [
            {"id": "1", "name": "Sample Vendor", "invoice_count": "3"}
          ],
          "wo_order_list": [
            {
              "value_total_with_out_gst": "125000",
              "po_hand_sign_img": "",
              "draft_flag": "0",
              "arr_wo_doc": [
                {
                  "file_name": "Sample order.pdf",
                  "created_at": "2026-11-03",
                  "is_pdf": "1",
                  "file_path": "preview://document"
                }
              ],
              "wo_assing_to_name": "Aarav Shah",
              "re_approved_date": "2026-11-03",
              "wo_verify_flag": "0",
              "wo_assign_date": "2026-11-03",
              "wo_sign_date": "2026-11-03",
              "wo_assing_to": "1",
              "company_name": "Sample Supplies Pvt Ltd",
              "re_approved_reson": "",
              "company_id": "1",
              "wo_order_no": "PREVIEW-001",
              "wo_order_id": "1",
              "project_id_fk": "1",
              "towar_id_fk": "1",
              "towar_id": "1",
              "grade_id": "1",
              "contract_type": "1",
              "value_total": "125000",
              "value_one": "125000",
              "value_two": "125000",
              "est_date": "2026-11-03",
              "gst_amount": "125000",
              "discount_amount": "125000",
              "retention_value": "125000",
              "wo_is_issued": "0",
              "wo_issued_by": "1",
              "project_name": "Sample Project",
              "approved_by": "Aarav Shah",
              "remarks": "Sample material for Tower A",
              "is_star_marked": "0",
              "wo_checked_by_date": "2026-11-03",
              "wo_checked_by": "Aarav Shah",
              "upload_note_image": [
                {"image_name": "Sample BOQ.pdf"}
              ],
              "wo_hand_sign_img": "",
              "wo_hand_sign_name": "1",
              "wo_hand_sign_date": "2026-11-03",
              "authorize_flag": "0"
            },
            {
              "value_total_with_out_gst": "125000",
              "po_hand_sign_img": "",
              "draft_flag": "0",
              "arr_wo_doc": [
                {
                  "file_name": "Sample order.pdf",
                  "created_at": "2026-11-03",
                  "is_pdf": "1",
                  "file_path": "preview://document"
                }
              ],
              "wo_assing_to_name": "Aarav Shah",
              "re_approved_date": "2026-11-03",
              "wo_verify_flag": "0",
              "wo_assign_date": "2026-11-03",
              "wo_sign_date": "2026-11-03",
              "wo_assing_to": "1",
              "company_name": "Metro Concrete Pvt Ltd",
              "re_approved_reson": "",
              "company_id": "1",
              "wo_order_no": "PREVIEW-002",
              "wo_order_id": "2",
              "project_id_fk": "1",
              "towar_id_fk": "1",
              "towar_id": "1",
              "grade_id": "1",
              "contract_type": "1",
              "value_total": "125000",
              "value_one": "125000",
              "value_two": "125000",
              "est_date": "2026-11-03",
              "gst_amount": "125000",
              "discount_amount": "125000",
              "retention_value": "125000",
              "wo_is_issued": "0",
              "wo_issued_by": "1",
              "project_name": "Sample Project",
              "approved_by": "Aarav Shah",
              "remarks": "Sample material for Tower A",
              "is_star_marked": "0",
              "wo_checked_by_date": "2026-11-03",
              "wo_checked_by": "Aarav Shah",
              "upload_note_image": [
                {"image_name": "Sample BOQ.pdf"}
              ],
              "wo_hand_sign_img": "",
              "wo_hand_sign_name": "1",
              "wo_hand_sign_date": "2026-11-03",
              "authorize_flag": "0"
            }
          ],
          "hand_sign_url": ""
        }
      },
      AppUrl.wspaymentdetailsbystatus: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "po_wo_payment": [
            {
              "payment_vender_id": "1",
              "approved_by": "Aarav Shah",
              "vender_name": "Sample Supplies Pvt Ltd",
              "hold_status": "0",
              "request_by": "Aarav Shah",
              "due_amount": "125000",
              "overdue_amount": "125000",
              "po_wo_flag": "0",
              "po_no": "PREVIEW-001",
              "invoice_no": "1",
              "amount_request": "125000",
              "status": "Pending",
              "payment_mode": "1",
              "po_invoice_image": "Sample invoice.pdf",
              "invoice_payment_updated_at": "2026-11-03",
              "invoice_payment_created_at": "2026-11-03",
              "advance_amount": "125000",
              "document_img": "preview://document/sample.pdf",
              "document_remark": "Sample material for Tower A"
            },
            {
              "payment_vender_id": "2",
              "approved_by": "Aarav Shah",
              "vender_name": "Metro Concrete Pvt Ltd",
              "hold_status": "0",
              "request_by": "Aarav Shah",
              "due_amount": "125000",
              "overdue_amount": "125000",
              "po_wo_flag": "0",
              "po_no": "PREVIEW-002",
              "invoice_no": "1",
              "amount_request": "125000",
              "status": "Pending",
              "payment_mode": "1",
              "po_invoice_image": "Sample invoice.pdf",
              "invoice_payment_updated_at": "2026-11-03",
              "invoice_payment_created_at": "2026-11-03",
              "advance_amount": "125000",
              "document_img": "preview://document/sample.pdf",
              "document_remark": "Sample material for Tower A"
            }
          ]
        }
      },
      AppUrl.wsvenderpaymentduelist: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "vendor_due_list": [
            {
              "vender_name": "Sample Supplies Pvt Ltd",
              "vender_id": "1",
              "grad_id_fk": "1",
              "dueamount": "125000",
              "grade_name": "Steel FE500",
              "pending_invoice": "1",
              "paidInvCount": "1",
              "totalInvCount": "125000"
            },
            {
              "vender_name": "Metro Concrete Pvt Ltd",
              "vender_id": "2",
              "grad_id_fk": "1",
              "dueamount": "125000",
              "grade_name": "Steel FE500",
              "pending_invoice": "1",
              "paidInvCount": "1",
              "totalInvCount": "125000"
            }
          ],
          "total_due": "125000"
        }
      },
      AppUrl.wsvenderpaymenthistory: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "search_data": [
            {"grade_name": "Steel FE500", "grade_id": "1"}
          ],
          "vender_grade": [
            {
              "grade_price": "1250",
              "grade_type_name": "Steel FE500",
              "grade_unit": "MT"
            }
          ],
          "invoice_path": "1",
          "payment_history": [
            {
              "is_star_marked": "0",
              "key": "2026-11-03",
              "project_name": "Sample Project",
              "challan_upload_status": "0",
              "po_no": "PREVIEW-001",
              "purchase_order_number": "1",
              "invoice_number": "1",
              "due_date": "2026-11-03",
              "delivery_date": "2026-11-03",
              "amount": "125000",
              "credit_type": "1",
              "due_type": "1",
              "order_id": "1",
              "payment_type": "1",
              "invoice_pdf": "Sample invoice.pdf",
              "raised_by": "Aarav Shah",
              "po_approve_by": "Aarav Shah",
              "invoice_status": "0",
              "invoice_pdf_arr": [],
              "invoice_list_arr": [],
              "is_paid": "1",
              "order_type": [
                {"grade_name": "Steel FE500", "grade_id": "1"}
              ],
              "order_type_comma": "1",
              "status": "Pending",
              "po_approve_status": "0",
              "totalInv": "125000",
              "paidInvCount": "1",
              "pending_invoice": "1",
              "po_sign_date": "2026-11-03"
            }
          ],
          "total_invoice": "125000",
          "total_payment": "125000",
          "total_balance": "125000",
          "total_overdue": "125000"
        }
      },
      AppUrl.webTrackingAssignToList: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "track_list": [
            {
              "trans_emp_name": "Aarav Shah",
              "trans_emp_id": "1",
              "total_count": "125000",
              "pending_count": "3"
            }
          ]
        }
      },
      AppUrl.getDeveloperPoDashboard: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "data": {
            "approvals": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "invoices": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "delivery": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "vendor": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "dueover": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "payments": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ]
          }
        }
      },
      AppUrl.getDeveloperWoDashboard: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "data": {
            "approvals": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "invoices": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "delivery": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "vendor": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "dueover": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ],
            "payments": [
              {"status": "Pending", "count": "6"},
              {"status": "Completed", "count": "12"},
              {"status": "Assigned", "count": "8"},
              {"status": "Issued", "count": "24"}
            ]
          }
        }
      },
      AppUrl.getDeveloperRawMaterialDashboard: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "data": [
            {
              "grade_name": "Steel FE500",
              "grade_id": "1",
              "details": [
                {
                  "stock_in": "1",
                  "stock_out": "1",
                  "month": "1",
                  "month_name": "1"
                }
              ]
            }
          ]
        }
      },
      AppUrl.wsPoFilter: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "filter_list": [
            {
              "name": "Sample Vendor",
              "id": "1",
              "details": [
                {"id": "1", "name": "Sample Vendor"}
              ]
            }
          ]
        }
      },
      AppUrl.wsWoFilter: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "filter_list": [
            {
              "name": "Sample Vendor",
              "id": "1",
              "details": [
                {"id": "1", "name": "Sample Vendor"}
              ]
            }
          ]
        }
      },
      AppUrl.wsPoDeliveryDetails: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "order_details": [
            {
              "casting_unit": "1",
              "supplie_id": "1",
              "order_quantity": "100",
              "casting_for": "Sample material for Tower A",
              "unit_price": "1250",
              "grade_type_id_fk": "1",
              "grade_id_Fk": "1",
              "grade_name": "Steel FE500",
              "grade_id": "1",
              "casting_unit_name": "MT",
              "casting_unit_id": "1",
              "delivery_quantity": "100"
            }
          ],
          "checked_by": "Aarav Shah",
          "delivery_quantity": "100",
          "order_quantity": "100"
        }
      },
      AppUrl.wspostructurebyorder: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "po_pdf": "",
          "authorize_flag": "0",
          "po_file_name": "",
          "budget_not_set_msg": "",
          "budget_over_buget": "",
          "price_structure": [
            {
              "trans_grade_type_name": "1",
              "grade_id_fk": "1",
              "slab_supplier_id": "1",
              "unit_price": "1250",
              "old_price": "125000",
              "po_no": "PREVIEW-001",
              "unit_price_percentage": "125000",
              "unit_price_difference": "125000",
              "average_price": "125000"
            }
          ],
          "signature_upload": "",
          "show_accounts": "0",
          "po_structure": {
            "subject": "1",
            "content": "<h2>Sample order</h2><p>Stallion UI preview</p>",
            "po_status": "0"
          },
          "filePath": "preview://document",
          "fileName": "Sample order.pdf"
        }
      },
      AppUrl.getprojectwopreview: {
        "Response": {
          "error_code": "0",
          "work_user_track": "1",
          "assing_to_list": [
            {
              "trans_emp_project_id_fk": "1",
              "trans_emp_developer_id": "1",
              "trans_emp_project_status": "0",
              "trans_emp_project_number": "1",
              "trans_emp_name": "Aarav Shah",
              "trans_emp_id": "1"
            }
          ],
          "msg": "Preview action completed locally",
          "wo_pdf": "",
          "wo_file_name": "",
          "signature_upload": "",
          "show_accounts": "0",
          "wo_order_html":
              "<h2>Work order preview</h2><p>Sample contract for Tower A</p>",
          "wo_status": "0",
          "filePath": "preview://document",
          "fileName": "Sample order.pdf",
          "authorize_flag": "0"
        }
      },
      AppUrl.getGetDefaultPoCreate: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "slab_details": [
            {"slab_name": "1", "slab_id": "1", "selected": "1"}
          ],
          "po_request": "1",
          "order_list": [
            {"id": "1", "name": "Sample Vendor", "towar_list": []}
          ],
          "finishing_type_list": [
            {
              "finishing_id": "1",
              "finishing_name": "1",
              "count": "3",
              "finishing_unit": [
                {"mst_finishing_unit_id": "1", "mst_finishing_unit_name": "1"}
              ]
            }
          ],
          "finishing_unit": [
            {"mst_finishing_unit_id": "1", "mst_finishing_unit_name": "1"}
          ],
          "assing_to_list": [
            {
              "trans_emp_project_id_fk": "1",
              "trans_emp_developer_id": "1",
              "trans_emp_project_status": "0",
              "trans_emp_project_number": "1",
              "trans_emp_name": "Aarav Shah",
              "trans_emp_id": "1"
            }
          ],
          "purchase_user_track": "1",
          "custome_btn_active": "0"
        }
      },
      AppUrl.webGetPoRequisitonVendorList: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "vender_list": [
            {
              "select_id": "1",
              "select_name": "Sample Vendor",
              "send_status": "0"
            }
          ],
          "assing_to_list": [
            {
              "trans_emp_project_id_fk": "1",
              "trans_emp_developer_id": "1",
              "trans_emp_project_status": "0",
              "trans_emp_project_number": "1",
              "trans_emp_name": "Aarav Shah",
              "trans_emp_id": "1"
            }
          ],
          "purchase_user_track": "1"
        }
      },
      AppUrl.webGetDescriptionByPoGrade: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "finishing_unit": [
            {"unit_id": "1", "unit_name": "MT", "flag": "0"}
          ],
          "similar_description": [
            {"trans_grade_type_name": "1"}
          ]
        }
      },
      AppUrl.wsgetgrnlist: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "grn_details": [
            {
              "grn_file_name": "Sample invoice.pdf",
              "challan_no": "1",
              "grn_sr_no": "1",
              "grn_created_date": "2026-11-03",
              "grn_id": "1",
              "grade_id_fk": "1",
              "booking_type": "1",
              "grade_name": "Steel FE500"
            }
          ]
        }
      },
      AppUrl.getGetPoChallan: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "challan_report_list": [
            {
              "po_challan_report_id": "1",
              "order_id_fk": "1",
              "po_challan_remarks": "Sample material for Tower A",
              "po_challan_report": "Sample challan.pdf",
              "po_challan_status": "0",
              "po_challan_updated_at": "2026-11-03",
              "po_challan_cretated_at": "2026-11-03",
              "file_delete": "1"
            }
          ]
        }
      },
      AppUrl.wsvenderpoinvoicelist: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "invoice_data": [
            {
              "invoice_id": "1",
              "invoice_no": "1",
              "invoice_image": "Sample invoice.pdf",
              "invoice_date": "2026-11-03",
              "total_paid": "125000",
              "total_amount": "125000",
              "status": "Pending"
            }
          ],
          "invoice_path": "1"
        }
      },
      AppUrl.getPoVendorQuotationPdf: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "quote_file_name": "Sample order.pdf",
          "quote_file_path": "preview://document"
        }
      },
      AppUrl.webSetPoAssignTo: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "vender_list": [
            {
              "select_id": "1",
              "select_name": "Sample Vendor",
              "send_status": "0"
            }
          ],
          "assing_to_list": [
            {
              "trans_emp_project_id_fk": "1",
              "trans_emp_developer_id": "1",
              "trans_emp_project_status": "0",
              "trans_emp_project_number": "1",
              "trans_emp_name": "Aarav Shah",
              "trans_emp_id": "1"
            }
          ],
          "purchase_user_track": "1"
        }
      },
      AppUrl.webSetWoAssignTo: {
        "Response": {
          "error_code": "0",
          "msg": "Preview action completed locally",
          "vender_list": [
            {
              "select_id": "1",
              "select_name": "Sample Vendor",
              "send_status": "0"
            }
          ],
          "assing_to_list": [
            {
              "trans_emp_project_id_fk": "1",
              "trans_emp_developer_id": "1",
              "trans_emp_project_status": "0",
              "trans_emp_project_number": "1",
              "trans_emp_name": "Aarav Shah",
              "trans_emp_id": "1"
            }
          ],
          "purchase_user_track": "1"
        }
      },
    }[url];
