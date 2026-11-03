import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/getLabReportOk.dart';
import 'package:stallion/models/get_masonry_status.dart';
import 'package:stallion/models/get_project_masonry.dart';
import 'package:stallion/models/get_rccstructure.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesLeadDetailPage.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// class MasonryStatusScreen extends StatefulWidget {
//   const MasonryStatusScreen({
//     super.key,
//     this.projectId,
//     this.towarId,
//     this.projectName,
//     this.title,
//     this.plist,
//     this.headId,
//     this.isSlabExist = false,
//     this.masonryId,
//   });
//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? title;
//   final InnerBlock? plist;
//   final String? headId;
//   final String? masonryId;
//   final bool? isSlabExist;

//   @override
//   State<MasonryStatusScreen> createState() => _SlabStatusScreenState();
// }

class MasonryStatusScreen extends StatefulWidget {
  const MasonryStatusScreen({super.key});

  @override
  State<MasonryStatusScreen> createState() => _SlabStatusScreenState();
}

class _SlabStatusScreenState extends State<MasonryStatusScreen> {
  late NotificationArgs args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  GetMasonryStatusResponse? getLabReportOkResponse;
  List<MasonryReport>? masonryReportRes = [];
  List<String>? reportVedioRes = [];

  List<String>? imageRes = [];

  int? isSelectedComment;
  List<String> commentsList = [
    "Ok Work",
    "Ideal Work",
    "Perfect Work",
    "Add Comments"
  ];
  TextEditingController textControler = TextEditingController();
  var arrayFiles = [];
  var arrayFilesBytes = [];

  Future<GetLabReportOkResponse?> getLabReport() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    // String towerId = "";
    // if (widget.towarId != null) {
    //   towerId = widget.towarId!;
    // }

    Map<String, String> data = {
      "user_id": userId ?? '',
      "head_id": args.response?.headId ?? '',
      "masonry_id": args.response?.masonryId ?? '',
      "check_id": args.response?.masonryCheckId ?? '',
    };

    var response =
        await apiNetworkHandler.post(AppUrl.getmasonryreportok, data);
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getMasonryStatusFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          getLabReportOkResponse = dataModel.response;
          reportVedioRes = dataModel.response?.masonryReport![0].reportVedio;

          imageRes = dataModel.response?.masonryReport![0].image;

