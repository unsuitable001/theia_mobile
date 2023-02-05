// Simplifies a ml model's output
// Example:
// Input:
// [{rect: {w: 0.35613885521888733, x: 0.022280186414718628, h: 0.2725698947906494, y: 0.5106925964355469}, confidenceInClass: 0.6989190578460693, detectedClass: autorickshaw}]
// Output:
// {'class': 'autorickshaw', 'category': 'vehicle', 'danger_level': 'high', 'alignments': 'left, right'}
// TODO: ^ improve above, reduce duplicate events in this layer. analyze direction etc
// TODO: ^ currently picking only 'category' till the model gets very refined on 'class'


Map<String, dynamic> inference_simplifier(List<dynamic> inferences) {
  Map<String, int> alignmentMap = {
    'in front': 0,
    'close': 0,
    'left': 0,
    'right': 0
  };
  Set<String> classes = <String>{};
  for (var inference in inferences) {
    var _x = inference["rect"]["x"];
    var _w = inference["rect"]["w"];
    var _y = inference["rect"]["y"];
    var _h = inference["rect"]["h"];

    if (inference["detectedClass"] == "person" || inference["detectedClass"] == "rider") {
      classes.add(inference["detectedClass"]);
    } else {
      classes.add("vehicle");
    }

    if (_h >= 0.98 && _w >= 0.98) {
      print("Ignoring: camera is either obscured or false detection for null class");
    } else if(_w < 0.1){
      print("Ignoring: very tiny vehicle or person, probably a false flagging");
    } else {
      if (_y < 0.5) {
        alignmentMap['in front'] = (alignmentMap['in front']! + 1);
      } else {
        alignmentMap['close'] = (alignmentMap['close']! + 1);
      }

      if (_x < 0.5) {
        alignmentMap['left'] = (alignmentMap['left']! + 1);
      } else {
        alignmentMap['right'] = (alignmentMap['right']! + 1);
      }
    }

  }

  List<String> alignments = [];
  alignmentMap.forEach((key, value) {
    if (value > 1) {
      alignments.add(key);
    }
  });

  return {
    'category': classes,
    'alignments': alignments,
  };
}




