class AppUrl {
  // Set to true for the new email/password backend, false for the old name/mobile OTP backend
  static const bool useNewBackend = true;

  // Base URLs
  static const String oldBaseURL = "https://skrite.com/stallion-build-test/";
  static const String newBaseURL = "https://api.dev.batman.co.in/";

  static const String baseURL = useNewBackend ? newBaseURL : oldBaseURL;

  // New Auth Route
  static const String newLoginUrl = "${newBaseURL}auth/login";
  static const String sendOtpUrl = "${newBaseURL}auth/send-otp";
  static const String verifyOtpUrl = "${newBaseURL}auth/verify-otp";
  static const String authMe = "${newBaseURL}auth/me";
  // Multi-developer project listing (returns modules[] per project)
  static const String getMobileProjectList = "${newBaseURL}projects/mobile";
  static String getTowerTaskDashboard(String towerId) => "${newBaseURL}tasks/tower/$towerId/dashboard";
  static String getTowerTaskList(String towerId) => "${newBaseURL}tasks/tower/$towerId/list";
  static String getTowerMeetings(String towerId) => "${newBaseURL}tasks/tower/$towerId/meetings";
  static String createTowerMeeting(String towerId) => "${newBaseURL}tasks/tower/$towerId/meetings";
  static String addTaskToMeeting(String meetingId) => "${newBaseURL}tasks/meetings/$meetingId/tasks";
  static String getMeetingDetailsAndTasks(String meetingId) => "${newBaseURL}tasks/meetings/$meetingId/tasks";
  static String updateMeetingParticipants(String meetingId) => "${newBaseURL}tasks/meetings/$meetingId/participants";
  static String shareMeeting(String meetingId) => "${newBaseURL}tasks/meetings/$meetingId/share";
  static String deleteMeeting(String meetingId) => "${newBaseURL}tasks/meetings/$meetingId";
  static String deleteTask(String taskId) => "${newBaseURL}tasks/$taskId";
  static String getTaskDetails(String taskId) => "${newBaseURL}tasks/$taskId";
  static String getProjectUsers(String projectId) => "${newBaseURL}users/project/$projectId";
  static String createTowerTask(String towerId) => "${newBaseURL}tasks/tower/$towerId";
  static String extendTask(String taskId) => "${newBaseURL}tasks/$taskId/extend";
  static String completeTask(String taskId) => "${newBaseURL}tasks/$taskId/complete";
  static String getSlabAuthorities(String slabId) => "${newBaseURL}rcc/slabs/$slabId/authorities";
  static const String postSlabAuthorities = "${newBaseURL}rcc/slab-authorities";
  static String getTowerDeveloperRccCount(String towerId) => "${newBaseURL}rcc/towers/$towerId/slab-authorities/developer-rcc-count";
  static const String getRccSlabIssues = "${newBaseURL}rcc/slab-issues";
  static const String createSlabIssue = "${newBaseURL}rcc/create-slab-issue";
  static const String updateIssueStatus = "${newBaseURL}rcc/update-status";

  // Excavation & Debris Endpoints
  static String getTowerExcavations(String towerId) => "${newBaseURL}rcc/towers/$towerId/excavations";
  static String getTowerSlabs(String towerId) => "${newBaseURL}rcc/towers/$towerId/slabs";
  static const String getTruckSizes = "${newBaseURL}rcc/truck-sizes";
  static const String getVehicleTypes = "${newBaseURL}rcc/vehicle-types";
  static const String getRoyaltyTypes = "${newBaseURL}rcc/royalty-types";
  static const String createExcavationEntry = "${newBaseURL}rcc/excavation";

  // RCC Checklist Endpoints
  static String getRccChecklistsPdf(String slabId) => "${newBaseURL}rcc/checklists/pdf?slab_id=$slabId";
  static String getSlabSubmissions(String slabId) => "${newBaseURL}rcc/slabs/$slabId/submissions";
  static String getSlabChecklistTypesGrouped(String towerId) => "${newBaseURL}rcc/get-slab-checklist-types-grouped?tower_id=$towerId";
  static String getLatestSlabSubmission(String slabId) => "${newBaseURL}rcc/slabs/$slabId/fetch-latest-submission";
  static String postSlabSubmission(String slabId) => "${newBaseURL}rcc/slabs/$slabId/submissions";
  static String putSlabSubmission(String slabId, String submissionId) => "${newBaseURL}rcc/slabs/$slabId/submissions/$submissionId";
  static String deleteSubmissionFile(String fileId) => "${newBaseURL}rcc/slab-submissions/files/$fileId";