          masonryReportRes = dataModel.response?.masonryReport;
          print(
              "==================${dataModel.response?.masonryReport == null} =-=- ${dataModel.response?.masonryReport?.length}");
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
  }

  setSlabReport() async {
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.wsSetMasonryReportOk));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    request.fields['user_id'] = userId!;
    request.fields['masonry_id'] = args.response?.masonryId ?? '';
    request.fields['check_id'] = args.response?.masonryCheckId ?? '';
    request.fields['head_id'] = args.response?.headId ?? '';
    request.fields['message'] = isSelectedComment == 3
        ? textControler.text
        : commentsList[isSelectedComment!];
    // commentsList[isSelectedComment!];
    request.fields['reason'] = '';

    for (int i = 0; i < arrayFiles.length; i++) {
      if (arrayFiles[i] != null && arrayFiles[i].extension != "mp4") {
        PlatformFile file = arrayFiles[i]!;
        request.files.add(
          await http.MultipartFile.fromPath(
            "slabimage[]",
            file.path.toString(),
          ),
        );
      } else if (arrayFiles[i] != null && arrayFiles[i].extension == "mp4") {
        PlatformFile file = arrayFiles[i]!;
        request.files.add(
          await http.MultipartFile.fromPath(
            "slab_vedio[]",
            file.path.toString(),
          ),
        );
      }
    }

    var response = await request.send();

    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // return null;
      if (kDebugMode) {}
      if (kDebugMode) {
        print(responseData);
      }
    } else {
      print("ERROR");
    }
  }

  @override
  void initState() {
    super.initState();
    // if (widget.isSlabExist!) {
    getLabReport();
    // }
  }

  @override
  Widget build(BuildContext context1) {
    return Scaffold(
      // bottomNavigationBar: !widget.isSlabExist!
      bottomNavigationBar: masonryReportRes?.length == 0
          ? InkWell(
              onTap: () {
                if (arrayFiles.length == 0 ||
                    isSelectedComment == null ||
                    (isSelectedComment == 3 && textControler.text == "")) {
                  showDialog<void>(
                      barrierDismissible: true,
                      context: context1,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(
                              bottom: 10, left: 10, right: 10),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: const Text(
                            "Please choose or add comments on slab.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            InkWell(
                              onTap: () {
                                // Navigator.of(context).pop();

                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 250,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Text(
                                  "Okay",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                } else {
                  showDialog<void>(
                      barrierDismissible: true,
                      context: context1,
                      builder: (context2) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(
                              bottom: 10, left: 10, right: 10),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: const Text(
                            "Are you sure you want to submit this report?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            InkWell(
                              onTap: () {
                                // Navigator.of(context).pop();

                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 250,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Text(
                                  "No",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.of(context2).pop();
                                Future.delayed(Duration(milliseconds: 80), () {
                                  CustomLoading.progressDialog(
                                      isLoading: true, context: context1);
                                });
                                setSlabReport().then((_) {
                                  // if (kDebugMode) {
                                  print("SUCCESS");
                                  getLabReport().then((value) => {
                                        CustomLoading.progressDialog(
                                            isLoading: false,
                                            context: context1),
                                        Navigator.of(context1).pop(),
                                        showDialog<void>(
                                            barrierDismissible: true,
                                            context: context1,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // Set radius to zero
                                                ),
                                                titlePadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 20),
                                                actionsPadding:
                                                    const EdgeInsets.only(
                                                        bottom: 10,
                                                        left: 10,
                                                        right: 10),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                actionsAlignment:
                                                    MainAxisAlignment.center,
                                                title: const Text(
                                                  "You have successfully submitted slab report.",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                actions: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();

                                                      Navigator.of(context1)
                                                          .pop();
                                                      // Navigator.of(context).pop();
                                                    },
                                                    child: Container(
                                                      width: 250,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7)),
                                                      child: const Text(
                                                        "Okay",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                        setState(() {
                                          arrayFiles = [];
                                          arrayFilesBytes = [];
                                        }),
                                      });

                                  // });
                                  // }
                                  if (kDebugMode) {
                                    // print(responseData);
                                  }
                                });
                              },
                              child: Container(
                                width: 250,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                }
              },
              child: Container(
                  padding: const EdgeInsets.only(top: 7),
                  height: 40,
                  color: Colors.black,
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  )),
            )
          : const SizedBox.shrink(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${args.projectName?.toUpperCase()}',
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: masonryReportRes?.isEmpty ?? true
            // widget.isSlabExist == false
            ? [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: AppText(
                      title: args.response?.masonryNo ?? '',
                      fontSize: 18,
                      titleTextAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Center(
                    child: AppText(
                      title: "MASONRY STATUS",
                      fontSize: 18,
                      titleTextAlign: TextAlign.center,
                      titleColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: AppText(
                    title: args.response?.masonryNo ?? '',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: const AppText(
                    title: "Completed On : -",
                    fontSize: 16,
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: const AppText(
                    title: 'Masonry Images',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          if (arrayFiles.length != 4) {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'jpg',
                                'jpeg',
                                'png',
                                'mp4',
                              ],
                            );
                            if (result != null) {
                              PlatformFile file = result.files.first;
                              print("FILE SELECTED");
                              print(file.name);
                              print(file.bytes);
                              print(file.size);
                              print(file.extension);
                              print(file.path);
                              Uint8List? fileBytes = result.files.first.bytes;
                              String fileName = result.files.first.name;
                              setState(() {
                                arrayFilesBytes.add(fileBytes);
                                arrayFiles.add(file);
                              });
                            } else {
                              // User canceled the picker
                            }
                          }
                        },
                        child: Image.asset(
                          'images/projectmanagement/img5.png',
                          height: 140,
                          width: 140,
                        ),
                      ),
                      for (int j = 0; j < arrayFiles.length; j++)
                        arrayFiles[j].extension != 'mp4'
                            ? Image.file(
                                File(arrayFiles[j].path),
                                height: 140,
                                width: 140,
                              )
                            : const SizedBox(
                                height: 140,
                                width: 140,
                                child: Icon(
                                  Icons.video_camera_back,
                                  size: 40,
                                ),
                              ),
                    ],
                  ),
                ),
                // Image.asset(arrayFiles[0].path),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppText(
                        title: '${arrayFiles.length.toString()}/4',
                        fontSize: 12),
                    Container(width: 100),
                  ],
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: const AppText(
                    title: 'Masonry Review/Comments',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Row(
                    children: [
                      for (int i = 0; i < commentsList.length; i++)
                        InkWell(
                          onTap: () {
                            setState(() {
                              isSelectedComment = i;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelectedComment == i
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            child: AppText(
                              title: commentsList[i],
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelectedComment == 3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 20),
                    child: TextFormField(
                      maxLines: 6,
                      controller: textControler,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13.0),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        hintText: 'Please Enter Text',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 116, 116, 116),
                          fontSize: 13.0,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'HelveticaNeue',
                        ),
                      ),
                    ),
                  ),
              ]
            : [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: AppText(
                      title: args.response?.masonryNo ?? '',
                      fontSize: 18,
                      titleTextAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Center(
                    child: AppText(
                      title: "MASONRY STATUS",
                      fontSize: 18,
                      titleTextAlign: TextAlign.center,
                      titleColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: const AppText(
                    title: 'Estimated Date',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: AppText(
                    title: getLabReportOkResponse
                            ?.masonryReport?[0].estCompletDate ??
                        '',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: const AppText(
                    title: 'Completion Date',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: AppText(
                    title:
                        getLabReportOkResponse?.masonryReport?[0].submitDate ??
                            '',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: const AppText(
                    title: 'Masonry Images',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // getLabReportOkResponse?.slabReport?[0].image?.length != 0
                //     ?

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Row(
                    children: [
                      // for (int k = 0;
                      //     k <
                      //         getLabReportOkResponse
                      //             .masonryReport![0].image!.length;
                      //     k++)
                      for (int k = 0; k < imageRes!.length; k++)
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return ImagePreviewViewer(
                                    fileName: imageRes?[k],
                                    fileUrl:
                                        '${AppUrl.globalMasnoryReportPath}${imageRes?[k].toString()}',
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(8)),
                            margin: const EdgeInsets.only(right: 20),
                            padding: const EdgeInsets.all(8),
                            child: Image.network(
                              '${AppUrl.globalMasnoryReportPath}${imageRes![k].toString()}',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      // for (dynamic k = 0;
                      //     k <
                      //         getLabReportOkResponse
                      //             ?.masonryReport?[0].reportVedio?.length;
                      //     k++)
                      for (int k = 0; k < reportVedioRes!.length; k++)
                        InkWell(
                          // onTap: () {
                          //   // Navigator.push(
                          //   //   context,
                          //   //   MaterialPageRoute(
                          //   //     builder: (_) {
                          //   //       return ImagePreviewViewer(
                          //   //         fileName: getLabReportOkResponse
                          //   //             ?.slabReport?[0].image?[k],
                          //   //         fileUrl:
                          //   //             '${AppUrl.globalSlabReportPath}${getLabReportOkResponse?.slabReport?[0].image?[k].toString()}',
                          //   //       );
                          //   //     },
                          //   //   ),
                          //   // );

                          // },\
                          onTap: () async {
                            if (reportVedioRes![k]?.length != 0) {
                              final uri = Uri.parse(
                                  '${AppUrl.globalMasnoryReportPath}${reportVedioRes![k].toString()}');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                throw 'Could not launch';
                              }
                            }

                            // VideoItem(
                            //   file: '${plist.imagePath}/${plist.slabVedio?[0]}',
                            //   index: 0,
                            //   navigationFlag: 'fullscreen',
                            //   callbackVideo: () {},
                            //   urll: '${plist.imagePath}/${plist.slabVedio?[0]}',
                            // );
                          },
                          child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              margin: const EdgeInsets.only(right: 20),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.video_camera_back,
                              )
                              // Image.network(
                              //   '${AppUrl.globalSlabReportPath}${getLabReportOkResponse?.slabReport?[0].reportVedio![k].toString()}',
                              //   width: 100,
                              //   height: 100,
                              //   fit: BoxFit.cover,
                              // ),
                              ),
                        ),
                    ],
                  ),
                ),
                if (getLabReportOkResponse?.masonryReport?[0].image?.length ==
                    0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: const AppText(
                      title: "No Image Uploaded",
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: const AppText(
                    title: 'Masonry Review/Comments',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: AppText(
                    title: getLabReportOkResponse
                            ?.masonryReport?[0].masonryReportReview ??
                        '',
                    fontSize: 16,
                  ),
                ),
              ],
      ),
    );
  }
}
