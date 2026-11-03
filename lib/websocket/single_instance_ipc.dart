// import 'dart:convert';
// import 'dart:io';

// class SingleInstanceIpc {
//   static const _port = 40404; // pick a stable, unused port

//   static Future<void> startServer(
//     void Function(List<String> args) onArgs,
//   ) async {
//     final server = await ServerSocket.bind(
//       InternetAddress.loopbackIPv4,
//       _port,
//     );

//     server.listen((client) {
//       client.listen((data) {
//         final decoded = utf8.decode(data);
//         final args = List<String>.from(jsonDecode(decoded));
//         onArgs(args);
//       });
//     });
//   }

//   static Future<void> sendArgs(List<String> args) async {
//     try {
//       final socket = await Socket.connect(
//         InternetAddress.loopbackIPv4,
//         _port,
//         timeout: const Duration(milliseconds: 500),
//       );
//       socket.write(jsonEncode(args));
//       await socket.flush();
//       await socket.close();
//     } catch (_) {
//       // First instance not ready → ignore
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';

class SingleInstanceIpc {
  static const int _port = 40404; // stable app-specific port

  static Future<void> startServer(
    void Function(List<String> args) onArgs,
  ) async {
    final server = await ServerSocket.bind(
      InternetAddress.loopbackIPv4,
      _port,
    );

    server.listen((client) {
      client.listen((data) {
        final decoded = utf8.decode(data);
        final args = List<String>.from(jsonDecode(decoded));
        onArgs(args);
      });
    });
  }

  static Future<void> sendArgs(List<String> args) async {
    try {
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        _port,
        timeout: const Duration(milliseconds: 500),
      );
      socket.write(jsonEncode(args));
      await socket.flush();
      await socket.close();
    } catch (_) {
      // First instance not ready yet → ignore
    }
  }
}
