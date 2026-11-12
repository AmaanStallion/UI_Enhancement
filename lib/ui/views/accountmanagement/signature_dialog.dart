import 'po_action_feedback.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_style.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_layout.dart';
import 'package:stallion/ui/views/accountmanagement/account_management_preview.dart';
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:signature/signature.dart';
// import 'package:http/http.dart' as http;
// import 'package:stallion/utils/app_url.dart';
// import 'package:http_parser/http_parser.dart';

// class SignatureDialog extends StatefulWidget {
//   const SignatureDialog({
//     super.key,
//     this.projectId,
//     this.towarId,
//     this.projectName,
//     this.towarName,
//     this.onTap,
//     this.orderId,
//     this.handSignUrl,
//   });
//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? towarName;
//   final String? orderId;
//   final VoidCallback? onTap;
//   final String? handSignUrl;

//   @override
//   State<SignatureDialog> createState() => _SignatureDialogState();
// }

// class _SignatureDialogState extends State<SignatureDialog> {
//   final SignatureController _controller = SignatureController(
//     penStrokeWidth: 3,
//     penColor: Colors.blue,
//     exportBackgroundColor: Colors.white,
//   );
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   PlatformFile? arrayFiles;

//   // Future<void> _handleSubmit() async {
//   //   if (_controller.isNotEmpty) {
//   //     final Uint8List? signature = await _controller.toPngBytes();
//   //     print("Signature captured!");
//   //     Navigator.pop(context, signature);

//   //     var request =
//   //         http.MultipartRequest('POST', Uri.parse(AppUrl.wsSetPoHandSign));
//   //     request.headers.addAll({"Authorization": "Bearer token"});
//   //     final SharedPreferences prefs = await _prefs;
//   //     String? userId = (prefs.getString('mobileNo') ?? (useAccountManagementTestData ? '1' : null));
//   //     request.fields["user_id"] = userId ?? '';

//   //     request.fields["project_id"] = widget.projectId ?? '';
//   //     request.fields["towar_id"] = widget.towarId ?? '';
//   //     request.fields["order_id"] = widget.orderId ?? '';

//   //     PlatformFile file = arrayFiles!;
//   //     request.files.add(
//   //       await http.MultipartFile.fromPath(
//   //         "po_hand_sing",
//   //         file.path.toString(),
//   //       ),
//   //     );
//   //     var response = await request.send();

//   //     if (response.statusCode == 200) {
//   //       setState(() {});
//   //     } else {}
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text("Please provide a signature")),
//   //     );
//   //   }
//   // }
//   Future<void> _handleSubmit() async {
//     if (_controller.isNotEmpty) {
//       final Uint8List? signature = await _controller.toPngBytes();

//       if (signature != null) {
//         print("Signature captured!");

//         final request =
//             http.MultipartRequest('POST', Uri.parse(AppUrl.wsSetPoHandSign));
//         request.headers.addAll({
//           "Authorization": "Bearer token", // Replace with actual token
//         });

//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         String? userId = (prefs.getString('mobileNo') ?? (useAccountManagementTestData ? '1' : null));

//         request.fields["user_id"] = userId ?? '';
//         request.fields["project_id"] = widget.projectId ?? '';
//         request.fields["towar_id"] = widget.towarId ?? '';
//         request.fields["order_id"] = widget.orderId ?? '';

//         // Add signature image from memory
//         request.files.add(
//           http.MultipartFile.fromBytes(
//             'po_hand_sing', // This should match the field name expected by your API
//             signature,
//             filename: 'signature.png',
//             contentType: MediaType('image', 'png'),
//           ),
//         );

//         print(request.fields);
//         final response = await request.send();

//         if (response.statusCode == 200) {
//           print("Signature uploaded successfully!");
//           Navigator.pop(context, signature);

//           // widget.onTap!();
//           setState(() {});
//         } else {
//           print("Upload failed with status: ${response.statusCode}");
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Failed to upload signature")),
//           );
//         }
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please provide a signature")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Container(
//         width: 500,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(vertical: 8),
//               decoration: BoxDecoration(
//                   // borderRadius: BorderRadius.circular(5),
//                   color: Colors.black),
//               // padding: EdgeInsets.only(top: 12),
//               child: Text(
//                 "SIGNATURE",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),

