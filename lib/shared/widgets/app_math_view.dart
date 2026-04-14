import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class AppMathView extends StatelessWidget {
  const AppMathView({
    super.key,
    required this.latex,
    this.textStyle,
    this.textAlign = TextAlign.start,
  });

  final String latex;
  final TextStyle? textStyle;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final value = latex.trim();

    if (value.isEmpty) {
      return Text(
        '-',
        style: textStyle,
        textAlign: textAlign,
      );
    }

    return Align(
      alignment: _mapAlignment(textAlign),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          value,
          textStyle: textStyle,
          onErrorFallback: (e) {
            return Text(
              value,
              style: textStyle,
              textAlign: textAlign,
            );
          },
        ),
      ),
    );
  }

  Alignment _mapAlignment(TextAlign align) {
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