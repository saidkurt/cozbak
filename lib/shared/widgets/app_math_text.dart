import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class AppMixedMathText extends StatelessWidget {
  const AppMixedMathText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final value = text.trim();

    if (value.isEmpty) {
      return Text(
        '',
        style: style,
        textAlign: textAlign,
      );
    }

    if (_isMostlyMath(value)) {
      return Align(
        alignment: _alignmentFromTextAlign(textAlign),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            value,
            textStyle: style,
            onErrorFallback: (e) {
              return Text(
                _normalizeLatexForText(value),
                style: style,
                textAlign: textAlign,
              );
            },
          ),
        ),
      );
    }

    return Text(
      _normalizeLatexForText(value),
      style: style,
      textAlign: textAlign,
    );
  }

  bool _isMostlyMath(String value) {
    final hasLatex = value.contains(r'\frac') ||
        value.contains(r'\sqrt') ||
        value.contains(r'\cdot') ||
        value.contains(r'\pi') ||
        value.contains(r'\tan') ||
        value.contains(r'\sin') ||
        value.contains(r'\cos') ||
        value.contains(r'\log') ||
        value.contains(r'\ln');

    final hasTurkishText = RegExp(
      r'(olduğ|bulunur|ise|için|buradan|yazılır|elde edilir|olur|göre|çünkü|dolayısıyla|burada)',
      caseSensitive: false,
    ).hasMatch(value);

    return hasLatex && !hasTurkishText;
  }

  String _normalizeLatexForText(String value) {
    return value
        .replaceAll(r'\cdot', '·')
        .replaceAll(r'\pi', 'π')
        .replaceAll(r'\tan', 'tan')
        .replaceAll(r'\sin', 'sin')
        .replaceAll(r'\cos', 'cos')
        .replaceAll(r'\log', 'log')
        .replaceAll(r'\ln', 'ln')
        .replaceAllMapped(
          RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'),
          (m) => '${m.group(1)}/${m.group(2)}',
        )
        .replaceAllMapped(
          RegExp(r'\\sqrt\{([^}]*)\}'),
          (m) => '√(${m.group(1)})',
        );
  }

  Alignment _alignmentFromTextAlign(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.end:
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.left:
      case TextAlign.start:
      case TextAlign.justify:
        return Alignment.centerLeft;
    }
  }
}