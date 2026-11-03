import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/salesmanagement/plotdetailsview.dart';
import 'package:zoom_widget/zoom_widget.dart';
import '../../../models/get_plot_listing.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import 'bookasaleview.dart';
import 'bookingdetailsview.dart';
import 'membershipform.dart';

class PlotDisplayView extends StatefulWidget {
  const PlotDisplayView({
    super.key,
    this.projectId = "",
    this.towarId = "",
    this.projectName = "",
    this.towarName = "",
    this.member_ship_form = "0",
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? member_ship_form;

  @override
  State<PlotDisplayView> createState() => _PlotDisplayViewState();
}

class _PlotDisplayViewState extends State<PlotDisplayView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  List<Path> paths = [];
  List<Map<String, String>> flatSelected = [];
  List<PlotDetail>? plotDetails = [];
  String? plotDrawing = "";
  bool flagcalled = false;

  Future<ResponseGetPlotListing?> getPlotingDisplayStatus() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
    };

    var response =
        await apiNetworkHandler.post(AppUrl.wsgetPlotingDisplay, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPlotListingFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        plotDetails = dataModel.response?.plotDetails!;
        plotDrawing = dataModel.response?.plotDrawing!;

        paths = [];

        for (int j = 0; j < plotDetails!.length; j++) {
          var arrPoints = plotDetails![j].plotPoints!;

          final path = Path();

          for (int i = 0; i < arrPoints.length; i++) {
            if (i == 0) {
              path.moveTo(
                  double.parse(arrPoints[i].x!), double.parse(arrPoints[i].y!));
            } else {
              if (i == (arrPoints.length - 1)) {
                path.lineTo(double.parse(arrPoints[i].x!),
                    double.parse(arrPoints[i].y!));
                path.lineTo(double.parse(arrPoints[0].x!),
                    double.parse(arrPoints[0].y!));
              } else {
                path.lineTo(double.parse(arrPoints[i].x!),
                    double.parse(arrPoints[i].y!));
              }
            }
          }
          path.close();

          paths.add(path);
        }

        setState(() {
          flagcalled = true;
        });
      }
    }
  }

  // let dict = ["flat_id": "\(area.flatId)", "flat_name": "\(area.inventry_flat_name)", "flat_area": "\(area.flat_area)", "floor_number": "\(area.floor_number)"]

  @override
  void initState() {
    // TODO: implement initState
    getPlotingDisplayStatus();
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
      body: flagcalled == true
          ? Zoom(
              backgroundColor: Colors.white,
              initTotalZoomOut: true,
              child: Center(
                child: SizedBox(
                    width: 600,
                    height: 462,
                    child: GestureDetector(
                      onTapUp: (details) {
                        // Handle the click event based on the click coordinates
                        final clickPoint = details.localPosition;
                        print(clickPoint);
                        // let dict = ["flat_id": "\(area.flatId)", "flat_name": "\(area.inventry_flat_name)", "flat_area": "\(area.flat_area)", "floor_number": "\(area.floor_number)"]

                        for (int i = 0; i < paths.length; i++) {
                          if (paths[i].contains(clickPoint)) {
                            // Path at index i was clicked
                            print('Path $i clicked!');
                            print(plotDetails![i].plotNo);

                            if (plotDetails![i].availableStatus == "3") {
                              //Reserve
                              print('clicked');
                              List<String> flatId = [];
                              double totalflatAreaCount = 0;
                              for (int i = 0; i < flatSelected.length; i++) {
                                flatId
                                    .add(flatSelected[i]["flat_id"].toString());
                                totalflatAreaCount = totalflatAreaCount +
                                    double.parse(flatSelected[i]["flat_area"]
                                        .toString());
                              }
                              if (widget.member_ship_form == "1") {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return MembershipFormView(
                                    strBuyerID: plotDetails![i]
                                            .flatDetails![0]
                                            .flatBuyerDetails![0]
                                            .flatBuyerId! ??
                                        '',
                                    projectId: widget.projectId,
                                    towarId: widget.towarId!,
                                    projectName: widget.projectName,
                                    flagRedirect: "Reserve",
                                    flatNoIds: flatId,
                                    totalflatAreaCount: "0",
                                    flatBuyerRequest: plotDetails![i]
                                        .flatDetails![0]
                                        .flatBuyerDetails![0],
                                  );
                                }));
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return BookaSaleFormView(
                                        flatbuyerid: plotDetails![i]
                                            .flatDetails![0]
                                            .flatBuyerDetails![0]
                                            .flatBuyerId,
                                        flatidfk: plotDetails![i].flatId ?? '',
                                        projectId: widget.projectId!,
                                        towarId: widget.towarId!,
                                        projectName: widget.projectName!,
                                        flatBuyerRequest: plotDetails![i]
                                            .flatDetails![0]
                                            .flatBuyerDetails![0],
                                        flagRedirect: 'Reserve',
                                      );
                                    },
                                  ),
                                );
                              }
                            } else if (plotDetails![i].availableStatus == "1") {
                              //Sold
                              print('SOLD');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return BookingDetailsView(
                                        memberShipForm: widget.member_ship_form,
                                        projectId: widget.projectId,
                                        projectName: widget.projectName,
                                        towarId: widget.towarId,
                                        towarName: widget.towarName!,
                                        flatBuyerRequest: plotDetails![i]
                                            .flatDetails![0]
                                            .flatBuyerDetails![0],
                                        navigationFlag: 'SoldInventory',
                                        title:
                                            '${plotDetails![i].flatDetails![0].flatBuyerDetails![0].flatBuyerName!} ${plotDetails![i].flatDetails![0].flatName!}');
                                  },
                                ),
                              );
                            } else {
                              //Available
                              setState(() {
                                if (plotDetails![i].selected == "true") {
                                  plotDetails![i].selected = "";
                                  for (int j = 0;
                                      j < flatSelected.length;
                                      j++) {
                                    if (flatSelected[j]["flat_id"] ==
                                        plotDetails![i].flatId) {
                                      flatSelected.removeAt(j);
                                      break;
                                    }
                                  }
                                } else {
                                  plotDetails![i].selected = "true";
                                  flatSelected.add(
                                    {
                                      'flat_id': plotDetails![i].flatId!,
                                      'flat_name': plotDetails![i].flatName!,
                                      'flat_area': plotDetails![i].flatArea!,
                                      'floor_number':
                                          plotDetails![i].floorNumber!,
                                    },
                                  );
                                }
                              });
                              print(flatSelected);
                            }
                            break; // Exit the loop after finding the first matching path
                          }
                        }
                      },
                      child: CustomPaint(
                          size: const Size(600, 462),
                          foregroundPainter: LinePainter(plotDetails),
                          child: Image.network(plotDrawing!)),
                    )),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Container(
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (flatSelected.isEmpty) {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text(''),
                              content: const Text('Please select a Plot.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17.0)),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      fixedSize: const Size.fromWidth(100),
                                      padding: const EdgeInsets.all(10),
                                      textStyle:
                                          const TextStyle(color: Colors.white)),
                                  child: const Text('CLOSE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.white)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return PlotDetailsView(
                        projectId: widget.projectId,
                        towarId: widget.towarId!,
                        projectName: widget.projectName,
                        towarName: widget.towarName!,
                        member_ship_form: widget.member_ship_form,
                        flatSelected: flatSelected,
                      );
                    }));
                  }
                },
                child: Container(
                  color: Colors.black,
                  height: 45,
                  child: const Center(
                      child: Text(
                    'VIEW DETAILS',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  )),
                ),
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  if (flatSelected.isEmpty) {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text(''),
                              content: const Text('Please select a Plot.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17.0)),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      fixedSize: const Size.fromWidth(100),
                                      padding: const EdgeInsets.all(10),
                                      textStyle:
                                          const TextStyle(color: Colors.white)),
                                  child: const Text('CLOSE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.white)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ));
                  } else {
                    print('clicked');
                    List<String> flatId = [];
                    double totalflatAreaCount = 0;
                    for (int i = 0; i < flatSelected.length; i++) {
                      flatId.add(flatSelected[i]["flat_id"].toString());
                      totalflatAreaCount = totalflatAreaCount +
                          double.parse(flatSelected[i]["flat_area"].toString());
                    }
                    if (widget.member_ship_form == "1") {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return MembershipFormView(
                          projectId: widget.projectId,
                          towarId: widget.towarId!,
                          projectName: widget.projectName,
                          flagRedirect: "InventoryNew",
                          flatNoIds: flatId,
                          totalflatAreaCount: "0",
                        );
                      }));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return BookaSaleFormView(
                          projectId: widget.projectId,
                          towarId: widget.towarId!,
                          projectName: widget.projectName,
                          flagRedirect: "InventoryNew",
                          flatNoIds: flatId,
                          totalflatAreaCount: totalflatAreaCount.toString(),
                        );
                      }));
                    }
                  }
                },
                child: Container(
                  color: Colors.black,
                  height: 45,
                  child: const Center(
                      child: Text('PROCEED FOR BOOKING',
                          style: TextStyle(color: Colors.white, fontSize: 17))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<ui.Image> loadImageFromNetwork(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
      final info = await codec.getNextFrame();
      return info.image;
    } else {
      throw Exception('Failed to load image');
    }
  }
}

