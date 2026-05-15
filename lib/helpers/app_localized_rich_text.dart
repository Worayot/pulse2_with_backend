import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppLocalizedRichText extends StatelessWidget {
  final String translationKey;
  final Map<String, String>? namedArgs;
  final TextStyle? style;
  final TextStyle? boldStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppLocalizedRichText({super.key, required this.translationKey, this.namedArgs, this.style, this.boldStyle, this.textAlign, this.maxLines, this.overflow});

  @override
  Widget build(BuildContext context) {
    final translatedText = tr(translationKey, namedArgs: namedArgs);

    final defaultStyle = style ?? DefaultTextStyle.of(context).style;

    return Text.rich(
      _buildTextSpan(translatedText, normalStyle: defaultStyle, boldStyle: boldStyle ?? defaultStyle.copyWith(fontWeight: FontWeight.bold)),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextSpan _buildTextSpan(String text, {required TextStyle normalStyle, required TextStyle boldStyle}) {
    final regex = RegExp(r'<b>(.*?)<\/b>', dotAll: true);

    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Normal text before bold
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start), style: normalStyle));
      }

      // Bold text
      spans.add(TextSpan(text: match.group(1), style: boldStyle));

      currentIndex = match.end;
    }

    // Remaining normal text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: normalStyle));
    }

    return TextSpan(children: spans);
  }
}
