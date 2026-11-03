import 'package:flutter/material.dart';
import 'package:stallion/models/res_tenant_dashboard.dart';

class AdditionalAreaCol extends StatefulWidget {
  const AdditionalAreaCol({super.key, this.tenantAddintionaArea});
  final List<TenantAddintionaArea>? tenantAddintionaArea;

  @override
  State<AdditionalAreaCol> createState() => _AdditionalAreaColState();
}

class _AdditionalAreaColState extends State<AdditionalAreaCol> {
  @override
  Widget build(BuildContext context) {
    double widthParent = (MediaQuery.of(context).size.width / 3) - 50;

    return Container(
      width: widthParent,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Column(
        children: [
          // const SizedBox(height: 10),
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
                "Additional Area (Total)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
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
                for (int i = 0; i < widget.tenantAddintionaArea!.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(
                          color: widget.tenantAddintionaArea!.length - 1 == i
                              ? Colors.transparent
                              : Colors.white54),
                    )),
                    child: Row(
                      children: [
                        Text(
                          widget.tenantAddintionaArea?[i].name ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.tenantAddintionaArea?[i].total ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
