import 'package:flutter/material.dart';
import 'package:stallion/models/res_tenant_dashboard.dart';

class TenanatRentCol extends StatefulWidget {
  const TenanatRentCol({super.key, this.tenantRent});
  final List<TenantRent>? tenantRent;

  @override
  State<TenanatRentCol> createState() => _TenanatRentColState();
}

class _TenanatRentColState extends State<TenanatRentCol> {
  @override
  Widget build(BuildContext context) {
    double widthParent = (MediaQuery.of(context).size.width / 3) - 50;
    Widget tileCardRent({
      required String title,
      required String total,
      required String paid,
      required String balance,
    }) {
      return Container(
        margin: const EdgeInsets.symmetric(
          vertical: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widthParent * .3,
              decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white38))),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Container(
              width: widthParent * .2,
              decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white38))),
              child: Text(
                total,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: widthParent * .2,
              decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white38))),
              child: Text(
                paid,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: widthParent * .2,
              child: Text(
                balance,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      );
    }

    return Container(
      width: widthParent,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.white60),
      //   borderRadius: BorderRadius.circular(12),
      //   color: Colors.black,
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.5), // Shadow color
      //       spreadRadius: 0, // Spread radius
      //       blurRadius: 4, // Blur radius
      //       offset: const Offset(4, 4), // Changes position of shadow
      //     ),
      //   ],
      // ),
      child: Column(
        children: [
          const SizedBox(height: 10),
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
                "Rent",
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
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 32, 32, 32),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: widthParent * .3,
                      decoration: const BoxDecoration(
                          border:
                              Border(right: BorderSide(color: Colors.white38))),
                      child: const Text(
                        "",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: widthParent * .2,
                      decoration: const BoxDecoration(
                          border:
                              Border(right: BorderSide(color: Colors.white38))),
                      child: const Text(
                        "Total",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      width: widthParent * .2,
                      decoration: const BoxDecoration(
                          border:
                              Border(right: BorderSide(color: Colors.white38))),
                      child: const Text(
                        "Paid",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: widthParent * .2,
                      child: const Text(
                        "Balance",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < widget.tenantRent!.length; i++)
                  tileCardRent(
                    title: widget.tenantRent?[i].name ?? '',
                    total: widget.tenantRent?[i].total ?? '',
                    paid: widget.tenantRent?[i].paid ?? '',
                    balance: widget.tenantRent?[i].balance ?? '',
                  ),
                // SizedBox(height: 8),
                // tileCardRent(
                //   title: "Shifting Charges",
                //   total: '₹ 3 cr',
                //   paid: '₹ 1 cr',
                //   balance: '₹ 2 cr',
                // ),
                // SizedBox(height: 8),
                // tileCardRent(
                //   title: "Corpus",
                //   total: '₹ 3 cr',
                //   paid: '₹ 1 cr',
                //   balance: '₹ 2 cr',
                // ),
                // SizedBox(height: 8),
                // tileCardRent(
                //   title: "Brokerage",
                //   total: '₹ 3 cr',
                //   paid: '₹ 1 cr',
                //   balance: '₹ 2 cr',
                // ),
                // SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
