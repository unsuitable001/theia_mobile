import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'package:theia_mobile/constants.dart';


typedef void Callback(List<dynamic> list, int h, int w);

class Recognizer extends StatefulWidget {
  final CameraController cameraController;
  final Callback setRecognitions;

  Recognizer(this.cameraController, this.setRecognitions, {super.key});

  @override
  _RecognizerState createState() => _RecognizerState();
}

class _RecognizerState extends State<Recognizer> {
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    widget.cameraController.startImageStream((CameraImage img) {
      if (!isDetecting) {
        isDetecting = true;

        int startTime = DateTime.now().millisecondsSinceEpoch;

        Tflite.detectObjectOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          model: "SSDMobileNet",
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: modelInputMean,
          imageStd: modelInputStd,
          numResultsPerClass: 1,
          threshold: confidenceThreshold,
        ).then((recognitions) {
          int endTime = DateTime.now().millisecondsSinceEpoch;
          print("Detection took ${endTime - startTime}");

          widget.setRecognitions(recognitions!, img.height, img.width);

          isDetecting = false;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    Size? tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = widget.cameraController.value.previewSize;
    var previewH = math.max(tmp!.height, tmp!.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
      screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
      screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(widget.cameraController),
    );
  }
}