  // RCC Daily Progress Report (DPR) Endpoints
  static String getDprsForSlab(String slabId, {int page = 1, int limit = 20, String? fromDate, String? toDate}) {
    String url = "${newBaseURL}rcc/get-dprs?slab_id=$slabId&page=$page&limit=$limit";
    if (fromDate != null && fromDate.isNotEmpty) url += "&from_date=$fromDate";
    if (toDate != null && toDate.isNotEmpty) url += "&to_date=$toDate";
    return url;
  }
  static String getProjectContractors(String projectId) => "${newBaseURL}dev/contractor-management/project/$projectId";
  static String getDprTypes(String projectId) => "${newBaseURL}rcc/dpr-types/project/$projectId";
  static const String dprPreviewPdf = "${newBaseURL}rcc/dpr/preview";
  static const String createDpr = "${newBaseURL}rcc/create-dpr";
  static String updateDpr(String submissionId) => "${newBaseURL}rcc/update-dpr/$submissionId";
  static String deleteDprDocument(String docId) => "${newBaseURL}rcc/dpr-documents/$docId";

  // RCC DPR Activities / Tasks Endpoints
  static String getDprActivities(String towerId, {String? slabId}) =>
      slabId != null && slabId.isNotEmpty
          ? "${newBaseURL}rcc/dpr-activities/$towerId?slab_id=$slabId"
          : "${newBaseURL}rcc/dpr-activities/$towerId";
  static String extendDprActivityDeadline(String dprTaskId) =>
      "${newBaseURL}rcc/dpr-activities/$dprTaskId/extend-deadline";
  static String completeDprActivity(String dprTaskId) =>
      "${newBaseURL}rcc/dpr-activities/$dprTaskId/complete";
  // Purchase Order Requests API (New REST Backend)
  static const String poVendorTypes = "${newBaseURL}vendor/po-vendor-types";
  static const String poMeasuringUnits = "${newBaseURL}vendor/po-measuring-units";
  static const String purchaseOrderRequests = "${newBaseURL}purchase-order-requests";
  static String getPurchaseOrderRequests(String towerId, {int page = 1, int limit = 20}) =>
      "${newBaseURL}purchase-order-requests?page=$page&limit=$limit&tower_id=$towerId";
  static String purchaseOrderRequestById(String id) =>
      "${newBaseURL}purchase-order-requests/$id";
  static String purchaseOrderPreviewPdf(String id) =>
      "${newBaseURL}purchase-order-requests/$id/preview";

  // Workspace switch — always called with master token
  static const String switchByProject = "${newBaseURL}auth/mobile/switch-by-project";
  static const String logoutAllDevicesUrl = "${baseURL}developers/logout-all-devices";

  //Webservices URL
  static const String globalRegisterInviteUrl = "${baseURL}developer-invite/";
  static const String globalProfileImgURLThumbs =
      "${baseURL}media/backend/userfiles/";
  static const String globalDwg = "${baseURL}media/backend/images/drawing/";

  static const String checkForceUpdate = "${baseURL}ws-force-update-popup";
  static const String loginOtpRequest = "${baseURL}ws-mobile-no-exit";
  static const String projectPmsStructureMove =
      "${baseURL}ws-project-pms-structure-move";

  static const String verifyOtpRequest =
      "${baseURL}ws-mobile-no-with-otp-login";
  static const String getProjectListRequest =
      "${baseURL}ws-get-new-projects-details";
  static const String getTowerListByProjectiId =
      "${baseURL}ws-get-tower-list-by-projecti-id";
  static const String brokerMeetingList = "${baseURL}ws-broker-meeting-list";
  static const String brokerMeetingAdd = "${baseURL}ws-broker-meeting-add";
  static const String getProjectWorkProgressListRequest =
      "${baseURL}ws-project-management-web";
  static const String getRccStructureDetailsRequest =
      "${baseURL}ws-project-rcc-slab-new";
  static const String getPoVendorQuotationPdf =
      "${baseURL}ws-po-vendor-quotation-pdf";
  static const String getDprTaskDetails = "${baseURL}ws-get-dpr-task-details";
  static const String getDprTaskList = "${baseURL}ws-get-dpr-task-list";
  static const String wsProjectRccSlabDetailsNew =
      "${baseURL}ws-project-rcc-slab-details-new";
  static const String wsProjectMasonrySlabDetailsNew =
      "${baseURL}ws-project-masonry-details-new";
  static const String getDefaultExcavationValue =
      "${baseURL}ws-default-excavation-value";
  static const String getExcavationList = "${baseURL}ws-excavation-list";
  static const String setDiagramRequest = "${baseURL}ws-set-diagram-request";
  static const String getProjectMasonry =
      "${baseURL}ws-get-project-masonry-new";
  static const String sopList = "${baseURL}ws-sop-list";

  static const String sopGetDetails = "${baseURL}ws-sop-get-details";
  static const String sopUserList = "${baseURL}ws-sop-user-list";

