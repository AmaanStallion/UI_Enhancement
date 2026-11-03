import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:stallion/models/resSalesLeadDashbord.dart';

class SourceCol extends StatefulWidget {
  const SourceCol({super.key, this.getLeadSource});
  final List<GetLeadSource>? getLeadSource;

  @override
  State<SourceCol> createState() => _SourceColState();
}

class _SourceColState extends State<SourceCol> {
  @override
  Widget build(BuildContext context) {
    double widthParent = MediaQuery.of(context).size.width * 0.3;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      width: widthParent,
      height: 213,
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
                "Sources (Top 5)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          for (int i = 0; i < widget.getLeadSource!.length; i++)
            Container(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 110,
                    child: Text(
                      widget.getLeadSource?[i].name ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AnimatedProgressBar(
                    height: 10,
                    // width: 100,
                    width: widthParent - 200,
                    value:
                        double.parse(widget.getLeadSource?[i].percent ?? '0') /
                            100,
                    duration: const Duration(seconds: 2),
                    color: Colors.green,
                    backgroundColor: Colors.grey,
                  ),
                  Container(
                    width: 50,
                    child: Text(
                      '${widget.getLeadSource?[i].percent}%',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
