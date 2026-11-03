// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:responsive_grid_list/responsive_grid_list.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../../models/get_plans_elevation.dart';
// import '../../../utils/api_network_call.dart';
// import '../../../utils/app_url.dart';
// import '../../shared/ui_helpers.dart';
// import '../mycontracts/imagepreviewview.dart';

// class PlansAndElevation extends StatefulWidget {
//   PlansAndElevation(
//       {Key? key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.towarName});

//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? towarName;

//   @override
//   State<PlansAndElevation> createState() => _PlansAndElevationState();
// }

// class _PlansAndElevationState extends State<PlansAndElevation> {
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   NetworkHandler apiNetworkHandler = NetworkHandler();

//   bool flagcalled = false;
//   List<PlansElevation>? plansElevation;

//   Future<ResponseGetPlansElevation?> fetchProjectPlansElevation() async {
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     String towerId = "";
//     if (widget.towarId != null) {
//       towerId = widget.towarId!;
//     }

//     Map<String, String> data = {
//       "user_id": userId!,
//       "project_id": widget.projectId!,
//       "towar_id": towerId
//     };

//     if (kDebugMode) {
//       print(data);
//     }

//     var response =
//         await apiNetworkHandler.post(AppUrl.webFetchPlansElevation, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = getPlansElevationFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response?.errorCode);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         setState(() {
//           flagcalled = true;
//           plansElevation = dataModel.response?.plansElevation;
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchProjectPlansElevation();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//             widget.towarName!.isNotEmpty
//                 ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
//                 : widget.projectName!.toUpperCase(),
//             style:
//                 const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.maybePop(context);
//           },
//         ),
//       ),
//       body: Container(
//         height: double.infinity,
//         color: Colors.white,
//         child: SafeArea(
//           child: flagcalled == true
//               ? plansElevation!.isNotEmpty
//                   ? Column(
//                       children: [
//                         const SizedBox(
//                           height: 40,
//                           child: Center(
//                             child: Text('PLANS & ELEVATION',
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 textAlign: TextAlign.center),
//                           ),
//                         ),
//                         const Divider(
//                           height: 1.0,
//                           color: Colors.black,
//                         ),
//                         Expanded(
//                           child: ResponsiveGridList(
//                             horizontalGridMargin: 50,
//                             verticalGridMargin: 50,
//                             horizontalGridSpacing: 20,
//                             minItemWidth: 160,
//                             children: List.generate(
//                               plansElevation!.length,
//                               (index) => plansElevation![index]
//                                       .imageName!
//                                       .contains('.pdf')
//                                   ? InkWell(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) {
//                                               return PdfViewer(
//                                                 fileName: plansElevation![index]
//                                                     .imageName,
//                                                 fileUrl:
//                                                     '${AppUrl.globalPlanElevation}${plansElevation![index].imageName}',
//                                               );
//                                             },
//                                           ),
//                                         );
//                                       },
//                                       child: Column(
//                                         children: [
//                                           Container(
//                                             padding: EdgeInsets.only(right: 10),
//                                             child: Image.asset(
//                                               'images/projectmanagement/pdf.png',
//                                               width: 160,
//                                               height: 160,
//                                             ),
//                                           ),
//                                           SizedBox(height: 10),
//                                           Text(plansElevation![index].name ??
//                                               ''),
//                                         ],
//                                       ),
//                                     )
//                                   : plansElevation![index]
//                                           .imageName!
//                                           .contains('.mp4')
//                                       ? InkWell(
//                                           onTap: () async {
//                                             final uri = Uri.parse(
//                                                 '${AppUrl.globalPlanElevation}${plansElevation![index].imageName}');
//                                             if (await canLaunchUrl(uri)) {
//                                               await launchUrl(uri);
//                                             } else {
//                                               throw 'Could not launch';
//                                             }
//                                           },
//                                           child: Icon(
//                                             Icons.video_camera_back,
//                                             size: 80,
//                                           ),
//                                         )
//                                       : InkWell(
//                                           onTap: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (_) {
//                                                   return ImagePreviewViewer(
//                                                     fileName:
//                                                         plansElevation![index]
//                                                             .imageName!,
//                                                     fileUrl:
//                                                         '${AppUrl.globalPlanElevation}${plansElevation![index].imageName!}',
//                                                   );
//                                                 },
//                                               ),
//                                             );
//                                           },
//                                           child: Column(
//                                             children: [
//                                               SizedBox(
//                                                 height: 160,
//                                                 child: CachedNetworkImage(
//                                                   imageUrl: AppUrl
//                                                           .globalPlanElevation +
//                                                       plansElevation![index]
//                                                           .imageName!,
//                                                   imageBuilder: (context,
//                                                           imageProvider) =>
//                                                       Container(
//                                                           decoration:
//                                                               BoxDecoration(
//                                                     border: Border.all(
//                                                       width: 1.0,
//                                                       color: Colors.grey,
//                                                     ),
//                                                     borderRadius:
//                                                         const BorderRadius.all(
//                                                             Radius.circular(
//                                                                 5.0)),
//                                                     image: DecorationImage(
//                                                       image: imageProvider,
//                                                       fit: BoxFit.fitHeight,
//                                                     ),
//                                                   )),
//                                                   placeholder: _loader,
//                                                   errorWidget: _error,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 10),
//                                               Text(
//                                                   plansElevation![index].name ??
//                                                       ''),
//                                             ],
//                                           ),
//                                         ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   : const Center(
//                       child: Text('No Record Found', style: normalText))
//               : const Center(child: CircularProgressIndicator()),
//         ),
//       ),
//     );
//   }

