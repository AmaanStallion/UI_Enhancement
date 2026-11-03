import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/brokere_meeting_detail_modal.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/utils/app_url.dart';

class BrokerMettingDetail extends StatefulWidget {
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? brokerId;

  const BrokerMettingDetail(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.brokerId,
      y});

  @override
  State<BrokerMettingDetail> createState() => _BrokerMettingDetailState();
}

class _BrokerMettingDetailState extends State<BrokerMettingDetail> {
  String getOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<BrokerMeetingList>? brokerMeetingList = [];
  TextEditingController _remarkController = TextEditingController();
  // get all broker list
  Future<BrokerMeetingList?> getAllbrokerMeetingList() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "broker_id": widget.brokerId ?? '',
    };
    var response = await apiNetworkHandler.post(AppUrl.brokerMeetingList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = brokerMettingDetailModalFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          brokerMeetingList = dataModel.response?.brokerMeetingList;
        });
      }
    }
    return null;
  }

  Future<BrokerMeetingList?> addbrokerMeetingAdd() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "broker_id": widget.brokerId ?? '',
      "remark": _remarkController.text,
    };
    var response = await apiNetworkHandler.post(AppUrl.brokerMeetingAdd, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // final dataModel = brokerMettingDetailModalFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      _remarkController.clear();
      getAllbrokerMeetingList();
      //   setState(() {
      //     brokerMeetingList = dataModel.response?.brokerMeetingList;
      //   });
      // }
    }
    return null;
  }

  @override
  void initState() {
    getAllbrokerMeetingList();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            '${widget.projectName?.toUpperCase()} ${widget.towarName!.isNotEmpty ? "-" : ""} ${widget.towarName!.toUpperCase()}',
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
            padding: EdgeInsets.only(top: 8, bottom: 10),
            width: double.maxFinite,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            child: Text(
              'CP Meeting Detail',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    "Description",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                horizontalSpaceMedium,
                const Center(child: Icon(Icons.remove, color: Colors.black54)),
                horizontalSpaceLarge,
                Expanded(
                  child: TextFormField(
                    maxLines: 3,
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "(Remark Cannot Be Empty)";
                    //   }
                    // },
                    // validator: validator,
                    // enabled: false,
                    controller: _remarkController,
                    style: const TextStyle(color: Colors.black, fontSize: 15.0),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black45),
                      // suffixIcon: const Icon(
                      //   Icons.keyboard_arrow_down_sharp,
                      // ),
                      contentPadding: const EdgeInsets.all(10),
                      border: InputBorder.none,
                      hintText: 'Enter Remark',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF5F5C5C)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: (Color(0xFF5F5C5C)),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: (Colors.red),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: (Color(0xFF5F5C5C)),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              // SizedBox(
              //   width: 360,
              // ),
              Spacer(),
              InkWell(
                onTap: () {
                  addbrokerMeetingAdd();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Spacer(),
            ],
          ),
          SizedBox(height: 10),
          Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: brokerMeetingList?.length ?? 0,
              shrinkWrap: true,
              itemBuilder: ((BuildContext context, int index) {
                // Reverse the list by accessing items in reverse order
                final reversedIndex =
                    (brokerMeetingList?.length ?? 0) - 1 - index;
                final brokerMeeting = brokerMeetingList?[reversedIndex];

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              '${getOrdinal(((brokerMeetingList?.length ?? 0) - 1 - index) + 1)} Update',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          horizontalSpaceMedium,
                          Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Expanded(
                            child: Text(
                              brokerMeeting?.remark ?? '',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              "Submitted By",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          horizontalSpaceMedium,
                          Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(
                            brokerMeeting?.userName ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Text(
                              "Dated On",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          horizontalSpaceMedium,
                          Center(
                              child: Icon(Icons.remove, color: Colors.black54)),
                          horizontalSpaceLarge,
                          Text(
                            DateFormat('dd-MM-yyyy').format(
                                brokerMeeting?.createdAt ?? DateTime.now()),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              separatorBuilder: ((BuildContext context, int index) {
                return const Divider();
              }),
            ),
          ),
        ],
      ),
    );
  }
}
