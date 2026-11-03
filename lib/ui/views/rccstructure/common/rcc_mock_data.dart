import 'package:stallion/models/drawing_details.dart';
import 'package:stallion/models/getLabReportOk.dart';
import 'package:stallion/models/get_all_check_list.dart';
import 'package:stallion/models/get_default_excavation.dart' hide SlabDetail;
import 'package:stallion/models/get_excavation_list.dart';

import 'package:stallion/models/get_project_masonry.dart' hide Drawing;
import 'package:stallion/models/get_rccissuereport_data.dart';
import 'package:stallion/models/get_rccissuereport_dropdown.dart';
import 'package:stallion/models/get_rccstructure.dart';
import 'package:stallion/models/projectSlabCheckList.dart';

/// Flag to toggle between mock data and real backend API calls.
const bool useRccMockData = false;

/// Returns mock data for R.C.C Structure Screen matching the [RccStructureDataResponse] schema.
RccStructureDataResponse getMockRccStructureData({String? towerId, String? offset}) {
  final currentOffset = offset ?? '0';

  final List<TowarList> mockTowers = [
    TowarList(towarId: "tw_101", towarName: "Tower A - Royal Wing"),
    TowarList(towarId: "tw_102", towarName: "Tower B - Executive Wing"),
    TowarList(towarId: "tw_103", towarName: "Tower C - Skyline Wing"),
  ];

  List<SlabDetail> mockSlabs = [];

  if (currentOffset == '0') {
    mockSlabs = [
      SlabDetail(
        slabId: "slb_001",
        slabNo: "Basement Slab",
        estCompletDate: "15 Jan 2026",
        completedDate: "14 Jan 2026",
        completTitile: "Slab Concreted",
        errorTitle: "",
        completStatus: "1",
        issueReport: "0",
        issueSlabReport: "0",
        orderSupplies: "1",
        checkListFlag: "1",
        drawings: [
          Drawing(
            drawingTitle: "Basement Shuttering & Reinforcement Plan",
            drawingId: "drw_b1_01",
            pdf: ["https://example.com/drawings/b1_shuttering.pdf"],
            dwg: ["https://example.com/drawings/b1_shuttering.dwg"],
            drawingVersion: [
              DrawingVersion(
                pdfRemark: "Revised column markers",
                name: "Rev 1.2",
                dwgRemark: "Updated dwg CAD file",
                pdf: [PdfElement(slabDrawingImgName: "b1_v1.pdf", drawingDate: "10 Jan 2026")],
                dwg: [PdfElement(slabDrawingImgName: "b1_v1.dwg", drawingDate: "10 Jan 2026")],
              )
            ],
            slabCheckId: "chk_b1_01",
            submitReport: "0",
            issuse: "1",
            verify: "1",
            isSelected: false,
          ),
          Drawing(
            drawingTitle: "Basement Column & Shear Wall Details",
            drawingId: "drw_b1_02",
            pdf: ["https://example.com/drawings/b1_column.pdf"],
            dwg: ["https://example.com/drawings/b1_column.dwg"],
            drawingVersion: [],
            slabCheckId: "chk_b1_02",
            submitReport: "0",
            issuse: "1",
            verify: "1",
            isSelected: false,
          ),
        ],
        slabCheck: [
          SlabCheck(
            slabCheckTitle: "Excavation & Soil Testing Clearance",
            slabCheckId: "sc_01",
            isSetupDone: "1",
            slabCheckStatusOk: "1",
            slabCheckStatusIssue: "0",
            clickActive: "1",
          ),
          SlabCheck(
            slabCheckTitle: "PCC & Footing Reinforcement Inspection",
            slabCheckId: "sc_02",
            isSetupDone: "1",
            slabCheckStatusOk: "1",
            slabCheckStatusIssue: "0",
            clickActive: "1",
          ),
          SlabCheck(
            slabCheckTitle: "Basement Slab Concreting Quality Check",
            slabCheckId: "sc_03",
            isSetupDone: "1",
            slabCheckStatusOk: "1",
            slabCheckStatusIssue: "0",
            clickActive: "1",
          ),
        ],
      ),
      SlabDetail(
        slabId: "slb_002",
        slabNo: "Plinth Slab",
        estCompletDate: "30 Jan 2026",
        completedDate: "02 Feb 2026",
        completTitile: "Completed (Delayed 3 Days)",
        errorTitle: "",
        completStatus: "1",
        issueReport: "1",
        issueSlabReport: "1",
        orderSupplies: "1",
        checkListFlag: "1",
        drawings: [
          Drawing(
            drawingTitle: "Plinth Level Structural Drawing",
            drawingId: "drw_p0_01",
            pdf: ["https://example.com/drawings/plinth_struct.pdf"],
            dwg: [],
            drawingVersion: [],
            slabCheckId: "chk_p0_01",
            submitReport: "1",
            issuse: "1",
            verify: "1",
            isSelected: false,
          ),
        ],
        slabCheck: [
          SlabCheck(
            slabCheckTitle: "Plinth Beam Formwork & Alignment",
            slabCheckId: "sc_04",
            isSetupDone: "1",
            slabCheckStatusOk: "1",
            slabCheckStatusIssue: "0",
            clickActive: "1",
          ),
          SlabCheck(
            slabCheckTitle: "Plinth Concrete Cube Test 28-Day Result",
            slabCheckId: "sc_05",
            isSetupDone: "1",
            slabCheckStatusOk: "0",
            slabCheckStatusIssue: "1",
            clickActive: "1",
          ),
        ],
      ),
      SlabDetail(
        slabId: "slb_003",
        slabNo: "1st Floor Slab",
        estCompletDate: "15 Feb 2026",
        completedDate: "",
        completTitile: "In Progress - Reinforcement Phase",
        errorTitle: "Reinforcement Cover Block Misalignment",
        completStatus: "0",
        issueReport: "2",
        issueSlabReport: "2",
        orderSupplies: "1",
        checkListFlag: "0",
        drawings: [
          Drawing(
            drawingTitle: "1st Floor Slab Beam Layout & Schedule",
            drawingId: "drw_f1_01",
            pdf: ["https://example.com/drawings/f1_beam.pdf"],
            dwg: ["https://example.com/drawings/f1_beam.dwg"],
            drawingVersion: [],
            slabCheckId: "chk_f1_01",
            submitReport: "1",
            issuse: "1",
            verify: "1",
            isSelected: false,
          ),
          Drawing(
            drawingTitle: "1st Floor Electrical Conduit Sleeves Layout",
            drawingId: "drw_f1_02",
            pdf: ["https://example.com/drawings/f1_elec.pdf"],
            dwg: [],
            drawingVersion: [],
            slabCheckId: "chk_f1_02",
            submitReport: "0",
            issuse: "1",
            verify: "0",
            isSelected: false,
          ),
        ],
        slabCheck: [
          SlabCheck(
            slabCheckTitle: "1st Floor Shuttering Line & Level Verification",
            slabCheckId: "sc_06",
            isSetupDone: "1",
            slabCheckStatusOk: "1",
            slabCheckStatusIssue: "0",
            clickActive: "1",
          ),
          SlabCheck(
            slabCheckTitle: "1st Floor Steel Reinforcement & Lap Lengths",
            slabCheckId: "sc_07",
            isSetupDone: "1",
            slabCheckStatusOk: "0",
            slabCheckStatusIssue: "1",
            clickActive: "1",
          ),
          SlabCheck(
            slabCheckTitle: "Pre-Concreting MEP Clearance Checklist",
            slabCheckId: "sc_08",
            isSetupDone: "0",
            slabCheckStatusOk: "0",
            slabCheckStatusIssue: "0",
            clickActive: "1",
          ),
        ],
      ),
    ];
  } else if (currentOffset == '10') {
    mockSlabs = [
      SlabDetail(
        slabId: "slb_004",
        slabNo: "2nd Floor Slab",
        estCompletDate: "28 Feb 2026",
        completedDate: "",
        completTitile: "Shuttering Underway",
        errorTitle: "",
        completStatus: "0",
        issueReport: "0",
        issueSlabReport: "0",
        orderSupplies: "1",
        checkListFlag: "0",
        drawings: [
          Drawing(
            drawingTitle: "2nd Floor Slab Structural Drawing",
            drawingId: "drw_f2_01",
            pdf: ["https://example.com/drawings/f2_struct.pdf"],
            dwg: [],
            drawingVersion: [],
            slabCheckId: "chk_f2_01",
            submitReport: "0",
            issuse: "1",
            verify: "1",
            isSelected: false,
          ),
        ],
        slabCheck: [
          SlabCheck(
            slabCheckTitle: "2nd Floor Staging & Scaffolding Stability",
            slabCheckId: "sc_09",
            isSetupDone: "1",
            slabCheckStatusOk: "1",
            slabCheckStatusIssue: "0",
            clickActive: "1",
          ),
        ],
      ),
      SlabDetail(
        slabId: "slb_005",
        slabNo: "3rd Floor Slab",
        estCompletDate: "15 Mar 2026",
        completedDate: "",
        completTitile: "Scheduled",
        errorTitle: "",
        completStatus: "0",
        issueReport: "0",
        issueSlabReport: "0",
        orderSupplies: "0",
        checkListFlag: "0",
        drawings: [
          Drawing(
            drawingTitle: "3rd Floor Slab Key Plan",
            drawingId: "drw_f3_01",
            pdf: ["https://example.com/drawings/f3_key.pdf"],
            dwg: [],
            drawingVersion: [],
            slabCheckId: "chk_f3_01",
            submitReport: "0",
            issuse: "0",
            verify: "0",
            isSelected: false,
          ),
        ],
        slabCheck: [
          SlabCheck(
            slabCheckTitle: "3rd Floor Pre-Execution Quality Audit",
            slabCheckId: "sc_10",
            isSetupDone: "0",
            slabCheckStatusOk: "0",
            slabCheckStatusIssue: "0",
            clickActive: "1",
          ),
        ],
      ),
    ];
  }

  return RccStructureDataResponse(
    errorCode: "0",
    msg: "Success",
    towarList: mockTowers,
    blockFlag: "1",
    slabDetails: mockSlabs,
    averagedata: "12",
    offset: currentOffset == '0' ? '10' : '20',
  );
}

