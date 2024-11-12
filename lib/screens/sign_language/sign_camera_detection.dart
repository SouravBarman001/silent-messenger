import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SignCameraDetection extends StatefulWidget {
  const SignCameraDetection({super.key});

  @override
  State<SignCameraDetection> createState() => _SignCameraDetectionState();
}

class _SignCameraDetectionState extends State<SignCameraDetection> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _recordAndUploadVideo() async {
    try {
      if (!_isCameraInitialized) return;

      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String videoDirectory = '${appDirectory.path}/Videos';
      await Directory(videoDirectory).create(recursive: true);
      final String filePath = path.join(videoDirectory, '${DateTime.now().millisecondsSinceEpoch}.mp4');

      await _controller.startVideoRecording();
      await Future.delayed(Duration(seconds: 3)); // Record for 3 seconds
      final XFile videoFile = await _controller.stopVideoRecording();

      final request = http.MultipartRequest('POST', Uri.parse('http://192.168.0.101:5000/upload_video'));
      request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final data = jsonDecode(responseData.body);

        setState(() {
          // Update the result based on the backend response
          if (data['message'] != null) {
            _result = data['message']; // Directly use the message from the API
          } else {
            _result = 'Error: No message returned';
          }
        });
      } else {
        setState(() {
          _result = 'Error: ${response.reasonPhrase}';
        });
      }
        } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  void _toggleFlashlight() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          Expanded(child: SizedBox()),
          Icon(Icons.person_4, color: Colors.white),
          Expanded(child: SizedBox(), flex: 5),
          IconButton(
            onPressed: _toggleFlashlight,
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _isCameraInitialized
                ? AspectRatio(
              aspectRatio: 1 / _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            )
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 150,
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _recordAndUploadVideo,
              child: const Text('Record and Upload Video'),
            ),
            Text(
              _result,
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
