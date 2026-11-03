import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/finishing_listing.dart';
import 'package:stallion/models/tenant_payment_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/finishing/inidvidual_finishing.dart';
import 'package:stallion/utils/app_url.dart';

class FinishingScreen extends StatefulWidget {
  const FinishingScreen(
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
  State<FinishingScreen> createState() => _FinishingScreenState();
}

class _FinishingScreenState extends State<FinishingScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isInterior = false;
  List<FlatDetailsList>? flatDetailsListData = [];
  Future<List<FlatDetailsList>?> getFinishingList() async {
    try {
      CustomLoading.progressDialog(isLoading: true, context: context);
      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getFinishingListing, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = finishingListingFromJson(response.body);
        if (dataModel.response?.errorCode == "0") {
          setState(() {
            flatDetailsListData = dataModel.response?.flatDetailsList;
          });
        }
      } else {}
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    } finally {
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
      bottomNavigationBar: isInterior
          ? const SizedBox()
          : Container(
              height: 80,
              color: const Color.fromRGBO(0, 0, 0, 1),
              // padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Text('SUBMIT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.black,
                            child: const Column(
                              children: [
                                Text('Total List',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center),
                                Text('3',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: const Column(
                              children: [
                                Text('Completed',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center),
                                Text('2',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: const Column(
                              children: [
                                Text('Pending',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center),
                                Text('1',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
            child: Row(
              children: [
                SizedBox(width: 50),
                SizedBox(width: 70),
                Spacer(),
                Text('FINISHING',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center),
                Spacer(),
                isInterior
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return IndividualFinishing(
                                    projectId: widget.projectId,
                                    towarId: widget.towarId!,
                                    projectName: widget.projectName,
                                    towarName: widget.towarName!,
                                    slabName: '',
                                    floorId: '');
                              },
                            ),
                          );
                        },
                        child: Container(
                          // width: 70,
                          padding:
                              EdgeInsets.symmetric(horizontal: 22, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "ALL",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 69.8,
                      ),
                SizedBox(width: 50)
              ],
            ),
          ),
          const Divider(
            height: 1.0,
            color: Colors.black,
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      isInterior = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: isInterior ? Colors.transparent : Colors.black,
                    child: Text(
                      "Exterior",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isInterior ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      isInterior = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: isInterior ? Colors.black : Colors.transparent,
                    child: Text(
                      "Interior",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isInterior ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          isInterior ? interior() : exterior(),
        ],
      ),
    );
  }

  Widget exterior() {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        children: [
          // const SizedBox(height: 10),
          Container(
            color: Colors.black,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: const Text(
                      "Raw Materials",
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 140,
                  child: const Text(
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
                Container(
                  width: 80,
                  child: const Text(
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
                Container(
                  width: 100,
                  child: const Text(
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
          const SizedBox(height: 8),
          const Divider(
              // color: Colors.black,
              ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: const Text(
                      "External Paint",
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 140,
                  child: const Text(
                    "155 Sq.Ft",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                Container(
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
                  child: TextFormField(
                    decoration: const InputDecoration(
                      // icon: Icon(Icons.person),
                      hintText: 'Qty / Units',
                      // labelText: 'Name *',
                    ),
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                    },
                    // validator: (String? value) {
                    //   return (value != null && value.contains('@'))
                    //       ? 'Do not use the @ char.'
                    //       : null;
                    // },
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
                Container(
                  width: 100,
                  child: const Text(
                    "155 Sq.Ft",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                true
                    ? const Icon(
                        Icons.check_circle_outlined,
                        color: Colors.green,
                        size: 26,
                      )
                    : const SizedBox(width: 26),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: const Divider()),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: const Text(
                      "Plaster",
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 140,
                  child: const Text(
                    "500 Sq.Ft",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                Container(
                  width: 80,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Qty / Units',
                    ),
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                    },
                    // validator: (String? value) {
                    //   return (value != null && value.contains('@'))
                    //       ? 'Do not use the @ char.'
                    //       : null;
                    // },
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
                Container(
                  width: 100,
                  child: const Text(
                    "500 Sq.Ft",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                true
                    ? const Icon(
                        Icons.check_circle_outlined,
                        color: Colors.green,
                        size: 26,
                      )
                    : const SizedBox(width: 26),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: const Divider()),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: const Text(
                      "Lighting",
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 140,
                  child: const Text(
                    "100 Nos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                Container(
                  width: 80,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Qty / Units',
                    ),
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                    },
                    // validator: (String? value) {
                    //   return (value != null && value.contains('@'))
                    //       ? 'Do not use the @ char.'
                    //       : null;
                    // },
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
                Container(
                  width: 100,
                  child: const Text(
                    "30 Nos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red),
                  ),
                ),
                false
                    ? const Icon(
                        Icons.check_circle_outlined,
                        color: Colors.green,
                        size: 26,
                      )
                    : const SizedBox(width: 26),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget interior() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // const SizedBox(height: 10),
          // const Divider(),
          // const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            itemCount: flatDetailsListData?.length ?? 0,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(
                    width: 200,
                    child: Text(
                      "${flatDetailsListData?[index].floorName}",
                      // textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  for (int i = 0;
                      i < flatDetailsListData![index].flatDetails!.length;
                      i++)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return IndividualFinishing(
                                  flatDetailsListSelected:
                                      flatDetailsListData![index]
                                          .flatDetails?[i],
                                  projectId: widget.projectId,
                                  towarId: widget.towarId!,
                                  projectName: widget.projectName,
                                  towarName: widget.towarName!,
                                  slabName: flatDetailsListData![index]
                                      .flatDetails?[i]
                                      .flatName,
                                  floorId: flatDetailsListData![index]
                                      .flatDetails?[i]
                                      .floorId);
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          flatDetailsListData![index]
                                  .flatDetails?[i]
                                  .flatName ??
                              '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return IndividualFinishing(
                              slabName: "1st Floor",
                              projectId: widget.projectId,
                              towarId: widget.towarId!,
                              projectName: widget.projectName,
                              towarName: widget.towarName!,
                              flatDetailsListSelected: null,
                              floorName: flatDetailsListData?[index].floorName,
                            );
                          },
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Text(
                          "List",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_right_sharp,
                          color: Colors.black54,
                          size: 30,
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