  static const String getAllLegal = "${baseURL}ws-get-project-legal";

  static const String getAllSubLegal = "${baseURL}ws-get-project-sub-legal";

  static const String setLegalLegal = "${baseURL}ws-set-legal-remark";

  static const String setSubLegalLegal = "${baseURL}ws-set-sub-legal-remark";

  static const String updateLegalStatus = "${baseURL}ws-update-legal-status";
  static const String getRccStructureDropDownIssueReportRequest =
      "${baseURL}ws-get-issue-in-type";
  static const String getProjectBudgetCategory =
      "${baseURL}ws-get-budget-cateogries";

  static const String getProjectBudgetWoCategory =
      "${baseURL}ws-get-wo-budget-cateogries";

  static const String getProjectBudgetVenderList =
      "${baseURL}ws-get-budget-vender-list";
  static const String getProjectBudgetLegalList =
      "${baseURL}ws-get-statutory-details";
  static const String getProjectBudgetContractList =
      "${baseURL}ws-get-budget-contrators-list";
  static const String getProjectBudgetList = "${baseURL}ws-get-budget-list";
  static const String getProjectBudgetWoList =
      "${baseURL}ws-get-wo-budget-list";

  static const String getProjectBudgetStatutoryList =
      "${baseURL}ws-get-budget-statutory";

  static const String getProjectBudget = "${baseURL}ws-get-project-budget";
  static const String deleteTempFile = "${baseURL}ws-delet-temp-file";

  static const String getProfitLoss = "${baseURL}ws-get-profitability-list";
  static const String getDeveloperPoDashboard =
      "${baseURL}ws-developer-po-dashboard";

  static const String caseFlowList = "${baseURL}ws-case-flow-list";

  static const String getDeveloperRawMaterialDashboard =
      "${baseURL}ws-developer-raw-material-dashboard";

  static const String getDeveloperWoDashboard =
      "${baseURL}ws-developer-wo-dashboard";

  static const String getTenantPaymentList = "${baseURL}ws-tenant-payment-list";
  static const String getwsUserTaskById = "${baseURL}ws-user-task-by-id-new";

  static const String taskCompletedByUser =
      "${baseURL}ws-task-completed-by-user";

  static const String setDprCompletedTask =
      "${baseURL}ws-set-dpr-completed-task";

  static const String meetingByUserId = "${baseURL}ws-list-metting-by-user-new";
  static const String mettingDetailsByUser =
      "${baseURL}ws-metting-details-by-user";

  static const String createNewMetting = "${baseURL}ws-creat-new-metting";
  static const String setDprCompletedTaskNew =
      "${baseURL}ws-set-dpr-completed-task-new";
  static const String taskExtendDateNew = "${baseURL}ws-task-extend-date-new";
  static const String taskExtendDetails = "${baseURL}ws-task-extend-details";
  static const String getDprExtendDetails =
      "${baseURL}ws-get-dpr-extend-details";

  static const String taskExtendDate = "${baseURL}ws-task-extend-date";
  static const String getMemberByProject = "${baseURL}ws-get-member-by-project";
  static const String deleteMeetingById =
      "${baseURL}ws-delete-metting-task-by-id";
  static const String getFinishing = "${baseURL}ws-finishining-list";
  static const String getFinishingExteriorNew =
      "${baseURL}ws-get-finishing-exterior-list";
  static const String setFinishingTypeFlag =
      "${baseURL}ws-set-finishing-type-flag";
  static const String setFinishingReadyPosition =
      "${baseURL}ws-set-finishing-ready-position";
  static const String manageFinishingWorkType =
      "${baseURL}ws-manage-finishing-work-type";
  static const String setManageFinishingWorkType =
      "${baseURL}ws-set-finishing-work-type";
  static const String getFinishingInd = "${baseURL}ws-get-finishing-qty-list";
  static const String wsConsumeDocumentRemove =
      "${baseURL}ws-consume-document-remove";

  static const String getFinishingListing =
      "${baseURL}ws-finishining-flat-details";
  static const String getFinishingInteriorList =
      "${baseURL}ws-get-finishing-interior-list";
  static const String setFinishingExteriorQuantification =
      "${baseURL}ws-set-finishing-exterior-quantification";
  static const String setFinishingInteriorQuantification =
      "${baseURL}ws-set-finishing-interior-quantification";
  static const String finishingInteriorQuantification =
      "${baseURL}ws-finishing-interior-quantification";

  static const String getFinishingExteriorList =
      "${baseURL}ws-get-finishing-exterior-list";
  static const String participaintAddByMeeting =
      "${baseURL}ws-participaint-add-by-metting";
  static const String shareMettingWithOther =
      "${baseURL}ws-share-metting-with-other";

