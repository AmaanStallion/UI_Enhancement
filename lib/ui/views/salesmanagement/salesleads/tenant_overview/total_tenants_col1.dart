import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TotalTenantCol1 extends StatefulWidget {
  const TotalTenantCol1(
      {super.key, this.totalTenant, this.recidential, this.nonRecidential});
  final String? totalTenant;
  final String? recidential;
  final String? nonRecidential;

  @override
  State<TotalTenantCol1> createState() => _TotalTenantCol1State();
}

class _TotalTenantCol1State extends State<TotalTenantCol1> {
  @override
  Widget build(BuildContext context) {
    double widthParent = (MediaQuery.of(context).size.width / 3) - 50;

    return Container(
      width: widthParent,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      // decoration: BoxDecoration(
      // border: Border.all(color: Colors.white60),
      // borderRadius: BorderRadius.circular(12),
      // color: Colors.black,
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.grey.withOpacity(0.5), // Shadow color
      //     spreadRadius: 0, // Spread radius
      //     blurRadius: 4, // Blur radius
      //     offset: const Offset(4, 4), // Changes position of shadow
      //   ),
      // ],
      // ),
      child: Column(
        children: [
          // const SizedBox(height: 10),
          const Text(
            "TENANT",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          // const SizedBox(height: 20),
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
                "Total Tenants:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.totalTenant ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.green,
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 32, 32, 32),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: widthParent * .44,
                      decoration: const BoxDecoration(
                        border:
                            Border(right: BorderSide(color: Colors.white54)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Residential",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            widget.recidential ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: widthParent * .44,
                      decoration: const BoxDecoration(),
                      child: Column(
                        children: [
                          const Text(
                            "Non-Residential",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            widget.nonRecidential ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
