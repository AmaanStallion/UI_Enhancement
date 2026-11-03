import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/utils/responsive.dart';

import '../login/login_screen.dart';

class TutorialScreen extends StatefulWidget {
  TutorialScreen({Key? key});

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  static final myDictionary = [
    {
      "id": 1,
      "image": "images/tutorials/construction_1.png",
      "header": "CONSTRUCTION PROGRESS",
      "subheader1": "Central Database for Drawings",
      "subheader2": "Quality Checks",
      "subheader3": "Raw Material Consumption"
    },
    {
      "id": 2,
      "image": "images/tutorials/construction_2.png",
      "header": "GOVERNMENT COMPLIANCE'S",
      "subheader1": "Compliance Tracking",
      "subheader2": "Pre-Defined Necessary Compliances",
      "subheader3": "Premium Calculations"
    },
    {
      "id": 3,
      "image": "images/tutorials/construction_3.png",
      "header": "GOVERNMENT COMPLIANCE'S",
      "subheader1": "Issue Digital Purchase Orders",
      "subheader2": "Auto Account Reconciliation",
      "subheader3": "Vendor Application"
    },
    {
      "id": 4,
      "image": "images/tutorials/construction_4.png",
      "header": "SALES MANAGEMENT",
      "subheader1": "Sale Booking Form",
      "subheader2": "Digital Payment Structure",
      "subheader3": "Digital Agreement & Allotment."
    },
    {
      "id": 5,
      "image": "images/tutorials/construction_5.png",
      "header": "CONTRACTOR MANAGEMENT",
      "subheader1": "Issue Digital Work Orders",
      "subheader2": "Project Estimation",
      "subheader3": "Account Reconciliation."
    },
    {
      "id": 6,
      "image": "images/tutorials/construction_6.png",
      "header": "ACCOUNTING MANAGEMENT",
      "subheader1": "Payment Reconciliations",
      "subheader2": "Real-Time Cost of Project",
      "subheader3": "Bank Integration"
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobileDevice = context.isMobile;

          if (isMobileDevice) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: LoginScreen(),
              ),
            );
          }

          // Desktop/Web (>1024px): Split-screen layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: LoginScreen(),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 13,
                child: Container(
                  color: const Color(0xff121212),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GFCarousel(
                            autoPlay: true,
                            hasPagination: true,
                            activeIndicator: Colors.white,
                            passiveIndicator: Colors.white30,
                            height: 600,
                            items: myDictionary.map(
                              (dict) {
                                return Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          50, 0, 50, 0),
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.all(
                                                Radius.circular(5.0)),
                                        child: Image(
                                          image: AssetImage(
                                              dict['image'].toString()),
                                          height: 400,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      dict['header'].toString(),
                                      style: boldText.copyWith(color: Colors.white),
                                    ),
                                    verticalSpaceSmall,
                                    Text(
                                      dict['subheader1'].toString(),
                                      style: normalText.copyWith(color: Colors.white),
                                    ),
                                    verticalSpaceVeryTiny,
                                    Text(
                                      dict['subheader2'].toString(),
                                      style: normalText.copyWith(color: Colors.white),
                                    ),
                                    verticalSpaceVeryTiny,
                                    Text(
                                      dict['subheader3'].toString(),
                                      style: normalText.copyWith(color: Colors.white),
                                    ),
                                  ],
                                );
                              },
                            ).toList(),
                            onPageChanged: (index) {
                              setState(() {
                                index;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