  static const String addNewTaskByMeeting =
      "${baseURL}ws-add-new-task-by-metting";

  static const String getRccStructureIssueReportRequest =
      "${baseURL}ws-get-slab-issue-report";
  static const String setSlabIssueSolve = "${baseURL}ws-slab-issue-slove";

  static const String getMasonryIssueReportRequest =
      "${baseURL}ws-get-masonry-issue-report";

  static const String getProjectDprList = "${baseURL}ws-get-project-dpr-list";
  static const String getProjectFinishingDprList =
      "${baseURL}ws-get-project-finishing-dpr-list";

  static const String getProjectMprList =
      "${baseURL}ws-project-monthly-repot-list";

  static const String getCheckStatus =
      "${baseURL}ws-project-get-slab-check-list";
  static const String projectGetMasnoryCheckList =
      "${baseURL}ws-project-get-masnory-check-list";

  static const String projectGetFinishingCheckList =
      "${baseURL}ws-project-get-finishing-check-list";

  static const String getslabCheckList =
      "${baseURL}ws-project-slab-check-list-new";
  static const String projectMasnoryCheckListNew =
      "${baseURL}ws-project-masnory-check-list-new";

  static const String projectfinishingCheckListNew =
      "${baseURL}ws-project-finishing-check-list-new";

  static const String projectInventoryList =
      "${baseURL}ws-project-inventory-list";

  static const String slabCheckDeleteDocument =
      "${baseURL}ws-slab-check-document-delect";

  static const String setslabCheckList = "${baseURL}ws-project-slab-check";
  static const String projectMasnoryCheck =
      "${baseURL}ws-project-masnory-check";

  static const String projectfinishingCheck =
      "${baseURL}ws-project-finishing-check";

  static const String setFinishingQty = "${baseURL}ws-set-finishing-qty";
  static const String wsSetPoHandSign = "${baseURL}ws-set-po-hand-sign";
  static const String wsSetWoHandSign = "${baseURL}ws-set-wo-hand-sign";

  static const String setMprList = "${baseURL}ws-project-monthly-set-report";

  static const String getRccBookingDetails = "${baseURL}ws-rcc-booking-details";
  static const String getLabSlabReport = "${baseURL}ws-get-lab-slab-report";
  static const String getArchitechCertificateReport =
      "${baseURL}ws-get-architech-certificate-report";

  static const String getProjectDprContractor =
      "${baseURL}ws-get-project-dpr-contractor";
//   static const String getProjectDprContractor =
//       "${baseURL}ws-get-project-dpr-contractor";
  static const String getFinishingCompanyList =
      "${baseURL}ws-get-finishing-company-list";
  static const String wsDprDocumentRemove = "${baseURL}ws-dpr-document-remove";
  static const String getProjectSaveDpr = "${baseURL}ws-project-dpr-details";
  static const String getProjectOverView = "${baseURL}ws-project-overview";
  //new
  static const String projectRccmodel = "${baseURL}ws-project-rccmodel";
  static const String projectPurchaseordermodel =
      "${baseURL}ws-project-purchaseordermodel";

  static const String projectWorkordermodel =
      "${baseURL}ws-project-workordermodel";

  static const String projectPermissionmodel =
      "${baseURL}ws-project-permissionmodel";

  static const String projectBudgetmodel = "${baseURL}ws-project-budgetmodel";

  static const String projectSalesmodel = "${baseURL}ws-project-salesmodel";

  static const String getProjectBudgetOverview =
      "${baseURL}ws-project-budget-overview";
  static const String getCompanyProjectDue =
      "${baseURL}ws-wo-company-payment-due";
  static const String getVenderProjectDue =
      "${baseURL}ws-po-vender-payment-due";

  static const String getGetDefaultWoCreate =
      "${baseURL}ws-get-default-wo-create";
  static const String getWsslabmasonrystructure =
      "${baseURL}ws-slab-masonry-structure";
  static const String getWsworkorderpreview =
      "${baseURL}ws-preview-wo-percentage";
  static const String setworkorderpercentage =
      "${baseURL}ws-set-wo-by-percentage";
  static const String setworkorderquantitypreview =
      "${baseURL}ws-pre-view-wo-created";
  static const String setworkorderquantity = "${baseURL}ws-set-wo-by-quantity";
  static const String getprojectaccountmanagment =
      "${baseURL}ws-po-details-by-project";
  static const String getGetPoChallan = "${baseURL}ws-get-po-challan";
  static const String getprojectaccountmanagmentdueoverdue =
      "${baseURL}ws-po-vender-payment-due-optimize";
  static const String getNotifications =
      "${baseURL}ws-get-notification-details";
  static const String getprojectworequested = "${baseURL}ws-get-wo-by-status";
  static const String getslabreportok = "${baseURL}ws-get-slab-report-ok";
  static const String getmasonryreportok = "${baseURL}ws-get-masonry-report-ok";

