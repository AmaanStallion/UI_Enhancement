import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MasonryStatus extends StatefulWidget {
  const MasonryStatus({Key? key}) : super(key: key);

  @override
  State<MasonryStatus> createState() => _MasonryStatusState();
}

class _MasonryStatusState extends State<MasonryStatus> {
  bool check = true;
  int select = 0;
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
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    check = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 13),
                  height: 45,
                  color: check ? Colors.black : Colors.white,
                  child: Text(
                    'MASONRY STATUS',
                    style:
                        TextStyle(color: check ? Colors.white : Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    check = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 13),
                  height: 45,
                  color: check ? Colors.white : Colors.black,
                  child: Text(
                    'ISSUES REPORTED',
                    style:
                        TextStyle(color: check ? Colors.black : Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
            ],
          ),
          const Divider(
            height: 0,
            color: Colors.black,
            thickness: 1,
          ),
          check ? masonryStatus() : issueReported(),
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

  masonryStatus() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 60.0, top: 10, bottom: 10),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1st Basement Floor'),
                  Text('Completed on: 29 Jun 2022')
                ],
              )
            ],
          ),
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // SingleChildScrollView(
        // scrollDirection: Axis.horizontal,
        // child:
        Padding(
          padding: const EdgeInsets.only(left: 53.0),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade600),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade300,
                        ),
                        width: 80,
                        height: 70,
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
            //  )
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        Padding(
            padding: const EdgeInsets.only(left: 55.0, right: 55),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text('Slab Review/Comments'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  select = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.only(top: 12),
                                width: 200,
                                height: 47,
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(8),
                                    color: select == 1
                                        ? Colors.black
                                        : Colors.white),
                                child: Text(
                                  'OK Work',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: select == 1
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                select = 2;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(top: 12),
                              width: 200,
                              height: 47,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                  color: select == 2
                                      ? Colors.black
                                      : Colors.white),
                              child: Text(
                                'Ideal Work',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: select == 2
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                select = 3;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(top: 12),
                              width: 200,
                              height: 47,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                  color: select == 3
                                      ? Colors.black
                                      : Colors.white),
                              child: Text(
                                'Perfect Work',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: select == 3
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                select = 4;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(top: 10),
                              width: 200,
                              height: 47,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(8),
                                  color: select == 4
                                      ? Colors.black
                                      : Colors.white),
                              child: Text(
                                'Add Comments',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: select == 4
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    select == 4
                        ? SizedBox(
                            width: 400,
                            child: Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Add Comments ... ',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                maxLines: 4,
                              ),
                            ),
                          )
                        : Container()
                  ],
                )
              ],
            ))
      ],
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
                onPressed: () {},
                child: const Text('ADD ISSUE'),
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(160, 40),
                    // primary: Colors.grey.shade600,
                    elevation: 0),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 40, left: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 10),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade600),
                          borderRadius: BorderRadius.circular(12),
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
                      padding: EdgeInsets.only(top: 20, left: 10),
                      child: Text('Attach Challan')),
                ],
              ),
              const SizedBox(
                width: 150,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Issue In',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 50),
                        child: Text(
                          '1st Basement Floor',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Text(
                          'Reported To',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 20),
                        child: Text(
                          'Select Report to',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(
                      'Remarks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Add Challan Review/Comments',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(8))),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.black,
          thickness: 1,
        )
      ],
    );
  }
}
