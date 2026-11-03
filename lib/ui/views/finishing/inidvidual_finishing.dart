import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/finishing_flat_listing.dart';
import 'package:stallion/models/finishing_listing.dart';
import 'package:stallion/models/tenant_payment_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/finishing/add_finishing_work.dart';
import 'package:stallion/utils/app_url.dart';

class IndividualFinishing extends StatefulWidget {
  const IndividualFinishing(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      required this.slabName,
      this.floorId,
      this.flatDetailsListSelected,
      this.floorName = "",
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? slabName;
  final String? floorId;
  final FlatDetail? flatDetailsListSelected;
  final String? floorName;

  @override
  State<IndividualFinishing> createState() => _IndividualFinishingState();
}

class _IndividualFinishingState extends State<IndividualFinishing> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<FinishingList>? finishingListData = [];
  List<BottomBar>? bottomBarData = [];
  Future<List<FinishingList>?> getFinishingList() async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
        "finishing_type": "2",
        "floor_id": widget.floorId ?? '',
        "floor_name": widget.floorName ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response = await apiNetworkHandler.post(AppUrl.getFinishing, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = finishingFlatListingFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            finishingListData = dataModel.response?.finishingList;
            bottomBarData = dataModel.response?.bottomBar;
          });
        }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
      // ignore: use_build_context_synchronously
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getFinishingList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: Container(
      //   color: Colors.black,
      //   padding: const EdgeInsets.symmetric(vertical: 10),
      //   child: const Text('SUBMIT',
      //       style: TextStyle(
      //         fontSize: 15,
      //         fontWeight: FontWeight.w500,
      //         color: Colors.white,
      //       ),
      //       textAlign: TextAlign.center),
      // ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                  widget.slabName == ""
                      ? "FINISHING"
                      : 'FINISHING (${widget.slabName})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center),
            ),
          ),
          const Divider(
            height: 1.0,
            color: Colors.black,
          ),
          // const SizedBox(height: 10),
          // const SizedBox(height: 10),
          Container(
            height: 44,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Raw Materials",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 140,
                  child: Text(
                    "Total Req./Units",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 16,
                  height: 20,
                  decoration: const BoxDecoration(
                      border: Border(
                    right: BorderSide(color: Colors.grey),
                  )),
                ),
                const SizedBox(width: 16),
                const SizedBox(
                  width: 80,
                  child: Text(
                    "Installed",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 16,
                  height: 20,
                  decoration: const BoxDecoration(
                      border: Border(
                    right: BorderSide(color: Colors.grey),
                  )),
                ),
                const SizedBox(width: 16),
                const SizedBox(
                  width: 100,
                  child: Text(
                    "Remaining Qty",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 26)
              ],
            ),
          ),
          // const SizedBox(height: 8),
          // const Divider(
          //     // color: Colors.black,
          //     ),
          //   const SizedBox(height: 8),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            itemCount: finishingListData?.length ?? 0,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (widget.slabName != "" && widget.floorName == "") {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) {
                    //       return AddFinishingWork(
                    //         flatDetailsListSelected:
                    //             widget.flatDetailsListSelected,
                    //         // finishingListData: finishingListData?[index],
                    //         projectId: widget.projectId,
                    //         towarId: widget.towarId!,
                    //         projectName: widget.projectName,
                    //         towarName: widget.towarName!,
                    //         // slabName: "Internal Paint (R-101)",
                    //       );
                    //     },
                    //   ),
                    // ).then((value) {
                    //   getFinishingList();
                    // });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          finishingListData?[index].name ?? '',
                          // textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Text(
                          '${finishingListData?[index].totalQty} ${finishingListData?[index].unitName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 20,
                        decoration: const BoxDecoration(
                            border: Border(
                          right: BorderSide(color: Colors.grey),
                        )),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        // child: TextFormField(
                        //   // controller: _txtControllerRemark,
                        //   maxLines: 1,
                        //   decoration: InputDecoration(
                        //       hintText: 'Quantity',
                        //       // contentPadding: EdgeInsets.zero,
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(5)),
                        //       focusedBorder: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(5),
                        //           borderSide: const BorderSide(color: Colors.black))),
                        // ),
                        // child: TextFormField(
                        //   decoration: const InputDecoration(
                        //     // icon: Icon(Icons.person),
                        //     hintText: 'Qty / Units',
                        //     // labelText: 'Name *',
                        //   ),
                        //   onSaved: (String? value) {
                        //     // This optional block of code can be used to run
                        //     // code when the user saves the form.
                        //   },
                        //   // validator: (String? value) {
                        //   //   return (value != null && value.contains('@'))
                        //   //       ? 'Do not use the @ char.'
                        //   //       : null;
                        //   // },
                        // ),
                        child: Text(
                          '${finishingListData?[index].consumQty} ${finishingListData?[index].unitName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 20,
                        decoration: const BoxDecoration(
                            border: Border(
                          right: BorderSide(color: Colors.grey),
                        )),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: Text(
                          '${finishingListData?[index].remaingQty} ${finishingListData?[index].unitName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      finishingListData?[index].remaingQty == '0' &&
                              finishingListData?[index].totalQty != "0"
                          ? const Icon(
                              Icons.check_circle_outlined,
                              color: Colors.green,
                              size: 26,
                            )
                          : const SizedBox(width: 26),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: const Divider(),
            ),
          ),
        ],
      ),
    );
  }
}
