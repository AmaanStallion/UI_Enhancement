import 'package:flutter/material.dart';

class QuantificationScreen extends StatefulWidget {
  const QuantificationScreen({super.key});

  @override
  State<QuantificationScreen> createState() => _QuantificationScreenState();
}

class _QuantificationScreenState extends State<QuantificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                Container(
                  height: 44,
                  width: MediaQuery.of(context).size.width * 0.2,
                  color: Colors.grey,
                  child: const Center(
                    child: Text(
                      'Finishing Exterior Name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Text('certify Qty'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: const Center(
                    child: Text(
                      'Door',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Text('certify Qty'),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            // color: Colors.grey,
                            child: const Text(
                              '2 BHK (740.33 Sqft) (Qty Per Flat)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Text('certify Qty'),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            // color: Colors.grey,
                            child: const Text(
                              '2 BHK (740.33 Sqft) (Qty Per Flat)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Text('certify Qty'),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            // color: Colors.grey,
                            child: const Text(
                              '2 BHK (740.33 Sqft) (Qty Per Flat)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Text('certify Qty'),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            // color: Colors.grey,
                            child: const Text(
                              '2 BHK (740.33 Sqft) (Qty Per Flat)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Text('certify Qty'),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            // color: Colors.grey,
                            child: const Text(
                              '2 BHK (740.33 Sqft) (Qty Per Flat)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Text('certify Qty'),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            // color: Colors.grey,
                            child: const Text(
                              '2 BHK (740.33 Sqft) (Qty Per Flat)',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                // fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Text('certify Qty'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          height: 34,
                          width: MediaQuery.of(context).size.width * 0.12,
                          // color: Colors.grey,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            // scrollPadding: const EdgeInsets.all(0.0),
                            // controller: remarkControler,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 13),
                              // border: OutlineInputBorder(
                              //   borderSide: BorderSide(color: Colors.transparent),
                              // ),
                              hintText: 'Please Enter Remark',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              // suffixIcon: Icon(
                              //   Icons.calendar_month_outlined,
                              // ),
                            ),
                          ),
                          // Text('certify Qty'),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          height: 34,
                          width: MediaQuery.of(context).size.width * 0.12,
                          // color: Colors.grey,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            // scrollPadding: const EdgeInsets.all(0.0),
                            // controller: remarkControler,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 13),
                              // border: OutlineInputBorder(
                              //   borderSide: BorderSide(color: Colors.transparent),
                              // ),
                              hintText: 'Please Enter Remark',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              // suffixIcon: Icon(
                              //   Icons.calendar_month_outlined,
                              // ),
                            ),
                          ),
                          // Text('certify Qty'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
