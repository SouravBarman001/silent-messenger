import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:we_chat/screens/sign_language/sign_test/helpers/tflite_helper.dart';


import 'app_helper.dart';



class CameraHelper {
  static late CameraController camera;
  static bool isDetecting = false;
  static const CameraLensDirection _direction = CameraLensDirection.back;
  static late Future<void> initializeControllerFuture;

  static Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
          (List<CameraDescription> cameras) => cameras.firstWhere(
            (CameraDescription camera) => camera.lensDirection == dir,
        orElse: () => throw Exception('No camera found in the specified direction'),
      ),
    );
  }

  static Future<void> initializeCamera() async {
    AppHelper.log("initializeCamera", "Initializing camera..");
    try {
      camera = CameraController(
        await _getCamera(_direction),
        defaultTargetPlatform == TargetPlatform.iOS
            ? ResolutionPreset.low
            : ResolutionPreset.high,
        enableAudio: false,
      );
      initializeControllerFuture = camera.initialize().then((_) {
        AppHelper.log("initializeCamera", "Camera initialized, starting camera stream..");

        camera.startImageStream((CameraImage image) {
          if (!TFLiteHelper.modelLoaded || isDetecting) return;

          isDetecting = true;
          try {
            TFLiteHelper.classifyImage(image);
          } catch (e) {
            print("Error in image classification: $e");
          } finally {
            isDetecting = false;  // Reset the flag after classification
          }
        });
      });
    } catch (e) {
      print("Camera initialization failed: $e");
    }
  }
}