//   Widget _loader(BuildContext context, String url) {
//     return const Center(
//       child: CircularProgressIndicator(),
//     );
//   }

//   Widget _error(BuildContext context, String url, dynamic error) {
//     return const Center(child: Icon(Icons.error));
//   }
// }

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/get_plans_elevation.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import '../../../utils/responsive.dart';
import '../mycontracts/imagepreviewview.dart';
import '../../widgets/stallion_video_player.dart';

class PlansAndElevation extends StatefulWidget {
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  const PlansAndElevation({
    Key? key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
  }) : super(key: key);

  @override
  State<PlansAndElevation> createState() => _PlansAndElevationState();
}

class _PlansAndElevationState extends State<PlansAndElevation> {
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;
  List<PlansElevation>? plansElevation;

  Future<void> fetchProjectPlansElevation() async {
    final String idToFetch = (widget.towarId != null && widget.towarId!.isNotEmpty)
        ? widget.towarId!
        : widget.projectId!;
    final url = "${AppUrl.baseURL}plans-elevation/$idToFetch";
    if (kDebugMode) {
      print("PlansAndElevation: Fetching from URL: $url");
    }
    
    final response = await apiNetworkHandler.get(url);

    if (!mounted) return;

    if (kDebugMode) {
      print("PlansAndElevation: Status code: ${response.statusCode}");
      print("PlansAndElevation: Response Body: ${response.body}");
      print("PlansAndElevation: widget.towarId is: '${widget.towarId}'");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getPlansElevationFromJson(response.body);
      if (dataModel.success == true) {
        List<PlansElevation> allDocuments = dataModel.data ?? [];

        if (kDebugMode) {
          print("PlansAndElevation: Parsed documents count: ${allDocuments.length}");
          for (var doc in allDocuments) {
            print("PlansAndElevation: Document ID: ${doc.id}, Name: ${doc.documentName}, Tower ID in doc: '${doc.towerId}'");
          }
        }

        if (kDebugMode) {
          print("PlansAndElevation: Filtered documents count: ${allDocuments.length}");
        }

        setState(() {
          flagcalled = true;
          plansElevation = allDocuments;
        });

        // Preload first few images
        for (int i = 0;
            i < (plansElevation!.length > 3 ? 3 : plansElevation!.length);
            i++) {
          final imageUrl = plansElevation![i].fileUrl;
          if (imageUrl != null &&
              !imageUrl.toLowerCase().contains(".pdf") &&
              !imageUrl.toLowerCase().contains(".mp4")) {
            precacheImage(
              CachedNetworkImageProvider(imageUrl),
              context,
            );
          }
        }
      } else {
        setState(() {
          flagcalled = true;
          plansElevation = [];
        });
      }
    } else {
      setState(() {
        flagcalled = true;
        plansElevation = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProjectPlansElevation();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final double headerHeight = isMobile ? 32.0 : 44.0;
    final double headerFontSize = isMobile ? 13.5 : 16.0;
    final double gridPadding = isMobile ? 12.0 : 30.0;
    final double crossSpacing = isMobile ? 12.0 : 20.0;
    final double mainSpacing = isMobile ? 8.0 : 14.0;
    
    int crossAxisCount;
    double childAspectRatio;

    if (isMobile) {
      final double shortestSide = MediaQuery.of(context).size.shortestSide;
      final bool isTablet = shortestSide >= 600;
      final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
      
      if (isTablet) {
        // iPad / Tablet: Portrait = 4, Landscape = 6 to maintain item size
        crossAxisCount = isLandscape ? 6 : 4;
        childAspectRatio = isLandscape ? 0.85 : 0.80;
      } else {
        // Phone: Portrait = 2, Landscape = 4 to maintain item size
        crossAxisCount = isLandscape ? 4 : 2;
        childAspectRatio = isLandscape ? 0.82 : 0.78;
      }
    } else {
      // Desktop / Web: dynamic based on width
      crossAxisCount = (MediaQuery.of(context).size.width ~/ 180).clamp(4, 12);
      childAspectRatio = 0.82;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.towarName != null && widget.towarName!.isNotEmpty
              ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
              : widget.projectName!.toUpperCase(),
          style: TextStyle(fontSize: isMobile ? 17.0 : 20.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: flagcalled
            ? plansElevation!.isNotEmpty
                ? Column(
                    children: [
                      SizedBox(
                        height: headerHeight,
                        child: Center(
                          child: Text(
                            'PLANS & ELEVATION',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: headerFontSize,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1.0, color: Colors.black),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(gridPadding),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: crossSpacing,
                              mainAxisSpacing: mainSpacing,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: plansElevation!.length,
                            itemBuilder: (context, index) {
                              final item = plansElevation![index];
                              return _buildGridItem(item);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(child: Text('No Record Found'))
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildGridItem(PlansElevation item) {
    final String fileUrl = item.fileUrl ?? '';
    final String documentName = item.documentName ?? '';
    final String urlLower = fileUrl.toLowerCase();
    final isMobile = context.isMobile;

    if (urlLower.contains('.pdf')) {
      return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PdfViewer(fileName: documentName, fileUrl: fileUrl);
          }));
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 2.0 : 4.0),
                  child: Image.asset(
                    'images/projectmanagement/pdf.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              documentName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 13.5 : 15.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (urlLower.contains('.mp4') ||
        urlLower.contains('.mov') ||
        urlLower.contains('.avi') ||
        urlLower.contains('.mkv') ||
        urlLower.contains('.3gp') ||
        urlLower.contains('.webm') ||
        urlLower.contains('.ogg') ||
        urlLower.contains('.m4v')) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StallionVideoPlayer(
                fileUrl: fileUrl,
                documentName: documentName,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  Icons.video_camera_back,
                  size: isMobile ? 52.0 : 64.0,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              documentName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 13.5 : 15.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return ImagePreviewViewer(fileName: documentName, fileUrl: fileUrl);
          }));
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 2.0 : 4.0),
                  child: CachedNetworkImage(
                    imageUrl: fileUrl,
                    placeholder: (context, url) => _shimmerLoader(),
                    errorWidget: (context, url, error) => InkWell(
                      onTap: () => setState(() {}), // retry
                      child: const Icon(Icons.refresh, color: Colors.red, size: 30.0),
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              documentName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 13.5 : 15.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _shimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }
}
