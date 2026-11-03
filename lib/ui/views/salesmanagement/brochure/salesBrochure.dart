import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/brochure_plan.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesleadPage.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class SalesBrochure extends StatefulWidget {
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  const SalesBrochure(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName});

  @override
  State<SalesBrochure> createState() => _SalesBrochureState();
}

class _SalesBrochureState extends State<SalesBrochure> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<SellBrochurePlan>? sellBrochurePlan;

  // get all brochure list
  Future<BrochurePlanResponse?> getBrochureList() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId!,
    };
    var response =
        await apiNetworkHandler.post(AppUrl.webGetBrochureList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = brochurePlanFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          sellBrochurePlan = dataModel.response?.sellBrochurePlan;
        });
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getBrochureList();
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
            '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}',
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
          const SizedBox(height: 12),
          const Center(
            child: AppText(
              title: 'SALES BROCHURE',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          if (sellBrochurePlan != null)
            Wrap(
              spacing: 40,
              children: [
                for (int i = 0; i < sellBrochurePlan!.length; i++)
                  InkWell(
                    onTap: () async {
                      if (sellBrochurePlan![i]
                          .brochurePlanImage!
                          .contains('.pdf')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return PdfViewer(
                                fileName: sellBrochurePlan![i].planName,
                                fileUrl:
                                    '${AppUrl.globalBrochureUrl}${sellBrochurePlan![i].brochurePlanImage}',
                              );
                            },
                          ),
                        );
                      } else if (sellBrochurePlan![i]
                          .brochurePlanImage!
                          .contains('.mp4')) {
                        final uri = Uri.parse(
                            '${AppUrl.globalBrochureUrl}${sellBrochurePlan![i].brochurePlanImage!}');
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
                                fileName: sellBrochurePlan![i].planName,
                                fileUrl:
                                    '${AppUrl.globalBrochureUrl}${sellBrochurePlan![i].brochurePlanImage}',
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        sellBrochurePlan![i].brochurePlanImage!.contains('.pdf')
                            ? Image.asset(
                                'images/projectmanagement/pdf.png',
                                width: 200,
                                height: 200,
                              )
                            : sellBrochurePlan![i]
                                    .brochurePlanImage!
                                    .contains('.mp4')
                                ? Icon(
                                    Icons.video_camera_back,
                                    size: 200,
                                  )
                                : Image.network(
                                    '${AppUrl.globalBrochureUrl}${sellBrochurePlan![i].brochurePlanImage!}',
                                    width: 200,
                                    height: 200,
                                  ),
                        AppText(
                          title: sellBrochurePlan![i].planName ?? '',
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),
              ],
            ),
          if (sellBrochurePlan != null && sellBrochurePlan!.length == 0)
            Spacer(),
          if (sellBrochurePlan != null && sellBrochurePlan!.length == 0)
            Center(
              child: AppText(
                title: "No Records Found",
                fontSize: 20,
              ),
            ),
          if (sellBrochurePlan != null && sellBrochurePlan!.length == 0)
            Spacer(),
        ],
      ),
    );
  }
}
