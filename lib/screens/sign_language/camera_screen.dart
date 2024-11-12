// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:async';
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as IMG;
// import 'package:native_screenshot/native_screenshot.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:tflite/tflite.dart';
//
// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});
//
//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen> {
//   bool _recording = false;
//   bool _initialized = true;
//   int currentCamera = 0;
//   late CameraController _controller;
//   late List<CameraDescription> cameras;
//   FlutterTts flutterTts = FlutterTts();
//
//   late Timer timer;
//   String output = "";
//   String prevOutput = "";
//   String translation = "";
//   double confidenceScore = 0.0;
//   Color boxColor = Colors.black;
//   bool steadyTextDisplay = false;
//   String userId = ""; // New user ID state variable
//
//
//   Future<void> _requestPermissions() async {
//     if (await Permission.storage.isDenied) {
//       await Permission.storage.request();
//     }
//     if (await Permission.manageExternalStorage.isDenied) {
//       await Permission.manageExternalStorage.request();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions(); // Request permissions at the start
//     _cameraSetUp();
//     userId = "6666"; // Example userId
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   // Set up the camera
//   _cameraSetUp() async {
//     cameras = await availableCameras();
//     _controller = CameraController(cameras[0], ResolutionPreset.max);
//     await _controller.initialize();
//     setState(() => _initialized = false);
//   }
//
//   // Switch between front and back camera
//   void switchCamera() async {
//     if (cameras.length > 1) {
//       _controller = CameraController(
//           currentCamera == 0 ? cameras[1] : cameras[0], ResolutionPreset.max);
//       await _controller.initialize();
//       setState(() => currentCamera = currentCamera == 0 ? 1 : 0);
//     }
//   }
//
//   // Start or stop recording
//   _recordVideo() async {
//     if (_recording) {
//       timer.cancel();
//       if (userId.isNotEmpty) {
//        // storeHistory(translation);
//       }
//       setState(() => _recording = false);
//     } else {
//       setState(() => _recording = true);
//       translation = "";
//       timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//         String? path = await NativeScreenshot.takeScreenshot();
//
//         if (path == null || path.isEmpty) {
//           print("Screenshot didn't work");
//         }
//
//         File imgFile = File(path!);
//         Uint8List bytes = imgFile.readAsBytesSync();
//         IMG.Image? src = IMG.decodeImage(bytes);
//
//         if (src != null) {
//           IMG.Image destImage = IMG.copyCrop(src, 300, 990, 560, 560);
//           IMG.Image resizedImage = IMG.copyResize(destImage, width: 64, height: 64);
//           var res = await Tflite.runModelOnBinary(
//               binary: imageToByteListFloat32(resizedImage, 64, 0.0, 255.0),
//               numResults: 29);
//           if (res != null) {
//             output = res[0]['label'];
//             steadyTextDisplay = true;
//             confidenceScore = res[0]['confidence'];
//             if (confidenceScore > 0.85) {
//               boxColor = Colors.green;
//               steadyTextDisplay = false;
//               if (output != prevOutput && output.length == 1) {
//                 prevOutput = output;
//                 translation += output;
//               }
//             } else if (confidenceScore > 0.6) {
//               boxColor = Colors.yellow;
//             } else {
//               boxColor = Colors.red;
//             }
//             setState(() {});
//           }
//         }
//       });
//     }
//   }
//
//   Uint8List imageToByteListFloat32(
//       IMG.Image img, int inputSize, double mean, double std) {
//     var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
//     var buffer = Float32List.view(convertedBytes.buffer);
//     int pixelIndex = 0;
//     for (var i = 0; i < inputSize; i++) {
//       for (var j = 0; j < inputSize; j++) {
//         var pixel = img.getPixel(j, i);
//         buffer[pixelIndex++] = (IMG.getRed(pixel) - mean) / std;
//         buffer[pixelIndex++] = (IMG.getGreen(pixel) - mean) / std;
//         buffer[pixelIndex++] = (IMG.getBlue(pixel) - mean) / std;
//       }
//     }
//     return convertedBytes.buffer.asUint8List();
//   }
//
//   // Send video to Flask backend
//   // void storeHistory(String translation) async {
//   //   var url = Uri.parse('https://signify-10529.uc.r.appspot.com/history');
//   //   var response = await http.post(
//   //     url,
//   //     headers: <String, String>{
//   //       'Content-Type': 'application/json; charset=UTF-8',
//   //     },
//   //     body: jsonEncode(<String, String>{'id': userId, 'translation': translation}),
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_initialized) {
//       return const Center(child: CircularProgressIndicator());
//     } else {
//       return Scaffold(
//         body: Stack(
//           children: [
//             CameraPreview(_controller),
//             Positioned(
//               left: steadyTextDisplay ? 60 : 175,
//               top: 260,
//               child: Text(
//                 steadyTextDisplay
//                     ? "Keep steady for accurate results"
//                     : "${(confidenceScore * 100).toStringAsFixed(2)}%",
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//             Align(
//               alignment: Alignment.center,
//               child: Container(
//                 width: 200,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: boxColor, width: 5),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.topRight,
//               child: SafeArea(
//                 child: IconButton(
//                   onPressed: () {},
//                   icon: Icon(Icons.settings, size: 30, color: Colors.black),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment(0, 0.7285),
//               child: Text(translation, style: TextStyle(fontSize: 25)),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 height: 100,
//                 color: Colors.black54,
//                 padding: EdgeInsets.all(25),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     FloatingActionButton(
//                       child: Icon(Icons.volume_up, color: Colors.white),
//                       onPressed: () async {
//                         await flutterTts.setLanguage("en-US");
//                         await flutterTts.setPitch(1);
//                         await flutterTts.speak(translation);
//                       },
//                     ),
//                     FloatingActionButton(
//                       child: Icon(_recording ? Icons.stop : Icons.circle,
//                           color: Colors.white, size: 40),
//                       onPressed: _recordVideo,
//                     ),
//                     FloatingActionButton(
//                       child: Icon(Icons.autorenew, color: Colors.white),
//                       onPressed: switchCamera,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