/// Returns mock data for Revision R.C.C / Masonry Structure matching [DrawingDetailsResponse].
DrawingDetailsResponse getMockRevisionData({
  String? drawingId,
  String? slabId,
  String? documentPath,
}) {
  return DrawingDetailsResponse(
    errorCode: "0",
    msg: "Success",
    documentPath: documentPath ?? "RCC",
    drawingFlag: "1",
    drawings: [
      DrawingVersion(
        name: "Rev 1.2",
        pdfRemark: "Updated structural beam layout & reinforcement stirrup spacing as per consultant review.",
        dwgRemark: "CAD drawing revised for column grid line C-4.",
        pdf: [
          PdfElement(
            slabDrawingImgName: "RCC_Slab_Layout_Rev1.2.pdf",
            drawingDate: "28 Feb 2026",
          ),
        ],
        dwg: [
          PdfElement(
            slabDrawingImgName: "RCC_Slab_Layout_Rev1.2.dwg",
            drawingDate: "28 Feb 2026",
          ),
        ],
      ),
      DrawingVersion(
        name: "Rev 1.1",
        pdfRemark: "Incorporated duct sleeve openings for MEP services.",
        dwgRemark: "Updated DWG drawing layout v1.1.",
        pdf: [
          PdfElement(
            slabDrawingImgName: "RCC_Slab_Layout_Rev1.1.pdf",
            drawingDate: "15 Feb 2026",
          ),
        ],
        dwg: [
          PdfElement(
            slabDrawingImgName: "RCC_Slab_Layout_Rev1.1.dwg",
            drawingDate: "15 Feb 2026",
          ),
        ],
      ),
      DrawingVersion(
        name: "Rev 1.0",
        pdfRemark: "Initial structural drawing release approved for execution.",
        dwgRemark: "Initial CAD release v1.0.",
        pdf: [
          PdfElement(
            slabDrawingImgName: "RCC_Slab_Layout_Rev1.0.pdf",
            drawingDate: "01 Feb 2026",
          ),
        ],
        dwg: [],
      ),
    ],
  );
}

