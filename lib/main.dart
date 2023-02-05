import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tflite/tflite.dart';
import 'package:theia_mobile/bndbox.dart';
import 'package:theia_mobile/decision_engine/decision_engine.dart';
import 'package:theia_mobile/recognizer.dart';

import 'constants.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const TheiaApp());
}

/// TheiaApp is the Main Application.
class TheiaApp extends StatefulWidget {
  /// Default Constructor
  const TheiaApp({Key? key}) : super(key: key);

  @override
  State<TheiaApp> createState() => _TheiaAppState();
}

class _TheiaAppState extends State<TheiaApp> {
  late CameraController controller;
  final decisionEngine = DecisionEngine();
  // List<dynamic> _recognitions = [];
  // int _imageHeight = 0;
  // int _imageWidth = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    // TODO: Change initializing here
    loadModel();
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            Fluttertoast.showToast(
                msg: "CameraAccessDenied! Please allow camera access!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
            break;
          default:
            Fluttertoast.showToast(
                msg: "Error! ${e.code}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  loadModel() async {
    String? model = await Tflite.loadModel(
        model: "$assetPath/$modelName",
        labels: "$assetPath/$labelFilename"
    );
    if (kDebugMode) {
      print("Loaded model: $model");
    }
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    decisionEngine.inferenceSink.add(recognitions);
    // print(recognitions);
    // setState(() {
    //   _recognitions = recognitions;
    //   _imageHeight = imageHeight;
    //   _imageWidth = imageWidth;
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Stack(
        children: [
          Recognizer(controller, setRecognitions),
          // CameraPreview(controller),
          // Builder(
          //   builder: (context) {
          //     Size screen = MediaQuery.of(context).size;
          //     return BndBox(
          //         _recognitions,
          //         math.max(_imageHeight, _imageWidth),
          //         math.min(_imageHeight, _imageWidth),
          //         screen.height,
          //         screen.width
          //     );
          //   }
          // )
        ],
      ),
    );
  }
}
