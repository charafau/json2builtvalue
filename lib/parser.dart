import 'dart:convert';

import 'package:built_collection/src/list.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:json2builtvalue/root.dart';
import 'package:recase/recase.dart';
import 'package:tuple/tuple.dart';

class Parser {
  final _dartfmt = new DartFormatter();

  String parse(String jsonString, String topLevelName) {
    var decode = json.decode(jsonString);

    List<Tuple2<String, List<Subtype>>> allClasses = [];

    //check if list or map
    if (decode is List) {}

    List<Subtype> topLevel = _getTypedClassFields(decode);
    allClasses.add(new Tuple2(topLevelName, topLevel));

    topLevel.forEach((Subtype s) {
      if ((s.type == JsonType.LIST && s.listType == JsonType.MAP) ||
          s.type == JsonType.MAP) {
        var getTypedClassFields = _getTypedClassFields(s.value);
        allClasses.add(new Tuple2(s.name, getTypedClassFields));
      }
    });

//    print('all: $allClasses');

    String output = _generateStringClass(topLevel, topLevelName);

//    allClasses.forEach((Tuple2<String, List<Subtype>> tuple){
//      _generateStringClass(tuple.item2, tuple.item1 + 'Dto');
//    });

    String reduce = allClasses
        .map((tuple) => _generateStringClass(tuple.item2, tuple.item1))
        .reduce((s1, s2) => s1 + s2);

    return reduce;
  }

  String _generateStringClass(List<Subtype> topLevel, String name) {
    var topLevelClass = new Class((b) => b
      ..abstract = true
      ..constructors.add(new Constructor((b) => b..name = '_'))
      ..implements.add(new Reference(
          'Built<${_getPascalCaseClassName(name)}, ${_getPascalCaseClassName(
              name)}Builder>'))
      ..name = _getPascalCaseClassName(name)
      ..methods = _buildMethods(topLevel)
      ..methods.add(new Method((b) => b
        ..name = 'toJson'
        ..returns = new Reference('String')
        ..body = new Code(
            'json.encode(serializers.serializeWith(${_getPascalCaseClassName(
                name)}.serializer, this));')))
      ..methods.add(new Method((b) => b
        ..name = 'fromJson'
        ..static = true
        ..requiredParameters.add(new Parameter((b) => b
          ..name = 'jsonString'
          ..type = new Reference('String')))
        ..returns = new Reference(_getPascalCaseClassName(name))
        ..body = new Code(
            'return serializers.deserializeWith(${_getPascalCaseClassName(
                name)}.serializer, json.decode(jsonString));')))
      ..methods.add(new Method((b) => b
        ..type = MethodType.getter
        ..name = 'serializer'
        ..static = true
        ..lambda = true
        ..returns =
            new Reference('Serializer<${_getPascalCaseClassName(name)}>')
        ..body = new Code('_\$${ReCase(name).camelCase}Serializer')))
      ..constructors.add(new Constructor((b) => b
        ..factory = true
        ..lambda = true
        ..body = Code('_\$${_getPascalCaseClassName(name)}')
        ..requiredParameters.add(new Parameter((b) => b
          ..name = '[updates(${_getPascalCaseClassName(name)}Builder b)]')))));

    String classString = topLevelClass.accept(new DartEmitter()).toString();

    String header = """
      library ${new ReCase(name).snakeCase};
      import 'dart:convert';
      
      import 'package:built_collection/built_collection.dart';
      import 'package:built_value/built_value.dart';
      import 'package:built_value/serializer.dart';
      
      part '${new ReCase(name).snakeCase}.g.dart';
    
    """;

    String output = _dartfmt.format(header + classString);

//    print(output);
    return output;
  }

  String _getPascalCaseClassName(String name) => new ReCase(name).pascalCase;

  ListBuilder<Method> _buildMethods(List<Subtype> topLevel) {
    return new ListBuilder(topLevel.map((Subtype s) => new Method((b) => b
      ..name = new ReCase(s.name).camelCase
      ..returns = _getDartType(s)
      ..annotations.add(new CodeExpression(
          new Code("BuiltValueField(wireName: '${s.name}')")))
      ..type = MethodType.getter)));
  }

  Reference _getDartType(Subtype subtype) {
    JsonType type = subtype.type;
    switch (type) {
      case JsonType.INT:
        return new Reference('int');
      case JsonType.DOUBLE:
        return new Reference('double');
      case JsonType.BOOL:
        return new Reference('bool');
      case JsonType.STRING:
        return new Reference('String');
      case JsonType.MAP:
        return new Reference('Map');
      case JsonType.LIST:
        return new Reference('List<${_getDartTypeFromJsonType(subtype)}>');
      default:
        return new Reference('dynamic');
    }
  }

  String _getDartTypeFromJsonType(Subtype subtype) {
    var type = subtype.listType;
    switch (type) {
      case JsonType.INT:
        return 'int';
      case JsonType.DOUBLE:
        return 'double';
      case JsonType.STRING:
        return 'String';
      case JsonType.MAP:
        return new ReCase(subtype.name).pascalCase;
      default:
        return 'dynamic';
    }
  }

  List<Subtype> _getTypedClassFields(decode) {
    List<Subtype> topLevelClass = [];
    var toDecode;

    if (decode is List) {
      toDecode = decode[0];
    } else {
      toDecode = decode;
    }

//  if (toDecode is Map) {
    toDecode.forEach((key, val) {
      topLevelClass.add(_returnType(key, val));
    });
//  }
    return topLevelClass;
  }

  Subtype _returnType(key, val) {
    if (val is String)
      return new Subtype(key, JsonType.STRING, val);
    else if (val is int)
      return new Subtype(key, JsonType.INT, val);
    else if (val is num)
      return new Subtype(key, JsonType.DOUBLE, val);
    else if (val is bool)
      return new Subtype(key, JsonType.BOOL, val);
    else if (val is List) {
      return new Subtype(key, JsonType.LIST, val,
          listType: _returnJsonType(val));
    } else if (val is Map) {
      return new Subtype(key, JsonType.MAP, val);
    } else
      throw new ArgumentError('Cannot resolve JSON-encodable type for $val.');
  }

  JsonType _returnJsonType(List list) {
    var item = list[0];
    print('got item $item');
    if (item is String)
      return JsonType.STRING;
    else if (item is int)
      return JsonType.INT;
    else if (item is num)
      return JsonType.DOUBLE;
    else if (item is bool)
      return JsonType.BOOL;
    else if (item is Map)
      return JsonType.MAP;
    else
      throw new ArgumentError('Cannot resolve JSON-encodable type for $item.');
  }
}
