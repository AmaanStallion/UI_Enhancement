import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/models/get_flat_list_by_project.dart';
import 'package:stallion/models/get_parking_by_flat.dart';
import 'package:stallion/models/get_parking_inventery_pdf.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/salesmanagement/availableInventory/tenantDetail.dart';
import 'package:stallion/ui/views/salesmanagement/bookasaleview.dart';
import 'package:stallion/ui/views/salesmanagement/bookingdetailsview.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingListScreen extends StatefulWidget {
  const ParkingListScreen({
    super.key,
    this.projectId = "",
    this.towarId = "",
    this.projectName = "",
    this.towarName = "",
    this.flatId,
    this.title,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? flatId;
  final String? title;

  @override
  State<ParkingListScreen> createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<FlatParking>? flatParking = [];
  String? filePath = '';

  Future<FlatParking?> getParkingByFlat() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? "",
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "flat_id": widget.flatId ?? '',
    };

    var response =
        await apiNetworkHandler.post(AppUrl.webGetParkingByFlat, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getParkingByFlatFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          flatParking = dataModel.response?.flatParking;
        });
      }
    }
    return null;
  }

  Future<FlatParking?> getParkingInventeryPdf() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? "",
      "project_id": widget.projectId ?? '',
      "towar_id": widget.towarId ?? '',
      "flat_id": widget.flatId ?? '',
    };

    var response =
        await apiNetworkHandler.post(AppUrl.webParkingInventeryPdf, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getParkingInventeryPdfFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          filePath = dataModel.response?.filePath;
        });
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getParkingByFlat();
    getParkingInventeryPdf();
  }

  Color getParkingBackground({required FlatParking data}) {
    if (data.availableStatus == "1") {
      return const Color.fromRGBO(229, 12, 17, 1.0);
    } else if (data.availableStatus == "2") {
      return const Color.fromRGBO(50, 94, 168, 1.0);
    } else {
      return const Color.fromRGBO(1, 111, 1, 1.0);
    }
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
          widget.towarName!.isNotEmpty
              ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
              : widget.projectName!.toUpperCase(),
          style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Container(
        // padding: const EdgeInsets.symmetric(horizontal: 60),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const SizedBox(height: 34),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  children: [
                    const SizedBox(width: 30),
                    const Spacer(),
                    AppText(
                      title:
                          '${widget.title} - (${flatParking!.length})', // "AVAILABLE INVENTORY",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      titleTextAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse(filePath ?? '');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          throw 'Could not launch';
                        }
                      },
                      child: const Icon(
                        Icons.download,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Wrap(
                spacing: 20.0,
                runSpacing: 30,
                children: [
                  for (int i = 0; i < flatParking!.length; i++)
                    InkWell(
                      onTap: () {
                        print('-------------------');
                        if (flatParking![i].availableStatus == "1") {
                          Color.fromRGBO(229, 12, 17, 1.0);
                          if (flatParking![i].availableType == "2") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return TenantDetail(
                                    inventyParkingNumber:
                                        flatParking![i].mstParkingId ?? '',
                                    tenentId:
                                        flatParking![i].buyerTenantId ?? '',
                                    flatId:
                                        flatParking![i].inventryAllocatedId ??
                                            '',
                                    projectId: widget.projectId,
                                    projectName: widget.projectName,
                                    towarId: widget.towarId,
                                    towarName: widget.towarName!,
                                    podiumList: [],
                                  );
                                },
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return BookingDetailsView(
                                    flat_buyer_id:
                                        flatParking![i].buyerTenantId,
                                    // memberShipForm: widget.member_ship_form,
                                    projectId: widget.projectId,
                                    projectName: widget.projectName,
                                    towarId: widget.towarId,
                                    towarName: widget.towarName!,
                                    flatBuyerRequest: FlatBuyerRequest(),
                                    // flatAvailableListData
                                    //     .floorDetails!
                                    //     .flatDetails?[i]
                                    //     .flatBuyerDetails?[0],
                                    navigationFlag: 'SoldInventory',
                                    title: '',
                                    // inventryFlatName: flatAvailableListData
                                    //     .floorDetails!
                                    //     .flatDetails?[i]
                                    //     .inventryFlatName,
                                  );
                                },
                              ),
                            );
                          }
                        } else if (flatParking![i].availableStatus == "2") {
                          Color.fromRGBO(50, 94, 168, 1.0);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return BookaSaleFormView(
                                    flatbuyerid: flatParking?[i].buyerTenantId,
                                    flatidfk:
                                        flatParking?[i].inventryAllocatedId,
                                    projectId: widget.projectId,
                                    towarId: widget.towarId!,
                                    projectName: widget.projectName,
                                    strBuyerID: flatParking?[i].buyerTenantId,
                                    flatBuyerRequest: FlatBuyerRequest(),
                                    flagRedirect: "Reserve Avail",
                                    isFlatListFromReserve: FlatList(),
                                    flatNoIds: [
                                      flatParking?[i].inventryAllocatedId
                                    ]);
                              },
                            ),
                          );
                        } else {
                          Color.fromRGBO(1, 111, 1, 1.0);
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 146,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            // padding: const EdgeInsets.symmetric(
                            //     horizontal: 30, vertical: 16),
                            decoration: BoxDecoration(
                              color:
                                  getParkingBackground(data: flatParking![i]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              flatParking?[i].parkingSerialNo ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            flatParking?[i].flatName ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              // color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
