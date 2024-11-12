// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:tflite_v2/tflite_v2.dart';
// import '../../Utils/colors.dart';
// import '../../Utils/sizes.dart';
// // import '../../Utils/sizes.dart';
//
// class ViewfinderPage extends StatefulWidget {
//   const ViewfinderPage({super.key});
//
//   @override
//   State<ViewfinderPage> createState() => _ViewfinderPageState();
// }
//
// class _ViewfinderPageState extends State<ViewfinderPage> {
//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;
//   bool isCameraReady = false;
//   String label = '';
//   bool show = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }
//
//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final firstCamera = cameras[0];
//       _controller = CameraController(firstCamera, ResolutionPreset.ultraHigh);
//       _initializeControllerFuture = _controller?.initialize().then((_) async {
//         if (!mounted) return;
//         setState(() {
//           isCameraReady = true;
//         });
//
//         // Load the TFLite model
//         try {
//           final res = await Tflite.loadModel(
//             model: "assets/model/mobilenetv2_asl_model_final.tflite",
//             labels: "assets/model/labels.txt",
//           );
//           print('TFLite Model loaded: $res');
//
//           // Start the image stream
//           _controller?.startImageStream((image) async {
//             final results = await Tflite.runModelOnFrame(
//               bytesList: image.planes.map((plane) => plane.bytes).toList(),
//               imageHeight: image.height,
//               imageWidth: image.width,
//               threshold: 0.5,
//               numResults: 1,
//               asynch: true,
//             );
//
//             if (results != null && results.isNotEmpty) {
//               final newLabel = results.first['label'].toString();
//               print('Predicted label: $newLabel');
//
//               setState(() {
//                 label = newLabel;
//               });
//             }
//           });
//         } catch (e) {
//           print("Error loading TFLite model: $e");
//         }
//       });
//     } catch (e) {
//       print("Camera initialization error: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   Future<bool> _onWillPop() async {
//     await _controller?.dispose();
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         systemNavigationBarColor: whiteColor,
//       ),
//       child: WillPopScope(
//         onWillPop: _onWillPop,
//         child: Scaffold(
//           appBar: AppBar(
//             backgroundColor: secondaryColor,
//             automaticallyImplyLeading: true,
//             leading: Hero(
//               tag: 'back',
//               child: GestureDetector(
//                 onTap: () async {
//                   await _controller?.dispose();
//                   Get.back();
//                 },
//                 child: Icon(Icons.arrow_back, color: mainColor),
//               ),
//             ),
//           ),
//           backgroundColor: whiteColor,
//           body: Stack(
//             children: [
//               Column(
//                 children: [
//                   Flexible(
//                     flex: 5,
//                     child: isCameraReady
//                         ? Hero(
//                       tag: 'button',
//                       child: Container(
//                         width: double.infinity,
//                         child: CameraPreview(_controller!),
//                       ),
//                     )
//                         : Container(),
//                   ),
//                   Flexible(
//                     flex: 2,
//                     child: AnimatedContainer(
//                       decoration: BoxDecoration(
//                         color: whiteColor,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       duration: Duration(milliseconds: 200),
//                       width: displayWidth(context),
//                       child: Column(
//                         children: [
//                           SizedBox(height: 20),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   'Position ASL signs in the viewfinder above to get the English equivalent below:',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: mainColor,
//                                     fontFamily: 'Comfortaa',
//                                     fontWeight: FontWeight.w800,
//                                     fontSize: displayWidth(context) * 0.04,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 40),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 label,
//                                 style: TextStyle(
//                                   color: mainColor,
//                                   fontFamily: 'Comfortaa',
//                                   fontWeight: FontWeight.w800,
//                                   fontSize: displayWidth(context) * 0.14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