  static const String getprojectwopreview = "${baseURL}ws-get-wo-structure";
  static const String slaseLeadPdf = "${baseURL}ws-slaseLeadPdf";

  static const String getdprpreviewhtml = "${baseURL}ws-dpr-preview-html";
  static const String setdprpreviewhtml = "${baseURL}ws-set-project-dpr";
  static const String setProjectFinishingDpr =
      "${baseURL}ws-set-project-finishing-dpr";

  static const String setprojectwostatus =
      "${baseURL}ws-set-contractor-wo-status";
  static const String getprojectmycontracts =
      "${baseURL}ws-get-group-contractor-list";
  static const String getGroupContractorCategoryList =
      "${baseURL}ws-get-group-contractor-category-list";
  static const String getprojectmycontractscompanylist =
      "${baseURL}ws-get-group-company-contractor-list";

  // "${baseURL}ws-get-company-contractor-list-new";
  static const String getprojectworkorderdetails =
      "${baseURL}ws-get-contractor-details";
  static const String getcompletedpercentagelist =
      "${baseURL}ws-list-wo-quatification";
  static const String wssetworkordercompletedpercentage =
      "${baseURL}ws-set-wo-quatification";

  static const String wsUploadPermisionDiagram =
      "${baseURL}ws-upload-permission-diagram";

  static const String wsSopDocUpload = "${baseURL}ws-sop-doc-upload";

  static const String wsAcquisitionFileUpload =
      "${baseURL}ws-acquisition-file-upload";

  static const String wsSetSlabReportOk = "${baseURL}ws-set-slab-report-ok";
  static const String wsSetMasonryReportOk =
      "${baseURL}ws-set-masonry-report-ok";

  static const String wsSetSlabReport = "${baseURL}ws-set-lab-slab-report";
  static const String setArchitechCertificateReport =
      "${baseURL}ws-set-architech-certificate-report";

  static const String legalDiagramUpload = "${baseURL}ws-upload-legal-diagram";
  static const String subLegalDiagramUpload =
      "${baseURL}ws-upload-sublegal-diagram";

  static const String wsSetSlabIssueReport =
      "${baseURL}ws-set-slab-issue-report";
  static const String wsMasonrySlabIssueReport =
      "${baseURL}ws-set-masonry-issue-report";

  static const String wspaymentdetailsbystatus =
      "${baseURL}ws-payment-details-by-status";
  static const String wsvenderpaymentduelist =
      "${baseURL}ws-po-vender-payment-due-list-optimize";
  //  "${baseURL}ws-vender-payment-due-list";
  static const String wspodetailsbystatus =
      "${baseURL}ws-po-details-by-status-latest";
  static const String wsvenderpaymenthistory =
      "${baseURL}ws-vender-payment-history-optimize";
  static const String wsvenderpoinvoicelist =
      "${baseURL}ws-vender-po-invoice-list";
  static const String wspostructurebyorder =
      "${baseURL}ws-po-structure-by-order";

  static const String woOrderAmendPdf = "${baseURL}wo-order-amend-pdf";
  static const String poOrderAmendPdf = "${baseURL}po-order-amend-pdf";

  static const String getGetDefaultPoCreate =
      "${baseURL}ws-get-finishing-default-list";
  static const String newDeveloperAccess = "${baseURL}web-new-developer-access";
  static const String webAddCustomRequirementType = "${baseURL}ws-set-po-grade";
  static const String webServiceForApproveDecline =
      "${baseURL}ws-payment-change-status";
  static const String webServiceForAddCustomUnit =
      "${baseURL}ws-set-grade-unit";

  static const String webBuyerPenaltyUpdate =
      "${baseURL}ws-buyer-penalty-update";

  static const String plotPaymentChangeStatus =
      "${baseURL}ws-plot-payment-change-status";

  static const String brokerpaymentacceptdate =
      "${baseURL}ws-broker-payment-accept";

