
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../helpers/app_helper.dart';
import '../helpers/camera_helper.dart';
import '../helpers/tflite_helper.dart';
import '../models/result.dart';



class DetectScreen extends StatefulWidget {
  final String title;

  const DetectScreen({super.key, required this.title});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen>
    with TickerProviderStateMixin {
  late AnimationController _colorAnimController;
  late Animation<Color?> _colorTween;
  final FlutterTts flutterTts = FlutterTts();

  List<Result> outputs = [];

  @override
  void initState() {
    super.initState();

    // Load TFLite Model
    TFLiteHelper.loadModel().then((value) {
      setState(() {
        TFLiteHelper.modelLoaded = true;
      });
    });

    // Initialize Camera
    CameraHelper.initializeCamera();

    // Setup Animation
    _setupAnimation();

    // Subscribe to TFLite's Classify events
    TFLiteHelper.tfLiteResultsController.stream.listen(
          (value) {
        for (var element in value) {
          _colorAnimController.animateTo(
            element.confidence,
            curve: Curves.bounceIn,
            duration: const Duration(milliseconds: 500),
          );
        }

        // Set Results
        setState(() {
          outputs = value;
          CameraHelper.isDetecting = false;
        });
      },
      onError: (error) {
        AppHelper.log("listen", error.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: FutureBuilder<void>(
        future: CameraHelper.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                CameraPreview(CameraHelper.camera),
                _buildResultsWidget(width, outputs),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    TFLiteHelper.disposeModel();
    CameraHelper.camera.dispose();
    _colorAnimController.dispose();
    AppHelper.log("dispose", "Clear resources.");
    super.dispose();
  }

  Widget _buildResultsWidget(double width, List<Result> outputs) {
    Future<void> speak(String s) async {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(s);
    }

    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: outputs.isNotEmpty
              ? ListView.builder(
            itemCount: outputs.length,
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  Text(
                    outputs[index].label,
                    style: TextStyle(
                      color: _colorTween.value,
                      fontSize: 20.0,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _colorAnimController,
                    builder: (context, child) => LinearPercentIndicator(
                      width: width * 0.88,
                      lineHeight: 14.0,
                      percent: outputs[index].confidence,
                      progressColor: _colorTween.value,
                    ),
                  ),
                  Text(
                    "${(outputs[index].confidence * 100.0).toStringAsFixed(2)} %",
                    style: TextStyle(
                      color: _colorTween.value,
                      fontSize: 16.0,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        speak(outputs[index].label);
                      },
                      child: Icon(
                        Icons.play_arrow,
                        size: 60,
                        color: Color(0xff375079),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
              : Center(
            child: Text(
              "Waiting for model to detect..",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setupAnimation() {
    _colorAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _colorTween = ColorTween(begin: Colors.green, end: Colors.red)
        .animate(_colorAnimController);
  }
}
