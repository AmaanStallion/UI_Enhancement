import 'package:flutter/material.dart';

import '../../shared/ui_helpers.dart';

class MyContractsSubView extends StatefulWidget {
  MyContractsSubView(
      {Key? key,
      required this.updateScreen,
      this.projectId,
      this.towarId,
      this.projectName});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final Function(String) updateScreen;

  @override
  State<MyContractsSubView> createState() => _MyContractsSubViewState();
}

class _MyContractsSubViewState extends State<MyContractsSubView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.projectName!.toUpperCase()} - MY CONTRACTS',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => widget.updateScreen('MyContractsView'),
          ),
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
              child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            widget.updateScreen('MyContractsDetailView');
                          },
                          trailing: const Padding(
                            padding: EdgeInsets.only(top: 70.0, right: 10),
                            child: Icon(Icons.keyboard_arrow_right),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(
                                left: 50, right: 10, top: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: Text('Consultant Name',
                                            style: TextStyle(
                                                backgroundColor: Colors.white,
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ),
                                      horizontalSpaceMedium,
                                      Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      Text('Gajjar and Associates',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                      const Expanded(
                                          child: horizontalSpaceLarge),
                                      Stack(children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(
                                              backgroundColor: Colors.grey,
                                              color: const Color.fromRGBO(
                                                  0, 128, 43, 1.0),
                                              strokeWidth: 4,
                                              value: 0.5),
                                        ),
                                        const Padding(
                                          padding:
                                              EdgeInsets.only(left: 7, top: 9),
                                          child: Text('50%',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.black)),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: const [
                                      SizedBox(
                                        width: 200,
                                        child: Text('Work Order Number',
                                            style: TextStyle(
                                                backgroundColor: Colors.white,
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ),
                                      horizontalSpaceMedium,
                                      Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      Text('Bli/WO/46/2002',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: const [
                                      SizedBox(
                                        width: 200,
                                        child: Text('Project Name',
                                            style: TextStyle(
                                                backgroundColor: Colors.white,
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ),
                                      horizontalSpaceMedium,
                                      Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      Text('Bliss',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: const [
                                      SizedBox(
                                        width: 200,
                                        child: Text('Consultant Type',
                                            style: TextStyle(
                                                backgroundColor: Colors.white,
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ),
                                      horizontalSpaceMedium,
                                      Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      Text('Municipal Architect',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text('Amount Due',
                                            style: TextStyle(
                                                backgroundColor: Colors.white,
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ),
                                      horizontalSpaceMedium,
                                      const Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      const Text('Rs. -1,23,450',
                                          style: TextStyle(
                                              backgroundColor: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red)),
                                      const Expanded(
                                          child: horizontalSpaceLarge),
                                      SizedBox(
                                          width: 110,
                                          height: 33,
                                          child: Container(
                                            width: double.infinity,
                                            height: 33,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(17),
                                              border: Border.all(
                                                color: Colors.black,
                                              ),
                                            ),
                                            child: const Text(
                                              'VIEW WO',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 13.0,
                                              ),
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text('Status',
                                            style: TextStyle(
                                                backgroundColor: Colors.white,
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ),
                                      horizontalSpaceMedium,
                                      const Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      const Text('Open',
                                          style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromRGBO(
                                                0, 128, 43, 1.0),
                                          )),
                                      const Expanded(
                                          child: horizontalSpaceLarge),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 1,
                      endIndent: 1,
                      color: Colors.black,
                    );
                  },
                ),
              ),
              const Divider(
                height: 1,
                thickness: 0.5,
                indent: 1,
                endIndent: 1,
                color: Colors.black,
              ),
              SizedBox(
                height: 75,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      horizontalSpaceSmall,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: const [
                              Text('Total',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                              verticalSpaceSmall,
                              Text('Rs.6,653,064')
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        indent: 10,
                        endIndent: 0,
                        color: Colors.black54,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Work Done',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                              verticalSpaceSmall,
                              Text('Rs.6,653,064')
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        indent: 10,
                        endIndent: 0,
                        color: Colors.black54,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            widget.updateScreen('ContractAmtPaidView');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('Total Paid',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black)),
                                verticalSpaceSmall,
                                Text('Rs.6,653,064'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        indent: 10,
                        endIndent: 0,
                        color: Colors.black54,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Amount Due',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                              verticalSpaceSmall,
                              Text('Rs. 0',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ));
  }
}
