import 'package:flutter/material.dart';

class IssueReported extends StatefulWidget {
  const IssueReported({Key? key}) : super(key: key);

  @override
  State<IssueReported> createState() => _IssueReportedState();
}

class _IssueReportedState extends State<IssueReported> {
  bool check = true;
  int select = 0;
  int choose = 0;
  int issue = 3;
  int count = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIVA AGRIPADA'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                '1st Basement',
              )),
          const Divider(height: 0, color: Colors.black, thickness: 1),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 13),
                  height: 45,
                  color: Colors.black,
                  child: const Text(
                    'ISSUES REPORTED',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            height: 0,
            color: Colors.black,
            thickness: 1,
          ),
          issueReported(),
        ],
      )),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.only(top: 7),
          height: 40,
          color: Colors.black,
          child: const Text(
            'SUBMIT',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          )),
    );
  }

  issueReported() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 40, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    count++;
                  });
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(160, 40),
                    // primary: Colors.grey.shade600,
                    elevation: 0),
                child: const Text('ADD ISSUE'),
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 230,
          child: ListView(children: [
            Column(
              children: [
                for (int i = 0; i < issue; i++) ...{
                  issue != 0
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 40, left: 40),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, left: 10),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade600),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.grey.shade300,
                                            ),
                                            width: 95,
                                            height: 85,
                                            child: const Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 35,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 10),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                              fixedSize: const Size(200, 40),
                                              // primary: Colors.red,
                                              elevation: 0),
                                          child: const Text('Issue Pending',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 10),
                                        child: OutlinedButton(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            fixedSize: const Size(200, 40),
                                            elevation: 0,
                                            side: const BorderSide(
                                                color: Colors.black),
                                          ),
                                          child: const Text('Issue Pending',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Reported By'),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          Text('Krishna (Vaibhav LLP Pvt Ltd)'),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Text('Issue In'),
                                          SizedBox(
                                            width: 58,
                                          ),
                                          Text('Working Drawing'),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Text('Reported To'),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          Text('Structural Consultant'),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text('Reported On'),
                                          SizedBox(
                                            width: 25,
                                          ),
                                          Text('7th Jul 2022'),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text('Resolved On'),
                                          SizedBox(
                                            width: 28,
                                          ),
                                          Text('--'),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Remarks'),
                                              SizedBox(
                                                width: 30,
                                              ),
                                              Text('Test Remarks'),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 498,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const Divider()
                            ],
                          ),
                        )
                      : const SizedBox(width: 0, height: 0)
                },
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                      itemCount: count,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 40, left: 40),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, left: 10),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade600),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.grey.shade300,
                                            ),
                                            width: 95,
                                            height: 85,
                                            child: const Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 35,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.only(
                                              top: 20, left: 10),
                                          child: Text('Attach Challan')),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(
                                              'Issue In',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 50),
                                            child: Text(
                                              '1st Basement Floor',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 300,
                                          ),
                                          index != 0
                                              ? IconButton(
                                                  icon: const Icon(Icons
                                                      .remove_circle_outline_rounded),
                                                  onPressed: () {
                                                    setState(() {
                                                      count = count - 1;
                                                    });
                                                  },
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 15.0),
                                            child: Text(
                                              'Reported To',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0, left: 20),
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext
                                                                context) =>
                                                            Dialog(
                                                              elevation: 0,
                                                              child: SizedBox(
                                                                height: 400,
                                                                width: 360.0,
                                                                child: Column(
                                                                  children: [
                                                                    const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              10.0,
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            'Select Reporting to',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade500,
                                                                      thickness:
                                                                          1.5,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          300,
                                                                      width:
                                                                          360,
                                                                      child: ListView.builder(itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(bottom: 0.0),
                                                                            child: Column(
                                                                              children: [
                                                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(
                                                                                      left: 10.0,
                                                                                      top: 0,
                                                                                    ),
                                                                                    child: Text('Payment Due'),
                                                                                  ),
                                                                                  Padding(
                                                                                      padding: const EdgeInsets.only(right: 10.0, top: 10, bottom: 10),
                                                                                      child: IconButton(
                                                                                        icon: Icon(
                                                                                          choose == 1 ? Icons.check_circle_outlined : Icons.circle_outlined,
                                                                                          color: choose == 1 ? Colors.green : Colors.black,
                                                                                          size: 26,
                                                                                        ),
                                                                                        onPressed: () {
                                                                                          setState(() {
                                                                                            choose = 1;
                                                                                          });
                                                                                        },
                                                                                        splashRadius: 0.5,
                                                                                      )),
                                                                                ]),
                                                                                const Divider(),
                                                                              ],
                                                                            ));
                                                                      }),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              360,
                                                                          color:
                                                                              Colors.black,
                                                                          child:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(top: 10.0),
                                                                            child:
                                                                                Text(
                                                                              'OK',
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ));
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Select Report to',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .grey.shade400),
                                                  ),
                                                  const Icon(Icons
                                                      .arrow_drop_down_sharp)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 15.0),
                                        child: Text(
                                          'Remarks',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: TextField(
                                          decoration: InputDecoration(
                                              hintText:
                                                  'Add Challan Review/Comments',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8))),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(
                                thickness: 1,
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ],
            )
          ]),
        )
      ],
    );
  }
}
