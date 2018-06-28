import 'dart:html';
import 'package:json2builtvalue/parser.dart';

void main() {
//  querySelector('#output').text = 'Your Dart app is running.';

  Element outputText = querySelector('#output_text');

  querySelector('#convert').onClick.forEach((MouseEvent event) async {
    try {
//      String json = querySelector('#input_text').text;

      TextAreaElement elementById = document.getElementById('input_text');
      String json = elementById.value;
      print('json is $json');
      Parser parser = new Parser();
//      String outputClasses = parser.parse(json);

//      outputText.text = outputClasses;
      outputText.text = json;
    } catch (e) {
      outputText.text = 'Error';
    }
  });
}
