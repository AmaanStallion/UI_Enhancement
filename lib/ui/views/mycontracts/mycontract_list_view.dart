import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/group_contractor_category_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/mycontracts/mycontracts.dart';
import 'package:stallion/utils/app_url.dart';

class MycontractListView extends StatefulWidget {
  MycontractListView(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName,
      this.navigationFlag});

  String? projectId;
  String? towarId;
  String? projectName;
  String? navigationFlag;
  String? towarName;

  @override
  State<MycontractListView> createState() => _MycontractListViewState();
}

class _MycontractListViewState extends State<MycontractListView> {
  TextEditingController editingController = TextEditingController();
  List<FianlResult>? filteredResult = [];
  List<OrderList>? orderList = [];
  OrderList? orderListSelected = OrderList(id: '', name: "All");
  TowarList? towarListSelected = TowarList(towarId: '', towarName: '');
  String? accountFlag = '0';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String formatToIndianStandard(double numberString) {
    final indianRupeesFormat = NumberFormat.currency(
      name: "INR",
      locale: 'en_IN',
      decimalDigits: 2, // change it to get decimal places
      symbol: '₹ ',
    );
    return indianRupeesFormat.format(numberString);
  }

  String? offset = '0';
  List<FianlResult>? fianlResult = [];
  TotalBBar? totalBtmBar;