  static const String webGetDescriptionByPoGrade =
      "${baseURL}ws-get-grade-by-description";
  static const String webPurchaseOrderPreview =
      "${baseURL}ws-review-po-structure";
  static const String webPurchaseOrderSubmit =
      "${baseURL}ws-set-rcc-booking-details";
  static const String webPurchaseOrderStatusChange =
      "${baseURL}ws-po-approved-by-user";
  static const String webGetPoRequisitonVendorList =
      "${baseURL}ws-po-requisition";
  static const String webSendVenderPoRequisition =
      "${baseURL}ws-send-vender-requisition";
  static const String webChangePoStatus = "${baseURL}ws-change-po-status";
  static const String webSupplierBookingHistory =
      "${baseURL}ws-supplier-booking-history";
  static const String webGetChalanByOrder = "${baseURL}ws-get-chalan-by-order";
  static const String webGetWoOrderNoByContractor =
      "${baseURL}ws-get-contractor-by-wo-list";
  static const String webCompleteChalanByOrder =
      "${baseURL}ws-complete-chalan-by-order";
  static const String wsSetChalanByOrder = "${baseURL}ws-set-chalan-by-order";
  static const String webgetPoChallanListFromJson =
      "${baseURL}ws-get-po-challan";
  static const String webUploadPoChallan = "${baseURL}ws-upload-po-challan";
  static const String webFetchPlansElevation =
      "${baseURL}ws-get-plans-elevation";
  static const String wsworkorderinvoicelist = "${baseURL}ws-wo-invoice-list";
  static const String webCmsDetails = "${baseURL}ws-cms-details";
  static const String webOrderHistoryall =
      "${baseURL}ws-get-rcc-booking-history";
  static const String webgetpochallan = "${baseURL}ws-get-po-challan";
  static const String webgetprojectbuyerinventory =
      "${baseURL}ws-get-project-buyer-inventory";

  static const String webgetFlatStatus = "${baseURL}ws-get-flat-status-new";
  static const String webGetParkingByFlat = "${baseURL}ws-get-parking-by-flat";
  static const String webParkingInventeryPdf =
      "${baseURL}ws-parking-inventery-pdf";

  static const String webSetRehabTenent = "${baseURL}ws-set-rehab-tenent";
  static const String webSetPoAssignTo = "${baseURL}ws-set-po-assign-to";
  static const String webSetWoAssignTo = "${baseURL}ws-set-wo-assign-to";

  static const String webAvailableInventeryPdf =
      "${baseURL}ws-available-inventery-pdf";

  static const String webGetRehabTenent = "${baseURL}ws-get-rehab-tenent";
  static const String webgetcontractorpayement =
      "${baseURL}ws-get-contractor-payement";
  static const String websubmitdeactivateaccount =
      "${baseURL}ws-mobile-no-detactive-otp";
  static const String websetpartialchalanbyorder =
      "${baseURL}ws-set-partial-chalan-by-order";
  static const String webgetTeamList = "${baseURL}ws-project-teamlist";
  static const String wsgetgrnlist = "${baseURL}ws-get-grn-details";
  static const String wsgetflatlistbyproject =
      "${baseURL}ws-get-flat-list-by-project";
  static const String wssetflatbook = "${baseURL}ws-set-flat-book-new";
  static const String wssetflatleasebook = "${baseURL}ws-set-flat-lease-book";

  static const String wsExcavationAdd = "${baseURL}ws-excavation-add";

  static const String wssetflatStatus = "${baseURL}ws-set-flat-status";

  static const String wssetflatMemberBook = "${baseURL}ws-set-flat-member-book";

  static const String wsTemplateFlatLeaseBefore =
      "${baseURL}ws-template-flat-lease-before";

  static const String wssetPaymentTermsSaleBooking =
      "${baseURL}ws-template-flat-sell-before";
  static const String wsSetFlatTenentBook = "${baseURL}ws-set-flat-tenent-book";
  static const String wsgetflatbuyerrequest =
      "${baseURL}ws-get-flat-buyer-request";
  static const String wsgetbuyerpaymentsdetails =
      "${baseURL}ws-get-buyer-payments-details";
  static const String wstemplateflatsellafter =
      "${baseURL}ws-template-flat-sell-after";
  static const String wsSetFlatStatus = "${baseURL}ws-set-flat-status";
  static const String webGetFlatDemandInvoiceList =
      "${baseURL}ws-get-flat-demand-invoice-list";
  static const String webSetPaymentTermsTitle = "${baseURL}ws-set-sales-type";
  static const String webGetProjectBuyersList =
      "${baseURL}ws-get-project-buyer-list";

  static const String webGetProjectTenantDocs =
      "${baseURL}ws-project-tenant-doc";
  static const String webGetCashFlowListing =
      "${baseURL}ws-get-case-flow-details";

  static const String webGetAllSalesLead = "${baseURL}ws-sales-lead-list";

  static const String websalesLeadDashbord = "${baseURL}ws-salesLeadDashbord";

  static const String webTenantDashbord = "${baseURL}ws-tenant-dashbord";

  static const String webGetAllBrokerList = "${baseURL}ws-get-broker-list";
  static const String wsgetbrokerpayment = "${baseURL}ws-get-broker-payment";

  static const String webTaskCount = "${baseURL}ws-task-count";

  static const String webGetAllBrokerDetails =
      "${baseURL}ws-get-broker-details";

