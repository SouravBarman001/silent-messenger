import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';

import '../constraints.dart';

class IndDetectionScreen extends StatefulWidget {
  const IndDetectionScreen({super.key});

  @override
  State<IndDetectionScreen> createState() => _IndDetectionScreenState();
}

class _IndDetectionScreenState extends State<IndDetectionScreen> {
  CameraController? cameraController;
  CameraImage? cameraImage;
  String answer = "";

  @override
  void initState() {
    super.initState();
    loadModel();
    initCamera();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/samiul/model.tflite",
      labels: "assets/samiul/label.txt",
    );
  }

  initCamera() {
    cameraController = CameraController(
      cameras[0], // 0 for back camera
      ResolutionPreset.medium,
    );

    cameraController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        cameraController!.startImageStream((image) {
          cameraImage = image;
          applyModelOnImages();
        });
      });
    });
  }

  applyModelOnImages() async {
    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 3,
        threshold: 0.5,
        asynch: true,
      );

      setState(() {
        answer = predictions!.map((prediction) {
          String label = prediction['label'];
          double confidence = prediction['confidence'];
          return "${label[0].toUpperCase()}${label.substring(1)} (${(confidence * 100).toStringAsFixed(1)}%)";
        }).join('\n');
      });
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      body: cameraController != null && cameraController!.value.isInitialized
          ? Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: cameraController!.value.aspectRatio,
              child: CameraPreview(cameraController!),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.black87,
              child: Text(
                answer,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: MaterialButton(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onPressed: () {
            initCamera();
          },
          child: Text(
            'Start Detecting',
            style: TextStyle(color: Colors.indigo[900]),
          ),
        ),
      ),
    );
  }
}
