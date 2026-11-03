// import 'package:flutter/material.dart';
// import 'package:stallion/utils/app_url.dart';
// // import 'package:oxford/utils/app_url.dart';
// import 'package:video_player_win/video_player_win.dart';

// class VideoItem extends StatefulWidget {
//   final String file;
//   final int index;
//   final String navigationFlag;
//   final String urll;
//   Function callbackVideo;
//   VideoItem(
//       {Key? key,
//       required this.file,
//       required this.index,
//       required this.navigationFlag,
//       required this.urll,
//       required this.callbackVideo})
//       : super(key: key);

//   @override
//   _VideoItemState createState() => _VideoItemState();
// }

// class _VideoItemState extends State<VideoItem> {
//   WinVideoPlayerController? controller;

//   @override
//   void initState() {
//     super.initState();
//     reload();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     controller?.dispose();
//   }

//   void reload() {
//     controller?.dispose();
//     controller = WinVideoPlayerController.network(widget.urll);
//     controller!.initialize().then((value) {
//       if (controller!.value.isInitialized) {
//         controller!.pause();
//         setState(() {});
//       } else {
//         print("video file load failed");
//       }
//     }).catchError((e) {
//       print("controller.initialize() error occurs: $e");
//     });
//     setState(() {});
//   }

//   final ValueNotifier<bool> _visible = ValueNotifier(true);

//   @override
//   Widget build(BuildContext context) {
//     return Stack(children: [
//       WinVideoPlayer(controller!),
//       Positioned(
//           bottom: 0,
//           left: 5,
//           right: 5,
//           child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 ValueListenableBuilder<WinVideoPlayerValue>(
//                   valueListenable: controller!,
//                   builder: ((context, value, child) {
//                     int minute = value.position.inMinutes;
//                     int second = value.position.inSeconds % 60;
//                     return Text("$minute:$second",
//                         style: Theme.of(context)
//                             .textTheme
//                             .headline6!
//                             .copyWith(color: Colors.white, fontSize: 10));
//                   }),
//                 ),
//                 IconButton(
//                     onPressed: () => controller?.play(),
//                     icon: const Icon(Icons.play_arrow, color: Colors.white)),
//                 IconButton(
//                     onPressed: () => controller?.pause(),
//                     icon: const Icon(Icons.pause, color: Colors.white)),
//                 IconButton(
//                     onPressed: () => controller?.seekTo(Duration(
//                         milliseconds:
//                             controller!.value.position.inMilliseconds -
//                                 10 * 1000)),
//                     icon: const Icon(Icons.fast_rewind_outlined,
//                         color: Colors.white)),
//                 IconButton(
//                     onPressed: () => controller?.seekTo(Duration(
//                         milliseconds:
//                             controller!.value.position.inMilliseconds +
//                                 10 * 1000)),
//                     icon: const Icon(Icons.fast_forward_outlined,
//                         color: Colors.white)),
//                 IconButton(
//                     onPressed: () {
//                       controller?.pause();
//                       widget.callbackVideo(widget.file, widget.index);
//                     },
//                     icon: const Icon(Icons.fullscreen_outlined,
//                         color: Colors.white)),
//               ]))
//     ]);
//   }
// }
