import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/resSalesLeadDashbord.dart';

class PotentialCleint extends StatefulWidget {
  const PotentialCleint({super.key, this.potential});

  final List<Potential>? potential;

  @override
  State<PotentialCleint> createState() => _PotentialCleintState();
}

class _PotentialCleintState extends State<PotentialCleint> {
  @override
  Widget build(BuildContext context) {
    double widthParent = MediaQuery.of(context).size.width * 0.3;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      width: widthParent,
      height: 555,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white60),
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 0, // Spread radius
            blurRadius: 4, // Blur radius
            offset: Offset(4, 4), // Changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          // SizedBox(height: 10),
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
              SizedBox(width: 10),
              Text(
                "Potential Clients",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          for (int i = 0; i < min(widget.potential!.length, 10); i++)
            Container(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: widthParent * 0.1,
                    child: Text(
                      '${i + 1}.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: widthParent * 0.36,
                    child: Text(
                      widget.potential?[i].leadBuyerName ?? '',
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: widthParent * 0.2,
                    child: Text(
                      widget.potential?[i].leadRequirement ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: widthParent * 0.2,
                    child: Text(
                      widget.potential?[i].leadBudgetValue ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 26,
          )
        ],
      ),
    );
  }
}
