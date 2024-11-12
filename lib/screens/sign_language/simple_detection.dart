// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
//
// import 'package:image/image.dart' as img;
// // import 'package:tflite_v2/tflite_v2.dart';
//
// List<CameraDescription>? cameras;
//
//
// class SimpleDetectionPage extends StatefulWidget {
//   const SimpleDetectionPage({super.key});
//
//   @override
//   State<SimpleDetectionPage> createState() => _SimpleDetectionPageState();
// }
//
// class _SimpleDetectionPageState extends State<SimpleDetectionPage> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   List<dynamic>? _recognitions;
//   bool _isDetecting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _loadModel();
//   }
//
//   Future<void> _initializeCamera() async {
//     try {
//       cameras = await availableCameras();
//       if (cameras == null || cameras!.isEmpty) {
//         print("No cameras found!");
//         return;
//       }
//
//       _controller = CameraController(
//         cameras![0],
//         ResolutionPreset.medium,
//       );
//       _initializeControllerFuture = _controller.initialize();
//       setState(() {});
//     } catch (e) {
//       print("Error initializing camera: $e");
//     }
//   }
//
//   Future<void> _loadModel() async {
//     await Tflite.loadModel(
//       model: "assets/model/git1/model_unquant.tflite",
//       labels: "assets/model/git1/labels.txt",
//       numThreads: 1,
//       isAsset: true,
//       useGpuDelegate: false,
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     Tflite.close();
//     super.dispose();
//   }
//
//   void _detectSignLanguage(CameraImage image) async {
//     if (_isDetecting) return;
//
//     _isDetecting = true;
//
//     var recognitions = await Tflite.detectObjectOnFrame(
//       bytesList: image.planes.map((e) => e.bytes).toList(),
//       imageHeight: image.height,
//       imageWidth: image.width,
//       imageMean: 127.5,
//       imageStd: 127.5,
//       rotation: 90,
//       threshold: 0.1,
//       asynch: true,
//     );
//
//     setState(() {
//       _recognitions = recognitions;
//       _isDetecting = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Language Detection'),
//       ),
//       body: cameras == null || cameras!.isEmpty
//           ? const Center(child: Text("No camera found!"))
//           : FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return CameraPreview(_controller);
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: cameras == null || cameras!.isEmpty
//           ? null
//           : FloatingActionButton(
//         onPressed: () async {
//           try {
//             await _initializeControllerFuture;
//             _controller.startImageStream((CameraImage image) {
//               _detectSignLanguage(image);
//             });
//           } catch (e) {
//             print(e);
//           }
//         },
//         child: const Icon(Icons.camera),
//       ),
//     );
//   }
// }