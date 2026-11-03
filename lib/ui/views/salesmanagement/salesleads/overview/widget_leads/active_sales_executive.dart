import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/resSalesLeadDashbord.dart';

class ActiveSalesExecutive extends StatefulWidget {
  const ActiveSalesExecutive(
      {super.key, this.activeChennelPart, this.activeSalesExe});
  final List<Active>? activeSalesExe;
  final List<Active>? activeChennelPart;

  @override
  State<ActiveSalesExecutive> createState() => _ActiveSalesExecutiveState();
}

class _ActiveSalesExecutiveState extends State<ActiveSalesExecutive> {
  @override
  Widget build(BuildContext context) {
    double widthParent = MediaQuery.of(context).size.width * 0.3;

    return Column(
      children: [
        Container(
          height: 291,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          width: widthParent,
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 0, // Spread radius
                blurRadius: 4, // Blur radius
                offset: const Offset(4, 4), // Changes position of shadow
              ),
            ],
            border: Border.all(color: Colors.white60),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.2, 0.9],
                            colors: [
                              Color.fromARGB(255, 32, 147, 241),
                              Colors.red,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Active Sales Executive",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white38),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          width: widthParent * 0.28,
                          height: 28,
                          child: const Text(
                            "Name",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          width: widthParent * 0.12,
                          child: const Text(
                            "Leads",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          width: widthParent * 0.17,
                          child: const Text(
                            "Follow-Up",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          width: widthParent * 0.14,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          child: const Text(
                            "Missed",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          width: widthParent * 0.17,
                          child: const Text(
                            "Success",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (int i = 0;
                      i < min(widget.activeSalesExe!.length, 5);
                      i++)
                    // Container(
                    //   padding: EdgeInsets.only(top: 10, bottom: 10),
                    //   child:
                    Row(
                      children: [
                        Container(
                          width: widthParent * 0.28,
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          child: Text(
                            widget.activeSalesExe?[i].name ?? '',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Container(
                          width: widthParent * 0.12,
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          child: Text(
                            widget.activeSalesExe?[i].totLead ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: widthParent * 0.17,
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          child: Text(
                            widget.activeSalesExe?[i].followUp ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: widthParent * 0.14,
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          child: Text(
                            widget.activeSalesExe?[i].missLead ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: widthParent * 0.17,
                          child: Text(
                            widget.activeSalesExe?[i].success ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  // )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 250,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          width: widthParent,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60),
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 0, // Spread radius
                blurRadius: 4, // Blur radius
                offset: const Offset(4, 4), // Changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.2, 0.9],
                            colors: [
                              Color.fromARGB(255, 32, 147, 241),
                              Colors.red,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Active Channel Partners",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white38),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          width: widthParent * 0.28,
                          height: 28,
                          child: const Text(
                            "Name",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          width: widthParent * 0.2,
                          child: const Text(
                            "Leads",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white38),
                            ),
                          ),
                          width: widthParent * 0.2,
                          child: const Text(
                            "Follow-Up",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          width: widthParent * 0.2,
                          child: const Text(
                            "Success",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 32, 147, 241),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (int i = 0;
                      i < min(widget.activeChennelPart!.length, 4);
                      i++)
                    Container(
                      // padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: widthParent * 0.28,
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.white38),
                              ),
                            ),
                            child: Text(
                              widget.activeChennelPart?[i].name ?? '',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Container(
                            width: widthParent * 0.2,
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.white38),
                              ),
                            ),
                            child: Text(
                              widget.activeChennelPart?[i].totLead ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            width: widthParent * 0.2,
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.white38),
                              ),
                            ),
                            child: Text(
                              widget.activeChennelPart?[i].followUp ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            width: widthParent * 0.2,
                            child: Text(
                              widget.activeChennelPart?[i].success ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
