import 'dart:async';
import 'dart:convert';
import 'package:built_collection/src/list.dart';
import 'package:json2builtval/parser.dart';
import 'package:test/test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:json2builtval/root.dart';

main() {
  final _dartfmt = new DartFormatter();

//  "targets": ["dartium","javascript"],

  final String jsonString = """
  {
  "language": "dart",
  "age": 1,
  "website": {
    "homepage": "www.dartlang.org",
    "api": "api.dartlang.org"
  },
  "is_new": true,
  "version": 2.0
}
  """;

//  final String jsonString = """
//  {
//  "website": {
//    "homepage": "www.dartlang.org",
//    "api": "api.dartlang.org"
//  }
//}
//  """;

//  final String jsonString = """
//  {
//   "targets": ["dartium","javascript"]
//  }
//  """;

  test('should parse json', () {


    final parser = new Parser();

    var parse = parser.parse(jsonString);

    print(parse);

    expect(true, true);
  });


}
