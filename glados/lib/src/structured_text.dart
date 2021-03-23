abstract class StructuredText {
  Iterable<String> toLines(int width);

  @override
  String toString() => toLines(60).join('\n');
}

class Text extends StructuredText {
  Text(this.text);

  final String text;

  @override
  Iterable<String> toLines(int width) sync* {
    final words = text.split(' ');
    var line = StringBuffer();

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (line.length + (i == 0 ? 0 : 1) + word.length <= width) {
        if (i > 0) line.write(' ');
        line.write(word);
      } else {
        yield line.toString();
        line = StringBuffer(word);
      }
    }
    if (line.toString().trim().isNotEmpty) {
      yield line.toString();
    }
  }
}

class Paragraph extends StructuredText {
  Paragraph._(this.text, this.addNewline);
  Paragraph([String text = '']) : this._(text, true);
  Paragraph.noNl(String text) : this._(text, false);

  final String text;
  final bool addNewline;

  @override
  Iterable<String> toLines(int width) sync* {
    yield* Text(text).toLines(width);
    if (addNewline) yield '';
  }
}

class BulletList extends StructuredText {
  BulletList(this.items);

  final List<StructuredText> items;

  @override
  Iterable<String> toLines(int width) sync* {
    for (final item in items) {
      var isFirstLine = true;
      yield* item.toLines(width - 2).map((line) {
        var isFirst = isFirstLine;
        isFirstLine = false;
        return isFirst ? '* $line' : '  $line';
      });
    }
  }
}

class NumberedList extends StructuredText {
  NumberedList(this.items);

  final List<StructuredText> items;

  @override
  Iterable<String> toLines(int width) sync* {
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      var isFirstLine = true;
      yield* item.toLines(width - 4).map((line) {
        final prefix = isFirstLine ? '${(i + 1)}.' : '';
        isFirstLine = false;
        return '${prefix.padRight(4)}$line';
      });
    }
  }
}

class Flow extends StructuredText {
  Flow(this.texts);

  final List<StructuredText> texts;

  @override
  Iterable<String> toLines(int width) sync* {
    yield* texts.expand((text) => text.toLines(width));
  }
}

class Code extends StructuredText {
  Code(this.code);

  final List<String> code;

  @override
  Iterable<String> toLines(int width) sync* {
    yield* code;
    yield '';
  }
}