  Future<dynamic?> getGroupContractorCategoryList() async {
    if (kDebugMode) {
      print("getGroupContractorCategoryList called");
    }
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    String towerId = "";
    if (widget.towarId != null) {
      towerId = widget.towarId!;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.navigationFlag == "SideMenu"
          ? orderListSelected?.id ?? ""
          : widget.projectId ?? '',
      //orderListSelected?.id ?? "",
      "towar_id": widget.navigationFlag == "SideMenu"
          ? towarListSelected?.towarId ?? ''
          : widget.towarId ?? '',
      "limit": "20",
      "offset": offset!,
      "login_type": loginType ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(
        AppUrl.getGroupContractorCategoryList, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      //context.loaderOverlay.hide();
      final dataModel = groupContractorCategoryListFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          accountFlag = dataModel.response?.accountFlag ?? '0';
          if (orderList!.isEmpty) {
            orderList = dataModel.response?.orderList;
          }
          fianlResult = dataModel.response?.fianlResult;
          filteredResult = fianlResult;

          totalBtmBar = dataModel.response?.totalBtmBar;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  List<OrderList> searchSlabList(
      // List<MasnoryList>? masnoryList = [];

      List<OrderList> objects,
      String query) {
    query = query
        .toLowerCase(); // Convert the query to lowercase for case-insensitive search
    return objects
        .where((obj) =>
            obj.name!.toLowerCase().contains(query) ||
            obj.name.toString().contains(query))
        .toList();
  }

  selectSlabNumberModal() {
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                'SELECT SLAB NUMBER',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    getGroupContractorCategoryList();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "ADD",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
              content: SizedBox(
                width: 500,
                height: 404,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              // isLoad = false;
                            });
                          },
                          style: const TextStyle(fontSize: 13),
                          controller: editingController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              labelText: "Search by Name",
                              hintText: "Search by Name",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 340,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: searchSlabList(
                                    orderList!, editingController.text)
                                .length,
                            itemBuilder: (context, int indexFor) {
                              OrderList contrctorListTemp = searchSlabList(
                                  orderList!, editingController.text)[indexFor];

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    orderListSelected = contrctorListTemp;
                                    // _slabNumberController.text =
                                    //     contrctorListTemp.name ?? '';
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 13.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            contrctorListTemp.name ?? '',
                                            style: normalText,
                                          ),
                                          orderListSelected?.id ==
                                                  contrctorListTemp.id
                                              ? const Icon(
                                                  Icons
                                                      .check_circle_outline_outlined,
                                                  size: 25,
                                                  color: Colors.green,
                                                )
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                  size: 25,
                                                  color: Colors.grey,
                                                )
                                        ],
                                      ),
                                      verticalSpaceSmall,
                                      const Divider(
                                          height: 1.0, color: Colors.black),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        }).then((_) {
      setState(() {});
    });
  }

  selectTowerModal() {
    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                'SELECT TOWER',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    getGroupContractorCategoryList();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Center(
                      child: Text(
                        "ADD",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
              content: SizedBox(
                width: 500,
                height: 404,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // SizedBox(
                      //   height: 40,
                      //   child: TextField(
                      //     onChanged: (value) {
                      //       setState(() {
                      //         // isLoad = false;
                      //       });
                      //     },
                      //     style: const TextStyle(fontSize: 13),
                      //     controller: editingController,
                      //     decoration: const InputDecoration(
                      //         contentPadding: EdgeInsets.all(12.0),
                      //         labelText: "Search by Name",
                      //         hintText: "Search by Name",
                      //         prefixIcon: Icon(Icons.search),
                      //         border: OutlineInputBorder(
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(25.0)))),
                      //   ),
                      // ),
                      // const SizedBox(height: 10),
                      SizedBox(
                        height: 340,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            // itemCount: searchSlabList(
                            //         orderList!, editingController.text)
                            //     .length,
                            itemCount: orderListSelected?.towarList?.length,
                            itemBuilder: (context, int indexFor) {
                              TowarList contrctorListTemp =
                                  orderListSelected!.towarList![indexFor];
                              // searchSlabList(
                              //     orderList!, editingController.text)[indexFor];

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    towarListSelected = contrctorListTemp;
                                    // _slabNumberController.text =
                                    //     contrctorListTemp.name ?? '';
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 13.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            contrctorListTemp.towarName ?? '',
                                            style: normalText,
                                          ),
                                          towarListSelected?.towarId ==
                                                  contrctorListTemp.towarId
                                              ? const Icon(
                                                  Icons
                                                      .check_circle_outline_outlined,
                                                  size: 25,
                                                  color: Colors.green,
                                                )
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                  size: 25,
                                                  color: Colors.grey,
                                                )
                                        ],
                                      ),
                                      verticalSpaceSmall,
                                      const Divider(
                                          height: 1.0, color: Colors.black),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        }).then((_) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    offset = '0';
    getGroupContractorCategoryList();
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
            widget.navigationFlag! == 'SideMenu'
                ? 'ALL PROJECTS'
                : widget.towarName!.isNotEmpty
                    ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                    : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: widget.navigationFlag! == 'SideMenu'
            ? const SizedBox()
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
      ),
      bottomNavigationBar: accountFlag == '1'
          ? Container(
              height: 74,
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey))),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                            right: BorderSide(color: Colors.grey),
                            bottom: BorderSide(color: Colors.grey),
                          )),
                          // width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              const Text(
                                'Total',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                formatToIndianStandard(double.parse(
                                    totalBtmBar?.totalPayment.toString() ??
                                        '0')),
                                // totalBtmBar?.totalPayment.toString() ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                            right: BorderSide(color: Colors.grey),
                            bottom: BorderSide(color: Colors.grey),
                          )),
                          // width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              const Text(
                                'Work Done',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                formatToIndianStandard(double.parse(
                                    totalBtmBar?.dueAmount.toString() ?? '0')),
                                // totalBtmBar?.dueAmount.toString() ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                            right: BorderSide(color: Colors.grey),
                            bottom: BorderSide(color: Colors.grey),
                          )),
                          // width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              const Text(
                                'Total Paid',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                formatToIndianStandard(double.parse(
                                    totalBtmBar?.paidAmount.toString() ?? '0')),
                                // totalBtmBar?.paidAmount.toString() ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                            right: BorderSide(color: Colors.grey),
                            bottom: BorderSide(color: Colors.grey),
                          )),
                          // width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            children: [
                              const Text(
                                'Amount Due',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                formatToIndianStandard(double.parse(
                                    totalBtmBar?.overDueAmount.toString() ??
                                        '0')),
                                // totalBtmBar?.overDueAmount.toString() ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Cost to Complete : ${totalBtmBar?.totalPayment.toString() ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
      body: Column(
        children: [
          // Text('data'),
          const SizedBox(
              height: 40,
              child: Center(
                  child: Text('MY CONTRACTS',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center))),

          const Divider(height: 1.0, color: Colors.black),

          if (widget.navigationFlag == "SideMenu")
            SizedBox(
                height: 40,
                child: InkWell(
                  onTap: () {
                    selectSlabNumberModal();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(orderListSelected?.name ?? '',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center),
                      const Icon(Icons.keyboard_arrow_down_rounded)
                    ],
                  ),
                )),

          const Divider(height: 1.0, color: Colors.black),
          if (orderListSelected?.towarList != null &&
              orderListSelected?.towarList?.length != 0)
            SizedBox(
                height: 40,
                child: InkWell(
                  onTap: () {
                    selectTowerModal();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          towarListSelected?.towarName == ''
                              ? 'All'
                              : towarListSelected?.towarName ?? '',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center),
                      const Icon(Icons.keyboard_arrow_down_rounded)
                    ],
                  ),
                )),

          if (orderListSelected?.towarList != null &&
              orderListSelected?.towarList?.length != 0)
            const Divider(height: 1.0, color: Colors.black),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 60.0, right: 60),
            child: SizedBox(
              height: 40,
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    filteredResult = fianlResult
                        ?.where((item) =>
                            item.name
                                ?.toLowerCase()
                                .contains(value.toLowerCase()) ??
                            false)
                        .toList();
                  });
                },
                style: const TextStyle(fontSize: 13),
                controller: editingController,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    // labelText:
                    //     "Search by PO.No, Booking type or Vendor Name",
                    hintText: "Search by Category",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
          ),
          const SizedBox(height: 10),

          const Divider(height: 1.0, color: Colors.black),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black26))),
            child: const Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // width: MediaQuery.of(context).size.width * 0.42,
                  child: Text('Category',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      )),
                ),
                Expanded(
                  // width: MediaQuery.of(context).size.width * 0.42,
                  child: Text('No. of WO',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      )),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredResult == null || filteredResult!.isEmpty
                ? const Center(
                    child: Text(
                      'No Data Found',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredResult!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return MyContractsView(
                                  developerId: fianlResult?[index].developerId,
                                  projectId: widget.projectId ?? '',
                                  towarId: widget.towarId ?? '',
                                  projectName: widget.projectName ?? '',
                                  towarName: widget.towarName ?? '',
                                  navigationFlag: 'Project',
                                  categoryId: fianlResult?[index].id,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 8),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 242, 240, 240),
                            border: Border(
                              bottom: BorderSide(color: Colors.black26),
                            ),
                          ),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // width: MediaQuery.of(context).size.width * 0.42,
                                child: Text(fianlResult?[index].name ?? '',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                              Expanded(
                                child: Text(
                                    fianlResult?[index].count.toString() ?? '',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Colors.transparent,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
