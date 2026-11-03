import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/company_payment_due.dart';
import 'package:stallion/models/get_budget_overview.dart';
import 'package:stallion/models/get_overview.dart';
import 'package:stallion/models/get_project_dpr_contractor.dart';
import 'package:stallion/models/projectBudgetmodel.dart';
import 'package:stallion/models/projectPurchaseordermodel.dart';
import 'package:stallion/models/projectRccmodel.dart';
import 'package:stallion/models/projectSalesmodel.dart';
import 'package:stallion/models/projectWorkordermodel.dart';
import 'package:stallion/models/project_permissionmodel.dart';
import 'package:stallion/ui/views/overview_module/budget_module_screen.dart';
import 'package:stallion/ui/views/overview_module/permission_module_screen.dart';
import 'package:stallion/ui/views/overview_module/po_module_screen.dart';
import 'package:stallion/ui/views/overview_module/rcc_module_screen.dart';
import 'package:stallion/ui/views/overview_module/sales_module_screen.dart';
import 'package:stallion/ui/views/overview_module/work_order_screen.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/tenant_overview/tenant_overview_page.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  DateTime? _selectedToDate;
  DateTime? _selectedFormDate;
  TextEditingController fromDateControler = TextEditingController();
  TextEditingController toDateControler = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<LineChart>? lineChartResponse = [];
  List<SlabConsumption>? slabConsumptionResponse = [];
  List<String>? lastUpdateRccResponse = [];
  String? slabSpeedResponse = '';
  PoModule? poModuleResponse;
  // PoModule? woModuleResponse;
  WoModule? woModuleResponse;
  SalesModule? salesModuleResponse;
  BudgetModule? budgetModule;
  RccModule? rccModule;
  PermissionModule? permissionModule;
  List<PieChart>? pieChart = [];
  List<PieChart>? pieChartValue = [];
  List<String>? latestIssued = [];
  List<TotoalExpired>? totoalExpired = [];
  List<String>? totoalPending = [];
  List<PoBudgetList>? poBudgetList = [];
  List<WoBudgetList>? woBudgetList = [];
  String? paymentDue = '';
  String? paymentOverdue = '';
  String? totalPaidAmount = '';
  String? paymentDueWo = '';
  String? paymentOverdueWo = '';
  String? totalPaidAmountWo = '';
  String? totalPaidBalance = '';

  List<BrokerDetail>? brokerDetail = [];
  String? totalSoldSqft = '';
  String? totalSoldAvg = '';
  String? totalUnsoldAvg = '';
  List<dynamic>? assignedModules;
  bool _modulesLoaded = false;

  Future<ResponseGetProjectDprContractor?> fetchOverview() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }

    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      // "start_date": fromDateControler.text,
      // "end_date": toDateControler.text,
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getProjectOverView, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getOverViewFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          rccModule = dataModel.response?.rccModule;
          permissionModule = dataModel.response?.permissionModule;

          // rcc
          // lineChartResponse = dataModel.response?.rccModule?.lineChart;
          // slabSpeedResponse = dataModel.response?.rccModule?.slabSpeed;
          // slabConsumptionResponse =
          //     dataModel.response?.rccModule?.slabConsumption;
          // lastUpdateRccResponse = dataModel.response?.rccModule?.lastUpdate;
          // po module
          // poModuleResponse = dataModel.response?.poModule;

          // wo module
          // woModuleResponse = dataModel.response?.woModule;
          // Permission
          // pieChart = dataModel.response?.permissionModule?.pieChart;
          // pieChartValue = dataModel.response?.permissionModule?.pieChart;
          latestIssued = dataModel.response?.permissionModule?.latestIssued;
          // totoalExpired = dataModel.response?.permissionModule?.totoalExpired;
          // totoalPending = dataModel.response?.permissionModule?.totoalPending;
          //sales module
          // salesModuleResponse = dataModel.response?.salesModule;
          // brokerDetail = dataModel.response?.salesModule?.brokerDetail;
          // totalSoldSqft = dataModel.response?.salesModule?.totalSoldSqft;
          // totalSoldAvg = dataModel.response?.salesModule?.totalSoldAvg;
          // totalUnsoldAvg = dataModel.response?.salesModule?.totalUnsoldAvg;
          // budget
          // budgetModule = dataModel.response?.budgetModule;
        });
      } else {}
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?> fetchBudgetOverview() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      "start_date": fromDateControler.text,
      "end_date": toDateControler.text,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getProjectBudgetOverview, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getOverBugetViewFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          poBudgetList = dataModel.response?.poBudgetList;
          woBudgetList = dataModel.response?.woBudgetList;
        });
      } else {}
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?> fetchCompanyOverDue() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }
    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      // "start_date": fromDateControler.text,
      // "end_date": toDateControler.text,
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getCompanyProjectDue, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = companyPaymentDueFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          paymentDue = dataModel.response?.paymentDue;
          paymentOverdue = dataModel.response?.paymentOverdue;
          totalPaidAmount = dataModel.response?.totalPaidAmount;
          // totalPaidBalance = dataModel.response?.paymentBalance;
          print('${dataModel.response?.paymentBalance}--------------------');
        });
      } else {}

      fetchCompanyOverDueWo();
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?> fetchCompanyOverDueWo() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }
    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      // "start_date": fromDateControler.text,
      // "end_date": toDateControler.text,
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getVenderProjectDue, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = companyPaymentDueFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          paymentDueWo = dataModel.response?.paymentDue;
          totalPaidAmountWo = dataModel.response?.totalPaidAmount;

          paymentOverdueWo = dataModel.response?.paymentOverdue;
          print('${dataModel.response?.paymentBalance}--------------------');
          totalPaidBalance = dataModel.response?.paymentBalance;
        });
      } else {}
    }
    return null;
  }

  bool isOpenSelected = false;
  final List<ChartData> chartData = [
    ChartData(
      '2nd',
      13,
      // Colors.amber,
    ),
    ChartData(
      '3rd',
      75,
      // Colors.green,
    ),
  ];

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFormDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedFormDate) {
      setState(() {
        _selectedFormDate = picked;
        // ref.read(budgetApiProvider).setSelectedFormDate(data: picked);
        fromDateControler.text =
            DateFormat('dd-MM-yyyy').format(_selectedFormDate!);
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedToDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedToDate) {
      setState(() {
        _selectedToDate = picked;
        toDateControler.text =
            DateFormat('dd-MM-yyyy').format(_selectedToDate!);
      });
    }
  }

  Future<void> fetchAssignableModules() async {
    try {
      final url = "${AppUrl.baseURL}modules/assignable?project_id=${widget.projectId}";
      var response = await apiNetworkHandler.get(url);
      
      if (kDebugMode) {
        print("GET /modules/assignable status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
      
      String? errorMessage;
      if (response.body != null && response.body.isNotEmpty) {
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            errorMessage = decoded['message'] ?? decoded['msg'];
            if (decoded['success'] == true && decoded['data'] is List) {
              setState(() {
                assignedModules = decoded['data'];
                _modulesLoaded = true;
              });
              return;
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error parsing /modules/assignable JSON: $e");
          }
        }
      }
      
      if (response.statusCode == 403 ||
          errorMessage == "Forbidden: You do not have permission to view the assigned modules.") {
        setState(() {
          assignedModules = [];
          _modulesLoaded = true;
        });
      } else {
        setState(() {
          assignedModules = [];
          _modulesLoaded = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching assignable modules: $e");
      }
      setState(() {
        assignedModules = [];
        _modulesLoaded = true;
      });
    }
  }

  bool isModuleAssigned(String moduleKey) {
    if (!AppUrl.useNewBackend) {
      switch (moduleKey) {
        case 'rcc': return rccModule?.isActive == '1';
        case 'po': return poModuleResponse?.isActive == '1';
        case 'wo': return woModuleResponse?.isActive == '1';
        case 'permission': return permissionModule?.isActive == '1';
        case 'budget': return budgetModule?.isActive == '1';
        case 'sales': return salesModuleResponse?.isActive == '1';
        case 'tenant': return true;
        default: return false;
      }
    }
    
    if (assignedModules == null) return false;
    
    for (var item in assignedModules!) {
      if (item is Map) {
        final String name = (item['name'] ?? '').toString().toLowerCase();
        final String id = (item['id'] ?? '').toString();
        
        if (moduleKey == 'rcc') {
          if (name.contains('rcc') || id == '8') return true;
        }
        if (moduleKey == 'permission') {
          if (name.contains('permission') || id == '19') return true;
        }
        if (moduleKey == 'sales') {
          if (name.contains('sales') || id == '15') return true;
        }
        if (moduleKey == 'po') {
          if (name.contains('purchase order') || name.contains('po') || id == '10') return true;
        }
        if (moduleKey == 'wo') {
          if (name.contains('work order') || name.contains('wo') || id == '11') return true;
        }
        if (moduleKey == 'budget') {
          if (name.contains('budget') || id == '17') return true;
        }
        if (moduleKey == 'tenant') {
          if (name.contains('tenant') || id == '16') return true;
        }
      }
    }
    return false;
  }
 
  bool get _hasAnyAssignedModule {
    return isModuleAssigned('rcc') ||
        isModuleAssigned('po') ||
        isModuleAssigned('wo') ||
        isModuleAssigned('permission') ||
        isModuleAssigned('budget') ||
        isModuleAssigned('sales') ||
        isModuleAssigned('tenant');
  }

  bool get _isLoaded {
    if (!_modulesLoaded) return false;
    if (isModuleAssigned('budget')) {
      return budgetModule != null && poBudgetList != null;
    }
    return true;
  }

// new data api

  Future<ResponseGetProjectDprContractor?> fetchRccModel() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }
    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      // "start_date": fromDateControler.text,
      // "end_date": toDateControler.text,
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.projectRccmodel, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectRccModelFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          lineChartResponse = dataModel.response?.rccModule?.lineChart;
          slabSpeedResponse = dataModel.response?.rccModule?.slabSpeed;
          slabConsumptionResponse =
              dataModel.response?.rccModule?.slabConsumption;
          lastUpdateRccResponse = dataModel.response?.rccModule?.lastUpdate;
        });
      } else {}
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?> fetchwsPurchaseOrderModel() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }
    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.projectPurchaseordermodel, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectPurchaseordermodelFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          poModuleResponse = dataModel.response?.poModule;
          // paymentDueWo = dataModel.response?.poModule?.totalDue;
          // totalPaidAmountWo = dataModel.response?.poModule?.totalPaid;
          // totalPaidBalance = '00';
        });
      } else {}
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?>
      fetchwsProjectWorkordermodel() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }
    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      // "start_date": fromDateControler.text,
      // "end_date": toDateControler.text,
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.projectWorkordermodel, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectWorkordermodelFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          woModuleResponse = dataModel.response?.woModule;
        });
      } else {}
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?> fetchProjectPermissionmodel() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }
    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      // "start_date": fromDateControler.text,
      // "end_date": toDateControler.text,
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.projectPermissionmodel, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectPermissionmodelFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          pieChart = dataModel.response?.permissionModule?.pieChart;
          pieChartValue = dataModel.response?.permissionModule?.pieChart;
          latestIssued = dataModel.response?.permissionModule?.latestIssued;
          totoalExpired = dataModel.response?.permissionModule?.totoalExpired;
          totoalPending = dataModel.response?.permissionModule?.totoalPending;
        });
      } else {}
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?> fetchProjectBudgetmodel() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }
    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      // "start_date": fromDateControler.text,
      // "end_date": toDateControler.text,
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.projectBudgetmodel, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectBudgetmodelFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          budgetModule = dataModel.response?.budgetModule;
        });
      } else {}
    }
    return null;
  }

  Future<ResponseGetProjectDprContractor?> fetchProjectSalesmodel() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (fromDateControler.text.isNotEmpty) {
      // Parse dates and format properly
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(fromDateControler.text);
      DateTime endDate = DateFormat('dd-MM-yyyy').parse(toDateControler.text);

      // Add 1 day to end date
      DateTime endDatePlusOne = endDate.add(const Duration(days: 1));

      // Format as YYYY-MM-DD
      formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDatePlusOne);
    }
    Map<String, String> data = {
      "towar_id": widget.towarId ?? '',
      "project_id": widget.projectId ?? '',
      "user_id": userId ?? '',
      // "start_date": fromDateControler.text,
      // "end_date": toDateControler.text,
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.projectSalesmodel, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectSalesmodelFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          salesModuleResponse = dataModel.response?.salesModule;
          brokerDetail = dataModel.response?.salesModule?.brokerDetail;
          totalSoldSqft = dataModel.response?.salesModule?.totalSoldSqft;
          totalSoldAvg = dataModel.response?.salesModule?.totalSoldAvg;
          totalUnsoldAvg = dataModel.response?.salesModule?.totalUnsoldAvg;
        });
      } else {}
    }
    return null;
  }

  @override
  void initState() {
    if (!AppUrl.useNewBackend) {
      _modulesLoaded = true;
    } else {
      fetchAssignableModules();
    }
    //new
    fetchRccModel();
    fetchwsPurchaseOrderModel();
    fetchwsProjectWorkordermodel();
    fetchProjectPermissionmodel();
    fetchProjectBudgetmodel();
    fetchProjectSalesmodel();
    //new end
    fetchOverview();
    fetchBudgetOverview();
    fetchCompanyOverDue();
    fetchCompanyOverDueWo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Color(0XFF272727), //  0XFF101010
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     Navigator.maybePop(context);
        //     //Navigator.of(context).pushReplacementNamed('/dashboard');
        //   },
        // ),
      ),
      body: _isLoaded
          ? SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(6)),
                      height: 40,
                      child: const Center(
                        child: Text('OVERVIEW',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 1000,
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  // color: Colors.white,
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const SizedBox(width: 40),
                      Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: const AppText(
                          title: "Filter",
                          fontSize: 16,
                          titleColor: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _selectFromDate(context);
                          },
                          child: Container(
                            height: 32,
                            child: TextFormField(
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(From Date Cannot be Ready)";
                              //   }
                              // },
                              enabled: false,
                              readOnly: true,
                              controller: fromDateControler,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13.0),
                              decoration: const InputDecoration(
                                  filled: true,
                                  // fillColor: Colors.white,

                                  disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.red,
                                  )),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  hintText: 'Select From Date',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  suffixIcon: Icon(
                                    Icons.calendar_month_outlined,
                                    color: Color.fromARGB(255, 116, 116, 116),
                                  )),
                            ),
                          ),
                        ),
                      ),
                      // const Spacer(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _selectToDate(context);
                          },
                          child: Container(
                            height: 32,
                            child: TextFormField(
                              enabled: false,
                              readOnly: true,
                              controller: toDateControler,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13.0),
                              decoration: const InputDecoration(
                                  filled: true,
                                  // fillColor: Colors.white,
                                  disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.grey,
                                  )),
                                  contentPadding: EdgeInsets.all(12.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: 'Select To Date',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'HelveticaNeue',
                                  ),
                                  suffixIcon: Icon(
                                    Icons.calendar_month_outlined,
                                    color: Color.fromARGB(255, 116, 116, 116),
                                  )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () {
                          // getAllLeadOverview();
                          fetchRccModel();
                          fetchwsPurchaseOrderModel();
                          fetchwsProjectWorkordermodel();
                          fetchProjectPermissionmodel();
                          fetchProjectBudgetmodel();
                          fetchProjectSalesmodel();
                          //new end
                          fetchOverview();
                          fetchBudgetOverview();
                          fetchCompanyOverDue();
                          fetchCompanyOverDueWo();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: const BorderSide(
                              width: 1.0, color: Colors.transparent),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Border radius 4
                          ),
                        ),
                        child: const Text('Submit',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                              color: Colors.white,
                            )),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () {
                          fromDateControler.clear();
                          toDateControler.clear();
                          fetchRccModel();
                          fetchwsPurchaseOrderModel();
                          fetchwsProjectWorkordermodel();
                          fetchProjectPermissionmodel();
                          fetchProjectBudgetmodel();
                          fetchProjectSalesmodel();
                          //new end
                          fetchOverview();
                          fetchBudgetOverview();
                          fetchCompanyOverDue();
                          fetchCompanyOverDueWo();
                          // getAllLeadOverview();
                        },
                        style: OutlinedButton.styleFrom(
                          // backgroundColor: Colors.white,
                          side:
                              const BorderSide(width: 1.0, color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Border radius 4
                          ),
                        ),
                        child: const Text('Reset',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16.0,
                              color: Colors.white,
                            )),
                      ),
                      // const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // const Divider(height: 1.0, color: Colors.white),
                const SizedBox(height: 14),

                if (_modulesLoaded && (assignedModules == null || assignedModules!.isEmpty || !_hasAnyAssignedModule))
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            "No module is assigned.",
                            style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Wrap(
                      direction: Axis.horizontal, // default
                      alignment: WrapAlignment.start, // default
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        if (isModuleAssigned('rcc'))
                          RccModuleScreen(
                            lineChartData: lineChartResponse,
                            averageSlabSpeed: slabSpeedResponse ?? '',
                            slabConsumptionData: slabConsumptionResponse,
                            lastUpdateRccResponse: lastUpdateRccResponse,
                            projectId: widget.projectId ?? '',
                            towarName: widget.towarName ?? '',
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName ?? '',
                          ),
                        if (isModuleAssigned('po'))
                          POModuleScreen(
                            totalPaidBalance: totalPaidBalance,
                            totalOpenPoData: poModuleResponse?.totalOpenPo,
                            totalIssuedPoData: poModuleResponse?.totalIssuedPo,
                            totalDueData: poModuleResponse?.totalDue,
                            totalPaidData: poModuleResponse?.totalPaid,
                            lastUpdateData: poModuleResponse?.lastUpdate,
                            projectId: widget.projectId ?? '',
                            towarName: widget.towarName ?? '',
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName ?? '',
                            paymentDue: paymentDueWo, //paymentDue,
                            totalPaidAmount: totalPaidAmountWo, //totalPaidAmount,
                          ),
                        if (isModuleAssigned('wo'))
                          WorkOrderScreen(
                            totalBalanceAmount: "0",
                            projectId: widget.projectId ?? '',
                            towarName: widget.towarName ?? '',
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName ?? '',
                            totalOpenPo: woModuleResponse?.totalOpenPo,
                            totalIssuedPo: woModuleResponse?.totalIssuedPo,
                            totalDue: woModuleResponse?.totalDue,
                            totalPaid: woModuleResponse?.totalPaid,
                            lastUpdate: woModuleResponse?.lastUpdate,
                            paymentOverdue: paymentDue, //paymentOverdueWo,
                            totalPaidAmount:
                                totalPaidAmount, // totalPaidAmountWo,
                          ),
                        if (isModuleAssigned('permission'))
                          PermissionModuleScreen(
                            projectId: widget.projectId ?? '',
                            towarName: widget.towarName ?? '',
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName ?? '',
                            pieChart: pieChart,
                            pieChartValue: pieChartValue,
                            latestIssued: latestIssued,
                            totoalExpired: totoalExpired,
                            totoalPending: totoalPending,
                          ),
                        if (isModuleAssigned('budget'))
                          BudgetModuleScreen(
                            projectId: widget.projectId ?? '',
                            towarName: widget.towarName ?? '',
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName ?? '',
                            halfPie: budgetModule?.halfPie,
                            halfPieValue: budgetModule?.halfPieValue,
                            totalBudget: budgetModule?.totalBudget,
                            totalSpend: budgetModule?.totalSpend,
                            rawMaterialOverBudget:
                                budgetModule?.rawMaterialOverBudget,
                            contractOverBudget: budgetModule?.contractOverBudget,
                            poBudgetList: poBudgetList,
                            woBudgetList: woBudgetList,
                          ),
                        if (isModuleAssigned('sales'))
                          SalesModuleScreen(
                              flatReservedPencentage:
                                  salesModuleResponse?.flatReservedPencentage,
                              totalUnsoldAvg: totalUnsoldAvg,
                              totalSoldSqft: totalSoldSqft,
                              totalSoldAvg: totalSoldAvg,
                              brokerDetail: brokerDetail,
                              projectId: widget.projectId ?? '',
                              towarName: widget.towarName ?? '',
                              towarId: widget.towarId ?? '',
                              projectName: widget.projectName ?? '',
                              paymentStatusReceive:
                                  salesModuleResponse?.paymentStatusReceive,
                              paymentStatusOver:
                                  salesModuleResponse?.paymentStatusOver,
                              availableValue: salesModuleResponse?.availableValue,
                              successLead: salesModuleResponse?.successLead,
                              pendingRequest: salesModuleResponse?.pendingRequest,
                              nextTargetPrice:
                                  salesModuleResponse?.nextTargetPrice,
                              flatReserved: salesModuleResponse?.flatReserved,
                              paymentCollectable:
                                  salesModuleResponse?.paymentCollectable,
                              unsoldInventry:
                                  salesModuleResponse?.unsoldInventry),
                        if (isModuleAssigned('tenant'))
                          TenantOverViewPage(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            towarId: widget.towarId,
                            towarName: widget.towarName!,
                          ),
                      ])
              ]),
            )
          : Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: OverflowBox(
                  minHeight: 100,
                  maxHeight: 100,
                  child: Lottie.asset(
                    'assets/animation/running3.json',
                    repeat: true,
                  ),
                ),
              ),
            ),
    );
  }
}

class ChartData {
  ChartData(
    this.x,
    this.y,
    // this.colr,
  );
  final String x;
  final double? y;
  // final Color? colr;
}
