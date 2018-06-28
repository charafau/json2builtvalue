class Root {
  final String title;

  final Map<String, Subtype> jsonTree;

  Root(this.title, this.jsonTree);

  @override
  String toString() {
    return 'Root{title: $title, jsonTree: $jsonTree}';
  }
}

class Subtype {
  final String name;
  final JsonType type;
  final JsonType listType;
  final dynamic value;

  Subtype(this.name, this.type, this.value, {this.listType});

  @override
  String toString() {
    return 'Subtype{name: $name, type: $type, listType: $listType, value: $value}';
  }
}

enum JsonType { INT, DOUBLE, BOOL, STRING, MAP, LIST }