//                 // style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Padding(
//                       padding: EdgeInsets.all(12),
//                       child: Text(
//                         "Sign below",
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w600),
//                       )),
//                   TextButton(
//                     onPressed: _controller.clear,
//                     child: const Text(
//                       "Clear",
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(border: Border.all()),
//               height: (MediaQuery.sizeOf(context).height * 0.3).clamp(120.0, 200.0),
//               child: Signature(
//                 controller: _controller,
//                 backgroundColor: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                           // borderRadius: BorderRadius.circular(5),
//                           color: Colors.black),
//                       child: const Text(
//                         "CLOSE",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 1),
//                 Expanded(
//                   child: InkWell(
//                     onTap: _handleSubmit,
//                     child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 8),
//                         decoration: BoxDecoration(
//                             // borderRadius: BorderRadius.circular(5),
//                             color: Colors.black),
//                         child: const Text(
//                           "SUBMIT",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                           ),
//                         )),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stallion/utils/app_url.dart';

class SignatureDialog extends StatefulWidget {
  const SignatureDialog({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.onTap,
    this.orderId,
    this.handSignUrl,
    this.flagRedirect,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? orderId;
  final VoidCallback? onTap;
  final String? handSignUrl;
  final String? flagRedirect;
  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.blue,
    exportBackgroundColor: Colors.white,
  );

  bool _showSignaturePad = true;

  @override
  void initState() {
    super.initState();
    if (widget.handSignUrl != null && widget.handSignUrl!.isNotEmpty) {
      _showSignaturePad = false;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_showSignaturePad) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Clear existing signature to re-sign")),
      );
      return;
    }

    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a signature")),
      );
      return;
    }

    final Uint8List? signature = await _controller.toPngBytes();
    if (signature == null) return;

    if (useAccountManagementTestData) {
      if (!mounted) return;
      Navigator.pop(context, signature);
      widget.onTap?.call();
      return;
    }

    final request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.wsSetPoHandSign));

    request.headers.addAll({
      "Authorization": "Bearer token", // replace with real token
    });

    final prefs = await SharedPreferences.getInstance();
    request.fields["user_id"] = (prefs.getString('mobileNo') ??
            (useAccountManagementTestData ? '1' : null)) ??
        '';
    request.fields["project_id"] = widget.projectId ?? '';
    request.fields["towar_id"] = widget.towarId ?? '';
    request.fields["order_id"] = widget.orderId ?? '';

    request.files.add(
      http.MultipartFile.fromBytes(
        'po_hand_sing',
        signature,
        filename: 'signature.png',
        contentType: MediaType('image', 'png'),
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      Navigator.pop(context, signature);
      widget.onTap?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload signature")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: Colors.black,
              child: const Text(
                "SIGNATURE",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),

            // TITLE + CLEAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Sign below",
                      style: TextStyle(
                          fontSize: context.accountFont(14, mobile: 14),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (widget.flagRedirect != "Issued")
                    PoActionFeedback(
                        child: TextButton(
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _showSignaturePad = true;
                        });
                      },
                      child: Text(
                        "Clear",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                            fontSize: context.accountFont(14, mobile: 14),
                            fontWeight: FontWeight.w600),
                      ),
                    )),
                ],
              ),
            ),

            // SIGNATURE / IMAGE VIEW
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height:
                  (MediaQuery.sizeOf(context).height * 0.3).clamp(120.0, 200.0),
              width: 450,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black87, width: 1),
              ),
              child: widget.flagRedirect == "Issued"
                  ? (useAccountManagementTestData
                      ? const Icon(Icons.description_outlined,
                          size: 48, color: Colors.black54)
                      : Image.network(
                          widget.handSignUrl!,
                          // fit: BoxFit.fill,
                          errorBuilder: (_, __, ___) {
                            return const Center(
                                child: Text("Failed to load signature"));
                          },
                        ))
                  : _showSignaturePad
                      ? Signature(
                          controller: _controller,
                          backgroundColor: Colors.white,
                        )
                      : (useAccountManagementTestData
                          ? const Icon(Icons.description_outlined,
                              size: 48, color: Colors.black54)
                          : Image.network(
                              widget.handSignUrl!,
                              // fit: BoxFit.fill,
                              errorBuilder: (_, __, ___) {
                                return const Center(
                                    child: Text("Failed to load signature"));
                              },
                            )),
            ),

            const SizedBox(height: 12),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: PoActionFeedback(
                      child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black),
                          color: Colors.white),
                      child: const Text(
                        "CLOSE",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  )),
                ),
                const SizedBox(width: 1),
                Expanded(
                  child: PoActionFeedback(
                      enabled: widget.flagRedirect != 'Issued',
                      child: InkWell(
                        onTap: widget.flagRedirect == "Issued"
                            ? null
                            : _handleSubmit,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: widget.flagRedirect == "Issued"
                                  ? Colors.grey
                                  : Colors.black),
                          child: const Text(
                            "SUBMIT",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