  static const String webGetBrochureList = "${baseURL}ws-sell-brochure-plan";

  static const String webGetAllSalesLeadFilter =
      "${baseURL}ws-sales-lead-default";

  static const String wsLeadFilter = "${baseURL}ws-lead-filter";
  static const String wsSetPoVerifyFlag = "${baseURL}ws-set-po-verify-flag";

  static const String wsPoFilter = "${baseURL}ws-po-filter-details";
  static const String wsWoFilter = "${baseURL}ws-wo-filter-details";
  static const String wsPoDeliveryDetails = "${baseURL}ws-po-delivery-details";

  static const String webGetProjectPermission =
      "${baseURL}ws-get-project-permission";
  static const String webProjectPermissionTrackList =
      "${baseURL}ws-project-permission-track-list";
  static const String webTrackingAssignToList =
      "${baseURL}ws-tracking-assign-to-list";
  static const String webSopAssignList = "${baseURL}ws-sop-assign-list";
  static const String webAcquisitionList = "${baseURL}ws-acquisition-list";
  static const String getAppMasterDashboard =
      "${baseURL}ws-get-web-master-dashboard"; //"${baseURL}ws-get-app-master-dashboard";

  static const String webPlotPaymentList = "${baseURL}ws-plot-payment-list";

  static const String webcQuisitionFileList =
      "${baseURL}ws-acquisition-file-list";

  static const String webUpdatePermissionStatus =
      "${baseURL}ws-update-permission-status";

  static const String webProjectPermissionAssign =
      "${baseURL}ws-project-permission-assign";
  static const String webSopAssignTo = "${baseURL}ws-sop-assign-to";
  static const String webSopSetDetails = "${baseURL}ws-sop-set-details";

  static const String webSetPermissionRemark =
      "${baseURL}ws-set-permission-remark";

  static const String webGetProjectTenantList =
      "${baseURL}ws-project-tenant-list";
  static const String webGetAddSalesLead = "${baseURL}ws-sales-lead-add";
  static const String webleadPhoneExist = "${baseURL}ws-lead-phone-exit";
  static const String webSopDateSet = "${baseURL}ws-sop-date-set";

  static const String webleadOtherAdd = "${baseURL}ws-lead-other-add";
  static const String wsLeadSmsOtpRequest = "${baseURL}ws-lead-sms-otp-request";
  static const String wsResendOtp = "${baseURL}ws-resend-otp";

  static const String wsLeadEmailOtpRequest =
      "${baseURL}ws-lead-email-otp-request";

  static const String wsLeadOtpVerify = "${baseURL}ws-lead-otp-verify";
  static const String wsLeadEmailVerify = "${baseURL}ws-lead-email-otp-verify";

  static const String webGetLeadRegionList = "${baseURL}ws-lead-region-list";

  static const String webUpdateSalesLead = "${baseURL}ws-sales-lead-update";

  static const String wsForGetBuyerList = "${baseURL}ws-get-buyer-masonry-list";

  static const String wsGetCaseFlowBuyerList =
      "${baseURL}ws-get-case-flow-buyer-list";
  static const String wsGetBuyerPenaltyList =
      "${baseURL}ws-get-buyer-penalty-list";

  //Image URL
  static const String getProjectImageUrl =
      "${baseURL}media/backend/images/project-img/";
  static const String getProjectRccRevisionFileUrl =
      "${baseURL}media/backend/images/drawing/";
  static const String getProjectMasnoryRevisionFileUrl =
      "${baseURL}media/backend/images/masonry/";
  static const String globalWoFactSheetPath =
      "${baseURL}media/backend/images/quatification-img/";
  static const String globalUploadWoBoqURLMain =
      "${baseURL}media/backend/images/wo_before_image/";
  static const String globalUploadWoBoqURL =
      "${baseURL}media/backend/images/wo_before_image/";
  static const String globalPoinvoicePath =
      "${baseURL}media/backend/images/invoice/";
  static const String globalFinishingPath =
      "${baseURL}media/backend/images/finishing-document/";
  static const String permissionLodPath =
      "${baseURL}media/backend/images/permission-lod/";
  static const String globalLabReport =
      "${baseURL}media/backend/images/lab-report/";

  static const String dprUpload = "${baseURL}media/backend/images/project-dpr/";
  static const String slabCheckPath =
      "${baseURL}media/backend/images/project-slab-check/";

  static const String dprUploadImg =
      "${baseURL}media/backend/images/drp-upload/";

  static const String globalSlabReportPath =
      "${baseURL}media/backend/images/slabreport/";
  static const String EXCAVATIONpath =
      "${baseURL}media/backend/images/excavation/";
  static const String regenerateDemandNotePath =
      "${baseURL}media/backend/regenerate-demand-note/";

