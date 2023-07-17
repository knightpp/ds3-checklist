library simple_rich_md;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class SimpleRichParser {
  final void Function(String url) onTap;
  List<TextSpan> _spans = [];
  List<TextSpan> get spans => _spans;

  SimpleRichParser(String text,
      {required this.onTap,
      TextStyle? linkStyle,
      TextStyle? boldStyle,
      TextStyle? textStyle}) {
    final c = text.characters;
    final chars = c.toList(growable: false);
    int startText = 0;

    @pragma("vm:prefer-inline")
    void _addText(Characters c, int startIndex, int endIndex) {
      _spans.add(TextSpan(
          text: c.getRange(startIndex, endIndex).string, style: textStyle));
    }

    for (int i = 0; i < chars.length; i++) {
      // parse markdown [link](://)
      if (chars[i] == "[") {
        if (startText < i) {
          _addText(c, startText, i);
        }
        final startLinkText = ++i;

        // advanceToClosingBracket
        {
          int seen = 1;
          const bracket = '[';
          const closing = ']';
          while (seen > 0) {
            if (chars[i] == bracket) {
              seen += 1;
            } else if (chars[i] == closing) {
              seen -= 1;
            }
            i += 1;
          }
        }

        final endLinkText = i - 1;
        final linkText = c.getRange(startLinkText, endLinkText);

        if (chars[i] != "(") {
          throw "expected '(' after '[]`";
        }
        final startUrl = ++i;
        // advanceToClosingBracket
        {
          int seen = 1;
          const bracket = '(';
          const closing = ')';
          while (seen > 0) {
            if (chars[i] == bracket) {
              seen += 1;
            } else if (chars[i] == closing) {
              seen -= 1;
            }
            i += 1;
          }
        }
        final endUrl = i - 1;
        final linkUrl = c.getRange(startUrl, endUrl);
        //print("LINK: [$linkText]($linkUrl)");
        _spans.add(TextSpan(
            text: linkText.string,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => onTap(linkUrl.string)));
        startText = i;
      }
      // parse markdown **bold**
      else if (chars[i] == "*" && chars[i + 1] == "*") {
        if (startText < i) {
          _addText(c, startText, i);
        }
        i += 2;
        final startBold = i;
        while (chars[i] != "*" && chars[i + 1] != "*") {
          i += 1;
        }
        final endBold = i + 1;
        _spans.add(TextSpan(
          text: c.getRange(startBold, endBold).string,
          style: boldStyle,
        ));
        i += 2;
        startText = i;
      }
    }
    if (startText + 1 < chars.length) {
      _addText(c, startText, chars.length);
    }
  }
}

class SimpleRichMd extends StatelessWidget {
  final String text;
  final void Function(String url) onTap;
  final TextStyle? linkStyle;
  final TextStyle? boldStyle;
  final TextStyle? textStyle;

  const SimpleRichMd(
      {Key? key,
      required this.text,
      required this.onTap,
      this.linkStyle,
      this.boldStyle,
      this.textStyle})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            children: SimpleRichParser(text,
                    onTap: onTap,
                    textStyle: textStyle,
                    boldStyle: boldStyle,
                    linkStyle: linkStyle)
                .spans));
  }
}
