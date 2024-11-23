import 'dart:async';

import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import '../models/result.dart';
import 'app_helper.dart';

class TFLiteHelper {
  static final StreamController<List<Result>> tfLiteResultsController =
  StreamController<List<Result>>.broadcast();
  static final List<Result> _outputs = List<Result>.empty(growable: true);
  static bool modelLoaded = false;
  static double confidenceThreshold = 0.01; // Set your confidence threshold here

  static Future<void> loadModel() async {
    AppHelper.log("loadModel", "Loading model..");
    try {
      String? res = await Tflite.loadModel(
        model: "assets/samiul/second_mobnet_model.tflite",
        labels: "assets/samiul/labels.txt",
      );
      if (res == "success") {
        modelLoaded = true;
        AppHelper.log("loadModel", "Model loaded successfully");
      } else {
        AppHelper.log("loadModel", "Failed to load model");
      }
    } catch (e) {
      AppHelper.log("loadModel", "Error loading model: $e");
    }
  }

  static Future<void> classifyImage(CameraImage image) async {
    if (!modelLoaded) {
      AppHelper.log("classifyImage", "Model not loaded");
      return;
    }

    try {
      final List<dynamic>? results = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        numResults: 26, // Adjusted for 26 classes (letters A-Z)
      );

      if (results != null && results.isNotEmpty) {
        AppHelper.log("classifyImage", "Results loaded. ${results.length}");

        // Clear previous results
        _outputs.clear();

        // Populate outputs with new results that meet the confidence threshold
        for (var element in results) {
          double confidence = element['confidence'] as double;
          if (confidence >= confidenceThreshold) {
            _outputs.add(
              Result(
                confidence,
                element['index'] as int,
                element['label'] as String,
              ),
            );
            AppHelper.log(
              "classifyImage",
              "${element['confidence']} , ${element['index']}, ${element['label']}",
            );
          }
        }

        // Sort results according to confidence in descending order
        _outputs.sort((a, b) => b.confidence.compareTo(a.confidence));

        // Send results to stream
        tfLiteResultsController.add(_outputs);
      }
    } catch (e) {
      AppHelper.log("classifyImage", "Error during classification: $e");
    }
  }

  static void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
  }
}
