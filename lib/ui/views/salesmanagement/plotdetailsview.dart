import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/views/salesmanagement/membershipform.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../../../models/get_plot_images_details.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';
import 'bookasaleview.dart';

class PlotDetailsView extends StatefulWidget {
   PlotDetailsView({
    super.key,
    this.projectId = "",
    this.towarId = "",
    this.projectName = "",
    this.towarName = "",
    this.member_ship_form = "0",
    required this.flatSelected,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? member_ship_form;
  List<Map<String, String>> flatSelected;

  @override
  State<PlotDetailsView> createState() => _PlotDetailsViewState();
}

class _PlotDetailsViewState extends State<PlotDetailsView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();

  bool flagcalled = false;
  List<PlotDetail>? plotDetails;

  Future<ResponsePlotdrawingimages?> getPlotingDetails() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? flat = "";
    for(int i = 0; i < widget.flatSelected.length; i++){
      if (i == 0){
        flat = widget.flatSelected[i]["flat_id"];
      }else {
        flat = '$flat,${widget.flatSelected[i]["flat_id"]}';
      }
    }
    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
      "flat_id": flat!,
    };

    var response = await apiNetworkHandler.post(AppUrl.wsgetPlotImages, data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = plotdrawingimagesFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        plotDetails = dataModel.response?.plotDetails!;
        setState(() {
          flagcalled = true;
        });
      }
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    getPlotingDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return flagcalled == true ? Scaffold(
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
      body: ListView.builder(
        itemCount: plotDetails!.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                      plotDetails![index].name!,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
                Divider(),
                HorizontalListView(images: plotDetails![index].images, plotDetails: plotDetails![index], projectName: widget.projectName!),
                Container(
                  child: Text(
                      plotDetails![index].description!
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: InkWell(
        onTap: (){
          print('clicked');
          List<String> flatId = [];
          double totalflatAreaCount = 0;
          for(int i = 0; i < widget.flatSelected.length; i++){
            flatId.add(widget.flatSelected[i]["flat_id"].toString());
            totalflatAreaCount = totalflatAreaCount + double.parse(widget.flatSelected[i]["flat_area"].toString());
          }
          if(widget.member_ship_form == "1") {
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
          }else{
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
        },
        child: Container(
          color: Colors.black,
          height: 45,
          child: const Center(child: Text('PROCEED FOR BOOKING', style: TextStyle(color: Colors.white, fontSize: 17),)),
        ),
      ),
    ): const Center(child: CircularProgressIndicator());
  }
}


class HorizontalListView extends StatelessWidget {
  final List<Images>? images;
  final PlotDetail? plotDetails;
  String projectName;
   HorizontalListView({super.key, required this.images, this.plotDetails, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
      child: Container(
        height: 250,// Set the desired height for the horizontal ListView
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images!.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: (){
                // Handle image tap event here
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return FullScreenImageDisplay(images: images, initialIndex: index, projectName: projectName);
                  },
                ));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      AppUrl.globalPlotImagesUrl+images![index].name!,
                      width: 150, // Set the desired width for each image
                      height: 200, // Set the desired height for each image
                      fit: BoxFit.cover, // Adjust the fit as needed
                    ),
                    const SizedBox(height: 5,),
                    Center(
                      child: Text(
                          images![index].title!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class FullScreenImageDisplay extends StatelessWidget {
  final List<Images>? images;
  final int initialIndex;
  final String projectName;

  FullScreenImageDisplay({required this.images, required this.initialIndex, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(projectName),
      ),
      body: PageView.builder(
        itemCount: images!.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Expanded(
                child: Zoom(
                  backgroundColor: Colors.white,
                  initTotalZoomOut: true,
                  child: Center(
                    child: Image.network(
                      AppUrl.globalPlotImagesUrl+images![index].name!,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              Center(
                child: Text(
                    images![index].title!,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 15,),
            ],
          );
        },
      ),
    );
  }
}




