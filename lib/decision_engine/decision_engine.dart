import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'inference_simplifier.dart';
import 'package:text_to_speech/text_to_speech.dart';

class DecisionEngine {
  final _queueController = StreamController<List<dynamic>>();
  final _batchJobQueue = Queue<Map<String, dynamic>>();
  final _tts = TextToSpeech();

  DecisionEngine() {
    if (kDebugMode) {
      print("Initializing decision engine..!");
    }

    final _consumerSubscription = _consumer.listen((recognizedObjects) {
      // print("Decision Engine: $recognizedObjects");
      // print(inference_simplifier(recognizedObjects));
      final simplified_inference = inference_simplifier(recognizedObjects);
      if (simplified_inference['alignments'] != []) {
        _batchJobQueue.add(simplified_inference);
      }
    }, cancelOnError: false);
    
    Timer.periodic(const Duration(seconds: 4), (timer) {
      final queuedInferences = _batchJobQueue.toList();
      // print("Currently queued: ${_batchJobQueue.toList()}");
      _batchJobQueue.clear();
      Set<String> categories = <String>{};
      Set<String> directions = <String>{};
      for (var inference in queuedInferences) {
        categories.addAll(inference['category']);
        directions.addAll(inference['alignments']);
      }
      if (directions.length > 2) {
        directions = {'! Heavy traffic or intersection ahead!'};
      }
      final decisionString = "${categories.join(', ')} ${directions.join(', ')}";
      print(decisionString);
      if (directions.isNotEmpty) {
        _tts.speak(decisionString);
      }
    });

  }

  void dispose() {
    _queueController.close();
  }

  Stream<List<dynamic>> get _consumer {
    return _queueController.stream;
  }

  StreamSink<List<dynamic>> get inferenceSink {
    return _queueController.sink;
  }
}