/// Returns mock data for Issue RCC Report Screen matching [RccIssueReportsData].
RccIssueReportsData getMockIssueReportData() {
  return RccIssueReportsData(
    response: RccIssueReportsDataResponse(
      errorCode: "0",
      msg: "Success",
      slabIssueReport: [
        SlabIssueReport(
          mstSlabIssuerReportId: "issue_101",
          issueIn: "drw_f1_01",
          issusInName: "1st Floor Shuttering & Reinforcement Layout",
          reports: "Honeycomb defect observed on column C-4 after formwork removal. Patch work & grouting required.",
          extracomment: "",
          submitdate: "25 Feb 2026 10:30 AM",
          resolvedate: "",
          userIdFk: "usr_01",
          issueResolve: "0",
          reportBy: "Rajesh Kumar (Site Inspector)",
          reportedBy: "Rajesh Kumar",
          reportToName: "Vikram Sharma (Structural Lead), Amit Patel (Project Manager)",
          reportTo: "rep_01,rep_02",
          issueResolveBtn: "0",
          resolvedDate: "",
          empname: "",
          imagePath: "https://via.placeholder.com",
          image: [],
          slabVedio: [],
        ),
        SlabIssueReport(
          mstSlabIssuerReportId: "issue_102",
          issueIn: "drw_f1_01",
          issusInName: "1st Floor Shuttering & Reinforcement Layout",
          reports: "Electrical conduit sleeves misaligned at slab grid B-2. Corrected as per revised MEP overlay.",
          extracomment: "",
          submitdate: "20 Feb 2026 04:15 PM",
          resolvedate: "22 Feb 2026 02:00 PM",
          userIdFk: "usr_02",
          issueResolve: "1",
          reportBy: "Sunil Verma (MEP Consultant)",
          reportedBy: "Sunil Verma",
          reportToName: "Vikram Sharma (Structural Lead)",
          reportTo: "rep_01",
          issueResolveBtn: "1",
          resolvedDate: "22 Feb 2026 02:00 PM",
          empname: "Vikram Sharma",
          imagePath: "https://via.placeholder.com",
          image: [],
          slabVedio: [],
        ),
      ],
    ),
  );
}