class LinePainter extends CustomPainter {
  List<PlotDetail>? plotDetails;

  LinePainter(this.plotDetails);

  @override
  void paint(Canvas canvas, Size size) {
    for (int j = 0; j < plotDetails!.length; j++) {
      var arrPoints = plotDetails![j].plotPoints!;

      final path = Path();

      for (int i = 0; i < arrPoints.length; i++) {
        double sX = double.parse(arrPoints[i].x!);
        double sY = double.parse(arrPoints[i].y!);
        double eX = i == (arrPoints.length - 1)
            ? double.parse(arrPoints[0].x!)
            : double.parse(arrPoints[i + 1].x!);
        double eY = i == (arrPoints.length - 1)
            ? double.parse(arrPoints[0].y!)
            : double.parse(arrPoints[i + 1].y!);
        var startPoint = Offset(sX, sY);
        var endPoint = Offset(eX, eY);
        final paint = Paint()
          ..color = Colors.red
          ..strokeWidth = 2.0;
        canvas.drawLine(startPoint, endPoint, paint);

        if (i == 0) {
          path.moveTo(
              double.parse(arrPoints[i].x!), double.parse(arrPoints[i].y!));
        } else {
          if (i == (arrPoints.length - 1)) {
            path.lineTo(
                double.parse(arrPoints[i].x!), double.parse(arrPoints[i].y!));
            path.lineTo(
                double.parse(arrPoints[0].x!), double.parse(arrPoints[0].y!));
          } else {
            path.lineTo(
                double.parse(arrPoints[i].x!), double.parse(arrPoints[i].y!));
          }
        }
      }
      path.close();

      if (plotDetails![j].availableStatus == "3") {
        final paint1 = Paint()
          ..color =
              const Color.fromRGBO(112, 159, 230, 1.0); // Color Reserve Blue
        canvas.drawPath(path, paint1);
      } else if (plotDetails![j].availableStatus == "1") {
        final paint1 = Paint()
          ..color = const Color.fromRGBO(230, 94, 67, 1.0); // Color Reserve red
        canvas.drawPath(path, paint1);
      } else {
        final paint1 = Paint()
          ..color = plotDetails![j].selected == ""
              ? const Color.fromRGBO(129, 209, 100, 1.0)
              : plotDetails![j].selected == "true"
                  ? Colors.yellow
                  : const Color.fromRGBO(129, 209, 100, 1.0);

        canvas.drawPath(path, paint1);
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: plotDetails![j].inventryFlatName!,
          style: const TextStyle(
            color: Colors.black, // Text color
            fontSize: 7, // Text size
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.width);
      double xAxis = 0.0;
      double yAxis = 0.0;

      for (int p = 0; p < arrPoints.length; p++) {
        xAxis = xAxis + double.parse(arrPoints[p].x ?? '0');
        yAxis = yAxis + double.parse(arrPoints[p].y ?? '0');
      }
      final textOffset =
          Offset(xAxis / arrPoints.length - 4, yAxis / arrPoints.length - 3);
      // final textOffset = Offset(xAxis / 4.2, yAxis / 4.1);

      // final textOffset = Offset(
      //   (((double.parse(arrPoints[0].x!) + double.parse(arrPoints[2].x!)) / 2) -
      //       8 -
      //       (textPainter.width) / 5),
      //   (((double.parse(arrPoints[1].y!) + double.parse(arrPoints[1].y!)) / 2) +
      //       20 -
      //       (textPainter.height) / 0.6),
      // );

      // final textOffset = Offset(
      //   (((double.parse(arrPoints[0].x!) +
      //               double.parse(arrPoints[arrPoints.length - 1].x!)) /
      //           2) -
      //       8 -
      //       (textPainter.width) / 2),
      //   (((double.parse(arrPoints[0].y!) +
      //               double.parse(arrPoints[arrPoints.length - 1].y!)) /
      //           2) +
      //       20 -
      //       (textPainter.height) / 2),
      // );

      textPainter.paint(canvas, textOffset);
      // Offset((587.02 / 5.2), (1832.88 / 5.1)));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
