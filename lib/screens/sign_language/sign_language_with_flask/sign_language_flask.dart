// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:camera/camera.dart';
//
// class SignLanguageDetection extends StatefulWidget {
//   @override
//   _SignLanguageDetectionState createState() => _SignLanguageDetectionState();
// }
//
// class _SignLanguageDetectionState extends State<SignLanguageDetection> {
//   CameraController? _cameraController;
//   String? _label;
//   double? _confidence;
//   bool _isCapturing = false;
//   Timer? _captureTimer;
//   bool _isProcessingFrame = false; // Prevent overlapping frame processing
//
//   final String _apiUrl = 'http://192.168.0.106:5001/predict';
//
//   @override
//   void initState() {
//     super.initState();
//     _checkAndInitializeCamera();
//   }
//
//   Future<void> _checkAndInitializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final frontCamera = cameras.firstWhere(
//             (camera) => camera.lensDirection == CameraLensDirection.front,
//         orElse: () => throw Exception("No front camera found."),
//       );
//
//       _cameraController = CameraController(
//         frontCamera,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//       await _cameraController?.initialize();
//
//       // Lock orientation to portrait
//       await _cameraController?.lockCaptureOrientation(DeviceOrientation.portraitUp);
//
//       if (mounted) setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Camera initialization failed: $e')),
//       );
//     }
//   }
//
//   void _toggleCapture() {
//     if (_isCapturing) {
//       _stopCapturing();
//     } else {
//       _startCapturing();
//     }
//   }
//
//   void _startCapturing() {
//     setState(() {
//       _isCapturing = true;
//     });
//
//     _captureTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _captureAndSendImage();
//     });
//   }
//
//   void _stopCapturing() {
//     _captureTimer?.cancel();
//     setState(() {
//       _isCapturing = false;
//     });
//   }
//
//   Future<void> _captureAndSendImage() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return;
//     }
//
//     if (_isProcessingFrame) return; // Skip if a frame is still being processed
//
//     _isProcessingFrame = true;
//     try {
//       final image = await _cameraController!.takePicture();
//       await _classifyImage(File(image.path));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to capture image: $e')),
//       );
//     } finally {
//       _isProcessingFrame = false;
//     }
//   }
//
//   Future<void> _classifyImage(File image) async {
//     try {
//       final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
//       request.files.add(await http.MultipartFile.fromPath('file', image.path));
//
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final decoded = json.decode(responseBody);
//
//       if (response.statusCode == 200) {
//         setState(() {
//           _label = decoded['label'];
//           _confidence = decoded['confidence'];
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(decoded['error'] ?? 'Unknown error occurred.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to classify image: $e')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _captureTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           'Sign Language Detection',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.info_outline),
//             onPressed: () => showAboutDialog(
//               context: context,
//               applicationName: 'Sign Language Detection',
//               applicationVersion: '1.0.0',
//               applicationIcon: Icon(Icons.gesture, size: 40),
//               children: [
//                 Text(
//                     'This app detects hand gestures using the front camera and sends them to a server for classification.'),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _cameraController == null ||
//                 !_cameraController!.value.isInitialized
//                 ? Center(child: CircularProgressIndicator())
//                 : CameraPreview(_cameraController!),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
//             ),
//             child: Column(
//               children: [
//                 if (_label != null && _confidence != null)
//                   Column(
//                     children: [
//                       Text(
//                         'Label: $_label',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.indigo,
//                         ),
//                       ),
//                       Text(
//                         'Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%',
//                         style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _toggleCapture,
//                       icon: Icon(
//                         _isCapturing ? Icons.pause : Icons.play_arrow,
//                         color: Colors.white,
//                       ),
//                       label: Text(
//                         _isCapturing ? 'Pause' : 'Start',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.indigo),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _stopCapturing,
//                       icon: Icon(Icons.stop, color: Colors.white),
//                       label: Text(
//                         'Stop',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.redAccent),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img; // Import the image package

class SignLanguageDetection extends StatefulWidget {
  @override
  _SignLanguageDetectionState createState() => _SignLanguageDetectionState();
}

class _SignLanguageDetectionState extends State<SignLanguageDetection> {
  CameraController? _cameraController;
  String? _label;
  double? _confidence;
  bool _isCapturing = false;
  Timer? _captureTimer;
  bool _isProcessingFrame = false;

  final String _apiUrl = 'http://192.168.0.106:5001/predict';

  @override
  void initState() {
    super.initState();
    _checkAndInitializeCamera();
  }

  Future<void> _checkAndInitializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => throw Exception("No front camera found."),
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController?.initialize();

      // Lock orientation to portrait
      await _cameraController?.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  void _toggleCapture() {
    if (_isCapturing) {
      _stopCapturing();
    } else {
      _startCapturing();
    }
  }

  void _startCapturing() {
    setState(() {
      _isCapturing = true;
    });

    _captureTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _captureAndSendImage();
    });
  }

  void _stopCapturing() {
    _captureTimer?.cancel();
    setState(() {
      _isCapturing = false;
    });
  }

  Future<void> _captureAndSendImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessingFrame) return; // Skip if a frame is still being processed

    _isProcessingFrame = true;
    try {
      final image = await _cameraController!.takePicture();
      await _classifyImage(File(image.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _classifyImage(File image) async {
    try {
      // Read the image file as bytes
      final imageBytes = await image.readAsBytes();

      // Decode the image using the image package
      img.Image? decodedImage = img.decodeImage(imageBytes);

      if (decodedImage != null) {
        // Adjust orientation based on EXIF metadata
        final correctedImage = img.bakeOrientation(decodedImage);

        // Save the corrected image back to the file
        final correctedBytes = img.encodeJpg(correctedImage);
        await image.writeAsBytes(correctedBytes);
      }

      // Proceed with the server request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);

      if (response.statusCode == 200) {
        setState(() {
          _label = decoded['label'];
          _confidence = decoded['confidence'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decoded['error'] ?? 'Unknown error occurred.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to classify image: $e')),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _captureTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Sign Language Detection',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Sign Language Detection',
              applicationVersion: '1.0.0',
              applicationIcon: Icon(Icons.gesture, size: 40),
              children: [
                Text(
                    'This app detects hand gestures using the front camera and sends them to a server for classification.'),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraController == null ||
                !_cameraController!.value.isInitialized
                ? Center(child: CircularProgressIndicator())
                : CameraPreview(_cameraController!),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
            ),
            child: Column(
              children: [
                if (_label != null && _confidence != null)
                  Column(
                    children: [
                      Text(
                        'Label: $_label',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      Text(
                        'Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleCapture,
                      icon: Icon(
                        _isCapturing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isCapturing ? 'Pause' : 'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo),
                    ),
                    ElevatedButton.icon(
                      onPressed: _stopCapturing,
                      icon: Icon(Icons.stop, color: Colors.white),
                      label: Text(
                        'Stop',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