/// Returns mock dropdown data for Report To selections matching [RccIssueReportDropdownData].
RccIssueReportDropdownData getMockIssueReportDropdownData() {
  return RccIssueReportDropdownData(
    response: RccIssueReportDropdownDataResponse(
      errorCode: "0",
      msg: "Success",
      issueIn: [
        IssueIn(issueInId: "drw_f1_01", issueInName: "1st Floor Structural Drawing"),
      ],
      reportTo: [
        ReportTo(reportToId: "rep_01", reportToName: "Vikram Sharma (Structural Lead)", isSelected: false),
        ReportTo(reportToId: "rep_02", reportToName: "Amit Patel (Project Manager)", isSelected: false),
        ReportTo(reportToId: "rep_03", reportToName: "Suresh Menon (Quality Head)", isSelected: false),
        ReportTo(reportToId: "rep_04", reportToName: "Pankaj Joshi (Site Engineer)", isSelected: false),
      ],
    ),
  );
}

/// Returns mock data for Slab Status Screen matching [GetLabReportOkResponse].
GetLabReportOkResponse getMockLabReportOkData() {
  return GetLabReportOkResponse(
    errorCode: "0",
    msg: "Success",
    isExpire: "0",
    slabReport: [
      SlabReport(
        slabReportOkId: "slab_ok_01",
        slabStartDate: "15 Feb 2026",
        estCompletDate: "28 Feb 2026",
        submitDate: "28 Feb 2026 05:30 PM",
        slabReportReview: "Ideal Work - Inspection passed and approved for next stage execution.",
        imagePath: "https://via.placeholder.com",
        image: [],
        reportVedio: [],
      ),
    ],
  );
}

