import 'utils.dart';

/// While you shouldn't rely on [Type.toString()] to return something useful, we
/// depend on it _only_ for better developer experience.
class RichType {
  factory RichType.fromType(Type type) => RichType.fromString(type.toString());
  factory RichType.fromString(String string) {
    final parser = _TypeParser(string.replaceAll(' ', ''));
    final type = parser.parse();
    return parser.cursor == parser.string.length ? type : null;
  }
  RichType(this.name, [this.children = const []])
      : assert(name != null),
        assert(name.isNotEmpty);

  final String name;
  final List<RichType> children;

  bool get hasGenerics => children.isNotEmpty;
  Set<String> allTypes() =>
      {name, ...children.expand((child) => child.allTypes())};

  @override
  bool operator ==(Object other) =>
      other is RichType &&
      name == other.name &&
      children.length == other.children.length &&
      [
        for (var i = 0; i < children.length; i++)
          children[i] == other.children[i],
      ].every((it) => it);
  @override
  int get hashCode =>
      name.hashCode +
      children.map((child) => child.hashCode).fold(0, (a, b) => a + b);

  @override
  String toString() {
    final buffer = StringBuffer(name);
    if (children.isNotEmpty) {
      buffer.write('<${children.join(', ')}>');
    }
    return buffer.toString();
  }

  String toGeneratorString() {
    final string = StringBuffer('any.${name.toLowerCamelCase()}');
    if (children.isNotEmpty) {
      string
        ..write('(')
        ..write(children.map((child) => child.toGeneratorString()).join(', '))
        ..write(')');
    }
    return string.toString();
  }
}

class _TypeParser {
  _TypeParser(this.string);

  final String string;
  int cursor = 0;

  String get current => cursor < string.length ? string[cursor] : '';
  void advance() => cursor++;
  bool get isDone => cursor == string.length;

  RichType parse() {
    var name = StringBuffer();
    var types = <RichType>[];
    while (!['<', '>', ',', ''].contains(current)) {
      name.write(current);
      advance();
    }
    if (name.isEmpty) return null;
    if (current == '>' || current == ',') {
      return RichType(name.toString());
    }
    if (current == '<') {
      while (current == '<' || current == ',') {
        advance();
        types.add(parse());
      }
      if (current != '>') return null;
      advance();
    }
    return RichType(name.toString(), types);
  }
}