  static const String regenerateplotPaymentDetailsPath =
      "${baseURL}media/backend/images/plot-payment-details/";
  static const String globalMasnoryReportPath =
      "${baseURL}media/backend/images/masonryreport/";
  static const String globaltaskPath =
      "${baseURL}media/backend/images/task-img/";
  static const String globalMasonryReportPath =
      "${baseURL}media/backend/images/masonryreport/";
  static const String globalMasonryReportIssuePath =
      "${baseURL}media/backend/images/masonryissue/";
  static const String globalPermissionDocsPath =
      "${baseURL}media/backend/images/permission/";
  static const String vaultPath =
      "${baseURL}media/backend/images/project-category-file/";
  static const String poDocPath = "${baseURL}media/backend/images/po-document/";
  static const String slabCheckDoc =
      "${baseURL}media/backend/images/slab-check-document/";

  static const String legalDocsPath = "${baseURL}media/backend/images/legal/";
  static const String subLegalDocsPath =
      "${baseURL}media/backend/images/sub-legal/";

  static const String globalPoChallanReportPath =
      "${baseURL}media/backend/images/invoice/";
  static const String globalPoChallanUrl =
      "${baseURL}media/backend/images/chalan-report/";
  static const String globalBrochureUrl =
      "${baseURL}media/backend/images/brochure-plan/";
  static const String globalPlanElevation =
      "${baseURL}media/backend/images/plans-elevation/";
  static const String globalDebitDocumentUrl =
      "${baseURL}media/backend/images/discount/";
  static const String globalGrnPath = "${baseURL}media/backend/grn/";
  static const String globalFlatRegistrationDocURLMain =
      "${baseURL}media/backend/images/flat-register-document/";
  static const String globalFlatAllotmentLetterURLMain =
      "${baseURL}media/backend/sell-download/";
  static const String globalFlatCustomChargesURLMain =
      "${baseURL}media/backend/custom-charges-download/";
  static const String globalFlatBankLetterURLMain =
      "${baseURL}media/backend/sell-bank-letter/";
  static const String globalSaleDemandNoteUrl =
      "${baseURL}media/backend/sell-demand-note/";
  static const String globalTenantDocuments =
      "${baseURL}media/backend/images/tenant-document/";
  static const String globalSaleInvoiceUrl =
      "${baseURL}media/backend/sell-invoice/";
  static const String globalPlotImagesUrl =
      "${baseURL}media/backend/images/plot-direction-img";

  static const String wsdeletepmsstructure =
      "${baseURL}ws-delect-pms-structure";
  static const String wssetpmsstructure = "${baseURL}ws-set-pms-structure";
  static const String projectCmsDateChange =
      "${baseURL}ws-project-cms-date-change";

  static const String cmsRccSync = "${baseURL}ws-cms-rcc-sync";

  static const String wssetprojectpmsinfo = "${baseURL}ws-set-project-pms-info";

  static const String wssetduplicateStructure =
      "${baseURL}ws-set-duplicate-structure";
  static const String wsgetpmsstructure = "${baseURL}ws-get-pms-structure";

  static const String wsgetpmsWorkList = "${baseURL}ws-get-pms-work-list";
  static const String wsgetpROJECTpMS = "${baseURL}ws-get-project-pms";
  static const String wsSetProjectPms = "${baseURL}ws-set-project-pms";
  static const String wsProjectCmsExcel =
      "${baseURL}ws-project-cms-excel-download";

  static const String wsgetPlotImages = "${baseURL}ws-flat-plot-drawing";
  static const String wsgetPlotingDisplay = "${baseURL}ws-get-plot-flat";
  static const String wsdeletepROJECTpMS = "${baseURL}ws-delect-project-pms";
  static const String poDownload = "${baseURL}media/backend/po-download";
  static const String wsGetNotificationFillter =
      "${baseURL}ws-get-notification-fillter";

  // DevSOP REST APIs
  static const String devSopCategories = "${baseURL}devsop/categories";
  static const String devSopHeadings = "${baseURL}devsop/headings";
  static const String devSopSubHeadings = "${baseURL}devsop/sub-headings";
  static const String devSopTowerSubHeading = "${baseURL}devsop/tower-sop-sub-heading";
  static const String devSopDocuments = "${baseURL}devsop/documents";
  static const String devSopTowerTaskList = "${baseURL}devsop/tower-sop-task-list";
  static const String devSopAssignSubHeading = "${baseURL}devsop/assign-sub-heading";
  static const String devSopSaveAllSubHeadings = "${baseURL}devsop/save-all-sop-sub-headings";
  static String devSopHistory(String towerId, String categoryId) =>
      "${baseURL}devsop/history/tower/$towerId/category/$categoryId";
}
