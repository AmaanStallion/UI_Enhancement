// import 'package:velopack_flutter/velopack_flutter.dart';
// import 'package:flutter/material.dart';

// class UpdateManagerPage extends StatefulWidget {
//   const UpdateManagerPage({super.key});

//   @override
//   State<UpdateManagerPage> createState() => _UpdateManagerPageState();
// }

// class _UpdateManagerPageState extends State<UpdateManagerPage> {
//   String _updateStatus = 'Checking for updates...';
//   // Replace with the URL where you host your Velopack releases file
//   final String updateUrl = 'https://your-app-updates-url.com';

//   @override
//   void initState() {
//     super.initState();
//     _checkForUpdates();
//   }

//   Future<void> _checkForUpdates() async {
//     try {
//       final available = await isUpdateAvailable(url: updateUrl);
//       if (available) {
//         setState(() {
//           _updateStatus = 'Update available! Tap to install and restart.';
//         });
//       } else {
//         setState(() {
//           _updateStatus = 'App is up to date.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _updateStatus = 'Failed to check for updates: $e';
//       });
//     }
//   }

//   Future<void> _applyUpdate() async {
//     // This will download, apply the update, and restart the app
//     await updateAndRestart(url: updateUrl);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Velopack Update Manager')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_updateStatus),
//             if (_updateStatus.contains('Update available'))
//               ElevatedButton(
//                 onPressed: _applyUpdate,
//                 child: const Text('Install Update and Restart'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:velopack_flutter/velopack_flutter.dart';

class UpdateManagerPage extends StatefulWidget {
  final VoidCallback? onSkip;

  const UpdateManagerPage({super.key, this.onSkip});

  @override
  State<UpdateManagerPage> createState() => _UpdateManagerPageState();
}

class _UpdateManagerPageState extends State<UpdateManagerPage> {
  String _updateStatus = 'Checking for updates...';
  bool _isUpdateAvailable = false;
  bool _isProcessing = false;

  // IMPORTANT: URL must point to the folder containing 'releases.win.json'
  final String updateUrl = 'http://skrite.com/releases';

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      // 2026 API: Use top-level function isUpdateAvailable
      // This will fail if app is not installed via Velopack (e.g., debug mode)
      final bool available = await isUpdateAvailable(url: updateUrl);

      if (mounted) {
        setState(() {
          print('available : ${available}');
          _isUpdateAvailable = available;
          _updateStatus = available
              ? 'A new version is available!'
              : 'Your application is up to date.';
        });
      }
    } catch (e) {
      // Handle cases where app is not installed via Velopack or other errors
      debugPrint("Velopack Check Error: $e");
      if (mounted) {
        setState(() {
          // In debug mode or when not properly installed, just show "up to date"
          _isUpdateAvailable = false;
          _updateStatus = 'Your application is up to date.';
        });
      }
    }
  }

  Future<void> _applyUpdate() async {
    setState(() {
      _isProcessing = true;
      _updateStatus = 'Downloading and applying update...';
    });

    try {
      // 2026 API: Use top-level function updateAndRestart
      // This handles downloading, installing, and restarting the app.
      await updateAndRestart(url: updateUrl);
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _updateStatus = 'Update failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Software Updates')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isUpdateAvailable
                    ? Icons.system_update
                    : Icons.check_circle_outline,
                size: 80,
                color: _isUpdateAvailable ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                _updateStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              if (_isUpdateAvailable && !_isProcessing) ...[
                ElevatedButton.icon(
                  onPressed: _applyUpdate,
                  icon: const Icon(Icons.download),
                  label: const Text('Install & Restart Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onSkip ?? () => Navigator.pop(context),
                  child: const Text('Skip for now'),
                ),
              ],
              if (_isProcessing) const CircularProgressIndicator(),
              if (!_isUpdateAvailable && !_isProcessing) ...[
                ElevatedButton(
                  onPressed: widget.onSkip ?? () => Navigator.pop(context),
                  child: const Text('Continue to App'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
