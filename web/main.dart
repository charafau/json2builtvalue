import 'dart:html';
import 'package:json2builtvalue/parser.dart';

const String startingJson = """
 {
      "id": 157538,
      "date": "2017-07-21T10:30:34",
      "date_gmt": "2017-07-21T17:30:34",
      "type": "post",
      "link": "https://example.com",
      "title": {
          "rendered": "Json 2 dart built_value converter"
      },
      "tags": [
          1798,
          6298
      ]
}
""";


void main() {
//  querySelector('#output').text = 'Your Dart app is running.';

  Element outputText = querySelector('#output_text');
  TextAreaElement input = document.getElementById('input_text');
  input.text = startingJson;

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
      // outputText.text = json;
    } catch (e) {
      outputText.text = 'Error: ${e.toString()}';
    }
  });
}
