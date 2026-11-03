import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class PreviewWorkOrder extends StatefulWidget {
  PreviewWorkOrder(
      {Key? key,
      required this.updateScreen,
      this.projectId,
      this.towarId,
      this.projectName});

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final Function(String) updateScreen;

  @override
  State<PreviewWorkOrder> createState() => _PreviewWorkOrderState();
}

class _PreviewWorkOrderState extends State<PreviewWorkOrder> {
  String url = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose(); 
  }

  static const String kLocalExamplePage = '''

<!doctype html>
<html>
<head>
<meta charset="utf-8">
</head>

<body>
	<div style="width: 100%; padding: 20px; margin: auto; border: 1px solid #000000;">
		<div style="width: 100%">
			<img src='https://stallion.build/stallion-new/media/backend/images/project-img/1650349118.png' width="100%">   

		</div>
		<div>
			<div style="font-size:11px">


<div style="font-family:arial; padding:24px 48px 24px 16px">
<div id="top" style="float:left; height:auto; margin-bottom:0px; margin-left:0px; margin-right:0px; margin-top:0px; width:100%">
<table border="0" cellspacing="0" style="border-collapse:collapse; width:100%">
	<tbody>
		<tr>
			<td><strong>P.O. No.: Alp1021/2022</strong></td>
			<td style="text-align:right"><strong>Date: 01/04/2022 21:28:03</strong></td>
		</tr>
	</tbody>
</table>
</div>

<div id="to" style="display:block; float:left; height:auto; margin-bottom:0px; margin-left:0px; margin-right:0px; margin-top:0px; padding:24px; width:100%">To,<br />
VP pvt ltd<br />
401 - 404, Bhavan towerD.N nagar, andheri - WESTmumbai-400016</div>

<div id="sub" style="float:left; height:auto; margin-bottom:0px; margin-left:0px; margin-right:0px; margin-top:0px; padding:24px 0; text-align:center; width:100%"><strong>Sub. :</strong> Purchase Order for Supply of CCTV, Cables & Wire, Ready Mix Concrete , Chemical at &ldquo;Alpha Test&rdquo;.</div>

<div id="text" style="display:block; float:left; height:auto; margin-bottom:0px; margin-left:0px; margin-right:0px; margin-top:0px; padding:24px 24px; width:100%">Dear Sir,<br />
<br />
We are pleased to raise this Purchase Order for CCTV, Cables & Wire, Ready Mix Concrete , Chemical for &ldquo;Alpha Test&rdquo; at Nariman Point the rates are mention below,</div>

<div id="main-struc" style="display:block; float:left; height:auto; margin-bottom:0px; margin-left:0px; margin-right:0px; margin-top:0px; padding:24px; width:100%"><table border="1" cellpadding="5" cellspacing="" style="width:100%; font-size: 12px;">
	<tbody>
		<tr>
			<td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;width:9%">Grade name</td>
			<td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;width:9%">Type</td>
			<td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;width:9%">Qty</td>
			<td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;width:12%">Rate</td>
                        <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;width:20%">Sub Total</td>
                        <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;width:6%">Gst%</td>
                        <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;width:17%">Gst amt</td>
                        <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;width:19%">Total amt</td>
		</tr><tr>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">dsfadssdsfadsfdsfds e are pleased to raise this Purchase Orde are pleased to raise this Purchase Ord e are pleased to raise this Purchase Ord</td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">wifi camerasdf asfsdfdsafdsafdsfadasf </td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">9890 Nos</td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">9,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">8,90,10,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">10</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">89,01,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">9,79,11,000.00</td>
		</tr><tr>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">Cables & Wire</td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">14mm</td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">5370 Sq.Ft </td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">6,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">3,22,20,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">10</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">32,22,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">3,54,42,000.00</td>
		</tr><tr>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">Ready Mix Concrete </td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">M15 </td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">120 CUM</td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">7,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">8,40,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">10</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">84,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">9,24,000.00</td>
		</tr><tr>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">Chemical</td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">Crackmite </td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">250 Bags </td>
			<td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">6,500.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">16,25,000.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">10</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">1,62,500.00</td>
                        <td style="text-align:center;background-color:#f8f9fa;padding:8px 0px;">17,87,500.00</td>
		</tr><tr>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="2">Total:</td>
<td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;">15630       </td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;"></td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="" >  12,36,95,000.00</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="" >  </td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="" >  1,23,69,500.00</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="" >  13,60,64,000.00</td>
 </tr><tr>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="4">Transportation Charges:</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="" >  15,000.00</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="" >  10</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="" >  1,500.00</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="" >  16,500.00</td>
 </tr> <tr>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" colspan="4">Mathadi/Loader Charges:  </td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" >1000</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;" >10</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;">100</td>
 <td style="text-align:center;background-color:#e1e1e1;font-weight:bold;padding:8px 0px;">1,100.00</td>
 </tr>
</tbody>
</table></div>

<div id="details" style="display:block; float:left; height:auto; margin-bottom:0px; margin-left:0px; margin-right:0px; margin-top:0px; padding:0px 24px 0px 24px; width:100%">
<div style="float:left; padding:16px 8px; width:100%"><strong>Delivery Date:</strong> 21/04/2022</div>

<div style="float:left; padding:16px 8px; width:100%"><strong>Credit Period -</strong> 7 days from delivery</div>

<div style="float:left; padding:16px 8px; width:100%"><strong>Required For-</strong> Security</div>

<div style="float:left; padding:16px 8px; width:100%"><strong>Other Remarks - </strong> No remarks</div>
<div style="float:left; padding:16px 8px; width:100%"><strong>Contact Person at Site - </strong> vaibhav</div>
<div style="float:left; padding:16px 8px; width:100%"><strong>Contact Person at Office - </strong> Krishna</div>
<div style="float:left; padding:16px 8px; width:100%"><strong>Company Billing Name &amp; Address - </strong> Arcadia Building, NCPA Road, Mumbai</div>
<div style="float:left; padding:16px 8px; width:100%"><strong>Project Address - </strong>Alpha Ltd, Arcadia, Arcadia Building, NCPA Marg, Nariman Point, Mumbai, Maharashtra 400021, India, Nariman Point</div>
<div style="float:left; padding:16px 8px; width:100%"><strong>GST Number - </strong>GST122343</div>
<div style="float:left; padding:16px 8px; width:100%"><strong>PAN Number - </strong>PANSDFSDF</div>
<div style="float:left; padding:16px 8px; width:100%"><strong>RERA Number - </strong>RESDAFSDA12342</div>
</div>



<div id="tnc" style="display:block; float:left; height:auto; margin-bottom:0px; margin-left:0px; margin-right:0px; margin-top:0px; padding:24px; width:100%">
<div style="float:left; padding:16px 16px 16px 0px; width:80%">Thanking You.<br />
<br />
 For Alpha Ltd<br />
<img src="./media/backend/userfiles/signature/e20_1_1645181079_7.jpeg"  style="widht:100px;" ><br />
2022-04-01 21:28:03<br />
Director</div>

<div id="po_structure_terms">
<div style="float:left; font-size:11px; padding:16px 16px 16px 0; width:100%"><p><strong>Purchase Order Terms and Conditions:</strong><br />
1. Total value and dimension of the goods/products must be same as mentioned in the Purchase order which will be considered as the final invoice value.<br />
2. The Final invoice issued by your company should have a copy of this Purchase order and should mention the Purchase order Reference number in your invoice.<br />
3. Delivery of the order to be done as per the date and place of requirement or else the purchase order will stand cancelled.<br />
4. Purchase order is based on the unit price confirmed by your company, any escalations would not be permitted.<br />
5. No extra charge of any kind, including charges for boxing, packing, cartage, transportation or loading and unloading will be allowed unless specifically authorized on the face of this order, or agreed to in writing by Buyer.<br />
6. Seller shall not make any changes in materials, components, or delivery of the goods covered by this order without the prior written consent of Buyer.<br />
7. If any of the goods are found to be defective in material or otherwise not in conformity with the requirements of this Purchase Order, then the buyer may correct or have corrected the non-conformity at Sellers expense or reject and return the goods at Sellers expense, at Buyer’s sole discretion.<br />
8. The goods shall be of satisfactory quality and free from defects in provision, design, materials and workmanship.<br />
9. The Products shall meet the description of any agreed sample.<br />
10. Inspection receipt/voucher/certificate to be submitted to accounts after every work order completion to verify work done.<br />
11. Payment will be released after 7 working days or as per credit limit mentioned in the contract from the time of successful purchase order completion.<br />
12. If on inspection of the goods/products the Buyer determines that the goods/product do not meet the quality and description of the product/good agreed to purchase then Buyer will inform the Supplier in writing. The Seller must then promptly take all necessary steps to meet the quality and description of the product/good.<br />
13. The goods/Products shall be delivered by the Supplier, at the time and place specified in the Purchase Order in writing from time to time prior to delivery. And the Supplier shall take the acknowledgement of the goods/products delivered from the Authorized Person of the client.<br />
14. The Seller must deliver all Products with a detailed, dated, delivery note giving full particulars in writing of the Purchase Order number (if any) and date and the number of packages and contents. If Products are delivered in parts, the note must specify the outstanding balance to be delivered.<br />
15. The Seller shall, at its own expense, promptly repair or replace any Products that are lost or damaged in transit to the place of delivery specified by the Buyer.<br />
16. Seller shall raise an invoice against the Purchase Order issued by the Buyer. And for every single purchase order, separate invoice must be issued.</p>

<p>17. action will be taken if terms & conditions are followed.</p>
</div>
</div>
</div>
</div>
</div>   
		</div>
	<div style="width: 100%">
			<img src='https://stallion.build/stallion-new/media/backend/images/project-img/1650349134.png' width="100%">   

		</div>
	</div>
</body>
</html>

''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.projectName!.toUpperCase()} - PERCENTAGE',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => widget.updateScreen('RequestWorkOrderPercentage'),
          ),
        ),
        body: const SingleChildScrollView(
          child: HtmlWidget(kLocalExamplePage),
        ));
  }
}