/// Returns mock data for Excavation Screen matching [GetExcavationListResponse].
GetExcavationListResponse getMockExcavationListData() {
  return GetExcavationListResponse(
    errorCode: "0",
    msg: "Success",
    offset: "0",
    bottomBar: [
      BottomBar(id: "", name: "All", value: "35.50", truckValue: "4"),
      BottomBar(id: "1", name: "Royalty", value: "20.00", truckValue: "2"),
      BottomBar(id: "2", name: "Debris", value: "15.50", truckValue: "2"),
    ],
    filterBar: [
      BottomBar(id: "", name: "All Sizes", value: "35.50", truckValue: "4"),
      BottomBar(id: "101", name: "10 CUM Dumper", value: "20.00", truckValue: "2"),
      BottomBar(id: "102", name: "6 CUM Tipper", value: "15.50", truckValue: "2"),
    ],
    finalExcavalionList: [
      FinalExcavalionList(
        mstExcavationId: "exc_01",
        vehicelType: "3",
        vehilceTypeName: "10 CUM Dumper",
        vehicelNo: "MH-04-JK-4821",
        truckSizeName: "10 CUM",
        excavationChallanNo: "EX-94821",
        cumLoadValue: "10.00",
        typeRoyalityName: "Royalty Brass",
        userName: "Pankaj Joshi",
        excavationUpdatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      FinalExcavalionList(
        mstExcavationId: "exc_02",
        vehicelType: "3",
        vehilceTypeName: "10 CUM Dumper",
        vehicelNo: "MH-04-JK-4822",
        truckSizeName: "10 CUM",
        excavationChallanNo: "EX-94822",
        cumLoadValue: "10.00",
        typeRoyalityName: "Royalty Brass",
        userName: "Pankaj Joshi",
        excavationUpdatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      FinalExcavalionList(
        mstExcavationId: "exc_03",
        vehicelType: "1",
        vehilceTypeName: "JCB Excavator 3DX",
        hiringCharges: "4500",
        shiftRequired: "1 Shift (8 Hours)",
        excavationUsedFor: "Basement Soft Rock Excavation",
        excavationChallanNo: "EX-94823",
        userName: "Amit Patel",
        excavationUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  );
}

/// Returns mock default data for Excavation Add Vehicle screen matching [GetDefaultExcavationListResponse].
GetDefaultExcavationListResponse getMockDefaultExcavationData() {
  return GetDefaultExcavationListResponse(
    errorCode: "0",
    msg: "Success",
    vehicleType: [
      TruckSize(id: "3", name: "Dumper Truck"),
      TruckSize(id: "1", name: "JCB Excavator"),
      TruckSize(id: "2", name: "Poclain Heavy Machine"),
    ],
    truckSize: [
      TruckSize(id: "101", name: "10 CUM Dumper", value: "10"),
      TruckSize(id: "102", name: "6 CUM Tipper", value: "6"),
    ],
    typeRoyality: [
      TruckSize(id: "1", name: "Royalty Brass"),
      TruckSize(id: "2", name: "Debris Removal"),
    ],
  );
}

/// Returns mock checklist list data for [CheckListScreen].
GetAllCheckListResponse getMockGetAllCheckListResponse() {
  return GetAllCheckListResponse(
    errorCode: "0",
    msg: "Success",
    editFlag: "1",
    webCheckListUrl: "",
    checkList: [
      CheckList(
        userName: "Vikram Sharma (Site Lead)",
        companyName: "Stallion Infrastructure",
        projectSlabCheckId: "chk_101",
        projectSlabCheckNo: "CHK-2026-001",
        projectSlabCheckDate: "10 Mar 2026 11:30 AM",
        salbCheckPdf: "slab_check_101.pdf",
        projectSlabSaveStatus: "1",
        projectSlabRemark: "Shuttering alignment and reinforcement spacing verified as per structural drawing Rev 1.2.",
        checklistType: "RCC Detailed Checklist",
        categoryName: "Reinforcement & Formwork",
        slabCheckDocument: [
          SlabCheckDocument(
            documentId: "doc_101",
            documentName: "shuttering_inspection.pdf",
          ),
          SlabCheckDocument(
            documentId: "doc_102",
            documentName: "rebar_spacing_site.jpg",
          ),
        ],
      ),
      CheckList(
        userName: "Amit Patel (Project Engineer)",
        companyName: "Stallion Infrastructure",
        projectSlabCheckId: "chk_102",
        projectSlabCheckNo: "CHK-2026-002",
        projectSlabCheckDate: "09 Mar 2026 04:15 PM",
        salbCheckPdf: "slab_check_102.pdf",
        projectSlabSaveStatus: "0",
        projectSlabRemark: "Draft saved - Pending final MEP clearance check.",
        checklistType: "Pre-Concreting Checklist",
        categoryName: "MEP & Electrical Conduits",
        slabCheckDocument: [
          SlabCheckDocument(
            documentId: "doc_103",
            documentName: "conduit_layout_draft.png",
          ),
        ],
      ),
      CheckList(
        userName: "Suresh Menon (Quality Inspector)",
        companyName: "Stallion Quality Corp",
        projectSlabCheckId: "chk_103",
        projectSlabCheckNo: "CHK-2026-003",
        projectSlabCheckDate: "05 Mar 2026 02:00 PM",
        salbCheckPdf: "slab_check_103.pdf",
        projectSlabSaveStatus: "1",
        projectSlabRemark: "Concrete slump test passed. Pour approved for 350 cu.m.",
        checklistType: "Concreting Execution Checklist",
        categoryName: "Concrete Mix & Pouring",
        slabCheckDocument: [],
      ),
    ],
  );
}

/// Returns mock detailed checklist response for [CreateCheckList] and [CreateNewCheckList].
SlabCheckListResponse getMockSlabCheckListResponse() {
  return SlabCheckListResponse(
    errorCode: "0",
    msg: "Success",
    remark: "All initial checks verified by site engineer.",
    projectSlabCheckId: "chk_101",
    checkListFlag: "0",
    slabCheckList: [
      SlabCheckList(
        id: "cat_01",
        name: "1. Formwork & Shuttering Checks",
        isCollapse: "0",
        list: [
          ListElement(
            id: "item_101",
            name: "Formwork alignment and verticality check",
            checkFlag: "1",
            checkRemark: "Satisfactory alignment observed",
            disabled: false,
          ),
          ListElement(
            id: "item_102",
            name: "De-shuttering oil applied uniformly",
            checkFlag: "1",
            checkRemark: "Approved release agent used",
            disabled: false,
          ),
          ListElement(
            id: "item_103",
            name: "Formwork joint sealing & gap check",
            checkFlag: "0",
            checkRemark: "",
            disabled: false,
          ),
        ],
      ),
      SlabCheckList(
        id: "cat_02",
        name: "2. Reinforcement & Rebar Details",
        isCollapse: "0",
        list: [
          ListElement(
            id: "item_201",
            name: "Main steel bar diameter & spacing",
            checkFlag: "1",
            checkRemark: "Matches Rev 1.2 drawing specifications",
            disabled: false,
          ),
          ListElement(
            id: "item_202",
            name: "Cover blocks placement (25mm slab / 40mm beam)",
            checkFlag: "1",
            checkRemark: "PVC cover blocks installed",
            disabled: false,
          ),
          ListElement(
            id: "item_203",
            name: "Lap length and stagger rebar joints",
            checkFlag: "2",
            checkRemark: "Needs minor re-binding on East corner",
            disabled: false,
          ),
        ],
      ),
      SlabCheckList(
        id: "cat_03",
        name: "3. MEP & Conduit Services Clearance",
        isCollapse: "0",
        list: [
          ListElement(
            id: "item_301",
            name: "Electrical conduit routing & fan box locations",
            checkFlag: "0",
            checkRemark: "",
            disabled: false,
          ),
          ListElement(
            id: "item_302",
            name: "Plumbing sleeves & floor drain cutouts",
            checkFlag: "0",
            checkRemark: "",
            disabled: false,
          ),
        ],
      ),
    ],
    slabCheckListEdited: [],
  );
}





