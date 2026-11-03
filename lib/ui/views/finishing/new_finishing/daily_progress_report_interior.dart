import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stallion/models/get_project_dpr_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/finishing/new_finishing/add_dpr_screen_interior.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesLeadDetailPage.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/ui/widgets/row_three_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyProgressReportInterior extends StatefulWidget {
  DailyProgressReportInterior(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.slabId,
      this.title});
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;
  @override
  State<DailyProgressReportInterior> createState() =>
      _DailyProgressReportState();
}

class _DailyProgressReportState extends State<DailyProgressReportInterior> {
  DateTime? _selectedFormDate;
  TextEditingController fromDateControler = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedToDate;
  TextEditingController toDateControler = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String offset = "0";
  List<ProjctDprList>? projctDprListResponse = [];
  GetProjectDprListResponse? responseWebService;

  Future<GetProjectDprListResponse?> fetchGetAllDPRlist() async {
    CustomLoading.progressDialog(isLoading: true, context: context);

    String formatDate(DateTime dateTime) {
      // String formattedDate =
      //     DateFormat('yyyy-MM-dd HH:mm:ss').format(originalDate);
      // return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "end_date": _selectedToDate != null ? formatDate(_selectedToDate!) : "",
      "start_date":
          _selectedFormDate != null ? formatDate(_selectedFormDate!) : "",
      "offset": offset,
      "project_id": widget.projectId!,
      "limit": "20",
      "slab_id": widget.slabId!,
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getProjectFinishingDprList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getProjectDprListFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          if (projctDprListResponse!.length == 0) {
            projctDprListResponse = dataModel.response?.projctDprList;
          } else {
            projctDprListResponse = [
              ...projctDprListResponse!,
              ...?dataModel.response?.projctDprList
            ];
          }
          offset = dataModel.response?.offset ?? '';
          responseWebService = dataModel.response;
        });
      } else {}
    }
    CustomLoading.progressDialog(isLoading: false, context: context);
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));

    offset = '0';
    _selectedToDate = null;
    _selectedFormDate = null;
    projctDprListResponse = [];

    fetchGetAllDPRlist();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 100));
    fetchGetAllDPRlist();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      offset = "0";
    });
    // fetchGetAllDPRlist();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchGetAllDPRlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
          top: BorderSide(
            color: Colors.black,
          ),
        )),
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(
                  title: "Active Contractors",
                  fontSize: 16,
                ),
                const SizedBox(height: 6),
                AppText(
                  title: responseWebService?.activeContractor ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ],
            )),
            Expanded(
                child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                left: BorderSide(
                  color: Colors.black,
                ),
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppText(
                    title: "Avg. Skilled Labours",
                    fontSize: 16,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    title: responseWebService?.skilledLabour ?? '',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            )),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                  left: BorderSide(
                    color: Colors.black,
                  ),
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText(
                      title: "Avg. Unskilled Labours",
                      fontSize: 16,
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      title: responseWebService?.unskilledLabour ?? '',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.black,
            ))),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 100),
                const AppText(
                  // title: '${widget.title} - D.P.R',
                  title: 'D.P.R',
                  fontSize: 18,
                  titleColor: Colors.black,
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return AddDprScreenInterior(
                            projectId: widget.projectId,
                            towarId: widget.towarId ?? '',
                            projectName: widget.projectName,
                            towarName: widget.towarName ?? '',
                            title: widget.title,
                            slabId: widget.slabId,
                            slabNumber: widget.title,
                          );
                        },
                      ),
                    ).then((value) {
                      setState(() {
                        offset = "0";
                        projctDprListResponse?.clear();
                      });
                      fetchGetAllDPRlist();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(width: 1.0, color: Colors.black45),
                  ),
                  child: const Text('ADD DPR',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 40),
                Container(
                  padding: const EdgeInsets.only(right: 12),
                  child: const AppText(
                    title: "Filter",
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _selectFromDate(context);
                    },
                    child: TextFormField(
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return "(From Date Cannot be Ready)";
                      //   }
                      // },
                      enabled: false,
                      readOnly: true,
                      controller: fromDateControler,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13.0),
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.red,
                          )),
                          contentPadding: EdgeInsets.all(12.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: 'Select From Date',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 116, 116, 116),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'HelveticaNeue',
                          ),
                          suffixIcon: Icon(
                            Icons.calendar_month_outlined,
                          )),
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
                    child: TextFormField(
                      enabled: false,
                      readOnly: true,
                      controller: toDateControler,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13.0),
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: 'Select To Date',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 116, 116, 116),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'HelveticaNeue',
                          ),
                          suffixIcon: Icon(
                            Icons.calendar_month_outlined,
                          )),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                OutlinedButton(
                  onPressed: () {
                    if (_selectedFormDate != null && _selectedToDate != null) {
                      // if (_formKey.currentState!.validate()) {
                      setState(() {
                        offset = "0";
                        projctDprListResponse?.clear();
                      });
                      CustomLoading.progressDialog(
                          isLoading: true, context: context);
                      fetchGetAllDPRlist().then((value) {
                        CustomLoading.progressDialog(
                            isLoading: false, context: context);
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(width: 1.0, color: Colors.black45),
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
                    setState(() {
                      _selectedFormDate = null;
                      fromDateControler.clear();
                      _selectedToDate = null;
                      toDateControler.clear();
                      offset = '0';
                    });
                    fetchGetAllDPRlist();
                  },
                  style: OutlinedButton.styleFrom(
                    // backgroundColor: Colors.black,
                    side: const BorderSide(width: 1.0, color: Colors.black45),
                  ),
                  child: const Text('Reset',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0,
                        color: Colors.black,
                      )),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SmartRefresher(
                enablePullDown: true, //searchTermValue.isEmpty ? true : false,
                enablePullUp: true, //searchTermValue.isEmpty ? true : false,
                controller: _refreshController,
                onRefresh:
                    _onRefresh, //searchTermValue.isEmpty ? _onRefresh : null,
                onLoading:
                    _onLoading, // searchTermValue.isEmpty ? _onLoading : null,
                footer:
                    const ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                physics: const AlwaysScrollableScrollPhysics(),
                child: projctDprListResponse?.length != 0
                    ? ListView.separated(
                        itemCount: projctDprListResponse?.length ?? 0,
                        itemBuilder: (context, index) {
                          return dailyProgressDprCard(
                            data: projctDprListResponse![index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 1,
                            endIndent: 1,
                            color: Colors.black,
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "No Record Found",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      )),
          ),
        ],
      ),
    );
  }

  Widget dailyProgressDprCard({required ProjctDprList data}) {
    return InkWell(
      onTap: () {
        if (data.drpStatus == '1') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return PdfViewer(
                  fileName: data.drpFileName.toString(),
                  fileUrl: '${AppUrl.dprUpload}${data.drpFileName.toString()}',
                );
              },
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 80,
              child: Column(
                children: [
                  rowThreeText(
                    context: context,
                    title: "D.P.R No.",
                    titleValue: data.drpSrNo ?? "",
                    buttonText: data.drpStatus == '1' ? '' : 'Edit',
                    isActionButtonBlack: data.drpStatus == '1' ? false : true,
                    onTapButton: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return AddDprScreenInterior(
                              projectId: widget.projectId,
                              towarId: widget.towarId ?? '',
                              projectName: widget.projectName,
                              towarName: widget.towarName ?? '',
                              title: widget.title,
                              slabId: widget.slabId,
                              slabNumber: widget.title,
                              project_dpr_id: data.mstProjectDprId,
                            );
                          },
                        ),
                      ).then((value) {
                        setState(() {
                          offset = "0";
                          projctDprListResponse?.clear();
                        });
                        fetchGetAllDPRlist();
                      });
                    },
                  ),
                  rowThreeText(
                    context: context,
                    title: "Submitted By",
                    titleValue: data.userName ?? "",
                  ),
                  rowThreeText(
                    context: context,
                    title: "Work Type",
                    titleValue: data.drpWorkType ?? "",
                  ),
                  rowThreeText(
                    context: context,
                    title: "Created On",
                    titleValue: DateFormat('dd MMMM yyyy', 'en_US')
                        .format(data.drpCreatedAt!),
                    buttonText:
                        data.uploadImage?.length != 0 ? "View Docs" : "",
                    onTapButton: () {
                      viewDocumentsModal(dataDocs: data);
                    },
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

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
        fromDateControler.text =
            DateFormat('yyyy/M/d').format(_selectedFormDate!);
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
        toDateControler.text = DateFormat('yyyy/M/d').format(_selectedToDate!);
      });
    }
  }

  viewDocumentsModal({required ProjctDprList dataDocs}) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: const Text(
                  "SELECT DOCUMENT",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                height: 300,
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        direction: Axis.horizontal, // default
                        alignment: WrapAlignment.start, // default
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          for (int i = 0; i < dataDocs.uploadImage!.length; i++)
                            InkWell(
                              onTap: () async {
                                if (dataDocs.uploadImage![i].contains('.pdf')) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return PdfViewer(
                                          fileName:
                                              '${AppUrl.dprUploadImg}${dataDocs.uploadImage![i].toString()}',
                                          fileUrl:
                                              '${AppUrl.dprUploadImg}${dataDocs.uploadImage![i].toString()}',
                                        );
                                      },
                                    ),
                                  );
                                } else if (dataDocs.uploadImage![i]
                                    .contains('.mp4')) {
                                  final uri = Uri.parse(
                                      '${AppUrl.dprUploadImg}${dataDocs.uploadImage![i].toString()}');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    throw 'Could not launch';
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) {
                                        return ImagePreviewViewer(
                                          fileName: dataDocs.uploadImage![i]
                                              .toString(),
                                          fileUrl:
                                              '${AppUrl.dprUploadImg}${dataDocs.uploadImage![i].toString()}',
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                width: 140,
                                child: Column(
                                  children: [
                                    dataDocs.uploadImage![i].contains('.pdf')
                                        ? Image.asset(
                                            'images/projectmanagement/pdf.png',
                                            width: 100,
                                            height: 100,
                                          )
                                        : dataDocs.uploadImage![i]
                                                .contains('.mp4')
                                            ? const Icon(
                                                Icons.video_camera_back,
                                                size: 80,
                                              )
                                            : Image.network(
                                                '${AppUrl.dprUploadImg}${dataDocs.uploadImage![i].toString()}',
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.fill,
                                              ),
                                    AppText(
                                      title: dataDocs.uploadImage![i],
                                      fontSize: 14,
                                    )
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
