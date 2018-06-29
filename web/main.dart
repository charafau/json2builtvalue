import 'dart:html';
import 'package:json2builtvalue/parser.dart';

void main() {
//  querySelector('#output').text = 'Your Dart app is running.';

  Element outputText = querySelector('#output_text');

  querySelector('#convert').onClick.forEach((MouseEvent event) async {
    try {
      TextInputElement rootClassNameElement =
          document.getElementById('root_class_name');
      String rootClassName = rootClassNameElement.value;

      TextAreaElement elementById = document.getElementById('input_text');
      String json = elementById.value;
      print('json is $json');
      Parser parser = new Parser();
      String outputClasses =
          parser.parse(json, rootClassName.replaceAll(' ', ''));

      outputText.text = outputClasses;
      // outputText.text = rootClassName;
    } catch (e) {
      outputText.text = 'Error: ${e.toString()}';
    }
  });
}
