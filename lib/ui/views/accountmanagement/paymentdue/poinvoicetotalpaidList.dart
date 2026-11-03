import 'package:flutter/material.dart';
import '../../../../models/get_payment_details_by_vendor.dart';
import '../../../shared/ui_helpers.dart';

class PoInvoiceTotalPaidList extends StatefulWidget {
  const PoInvoiceTotalPaidList(
      {super.key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.paymentHistory,
      this.vendorName,
      this.totalpaidamt});

  final String? projectId;
  final String? vendorName;
  final String? towarId;
  final String? projectName;
  final List<PaymentHistory>? paymentHistory;
  final String? totalpaidamt;

  @override
  State<PoInvoiceTotalPaidList> createState() => _PoInvoiceTotalPaidListState();
}

class _PoInvoiceTotalPaidListState extends State<PoInvoiceTotalPaidList> {
  bool flagcalled = false;
  List<PaymentHistory>? paymentHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            // 'Bliss Breach Candey',
            widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
            child:
                // flagcalled == true
                //     ?
                Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // 'MAYUR ENTERPRISES',
                    widget.vendorName!.capitalize(),
                    style: boldText,
                  ),
                  verticalSpaceTiny,
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.black,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.paymentHistory!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 50, top: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text('Transacion No.',
                                            style: normalText),
                                      ),
                                      horizontalSpaceMedium,
                                      const Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      Text(widget.paymentHistory![index].poNo!,
                                          style: boldText),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child:
                                            Text('Paid On', style: normalText),
                                      ),
                                      horizontalSpaceMedium,
                                      const Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      Flexible(
                                        child: Text(
                                            widget.paymentHistory![index]
                                                .deliveryDate!,
                                            style: boldText),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text('Amount Paid',
                                            style: normalText),
                                      ),
                                      horizontalSpaceMedium,
                                      const Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      Text(
                                          currencyFormat.format(double.parse(
                                              widget.paymentHistory![index]
                                                  .amount!)),
                                          style: boldText),
                                      const Expanded(
                                          child: horizontalSpaceSmall),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text('Payment Mode',
                                            style: normalText),
                                      ),
                                      horizontalSpaceMedium,
                                      const Center(
                                          child: Icon(Icons.remove,
                                              color: Colors.black54)),
                                      horizontalSpaceLarge,
                                      Text(
                                          widget.paymentHistory![index]
                                              .paymentType!,
                                          style: boldText),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        verticalSpaceSmall15,
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        )
            //: const Center(child: CircularProgressIndicator())
            ),
      ),
      bottomNavigationBar: SizedBox(
        height: 45,
        child: IntrinsicHeight(
          child: Column(
            children: [
              const Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.black,
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Total Paid  :  ',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                        Text(
                            currencyFormat
                                .format(double.parse(widget.totalpaidamt!)),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green))
                      ]))
            ],
          ),
        ),
      ),
    );
  }
}
