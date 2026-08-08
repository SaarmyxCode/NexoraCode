import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class FastCodeController extends TextEditingController {
  Timer? _debounceTimer;
  final Duration debounceDuration;

  static final _keywordRegex = RegExp(
    r'\b(class|enum|struct|void|import|export|final|const|var|let|async|await|return|if|else|for|while|fn|pub|use|mut|self)\b',
  );
  static final _stringRegex = RegExp(
    r'(".*?"|'
    "'"
    r".*?'"
    ')',
  );
  static final _commentRegex = RegExp(r'(//.*|/\*[\s\S]*?\*/)');
  static final _numberRegex = RegExp(r'\b\d+\b');

  FastCodeController({
    super.text,
    this.debounceDuration = const Duration(milliseconds: 80),
  });

  static const Map<String, String> _pairMap = {
    '{': '}',
    '[': ']',
    '(': ')',
    '"': '"',
    "'": "'",
    '<': '>',
  };

  void handleAutoClosePairs(String typedChar) {
    if (!_pairMap.containsKey(typedChar)) return;

    final closePair = _pairMap[typedChar]!;
    final currentSelection = selection;

    if (!currentSelection.isValid) return;

    final start = currentSelection.start;
    final end = currentSelection.end;
    final currentText = text;

    if (start != end) {
      final selectedText = currentText.substring(start, end);
      final newText = currentText.replaceRange(
        start,
        end,
        '$typedChar$selectedText$closePair',
      );
      value = TextEditingValue(
        text: newText,
        selection: TextSelection(baseOffset: start + 1, extentOffset: end + 1),
      );
    } else {
      final newText = currentText.replaceRange(
        start,
        end,
        '$typedChar$closePair',
      );
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + 1),
      );
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final textContent = text;
    if (textContent.isEmpty) return TextSpan(style: style);

    if (textContent.length > 15000) {
      return TextSpan(text: textContent, style: style);
    }

    final List<TextSpan> children = [];

    textContent.splitMapJoin(
      RegExp(
        '${_commentRegex.pattern}|${_stringRegex.pattern}|${_keywordRegex.pattern}|${_numberRegex.pattern}',
      ),
      onMatch: (Match match) {
        final matchedText = match[0]!;
        TextStyle matchStyle = TextStyle(color: NexoraColors.textPrimary);

        if (_commentRegex.hasMatch(matchedText)) {
          matchStyle = TextStyle(
            color: NexoraColors.textMuted,
            fontStyle: FontStyle.italic,
          );
        } else if (_stringRegex.hasMatch(matchedText)) {
          matchStyle = const TextStyle(color: Color(0xFFE6DB74));
        } else if (_keywordRegex.hasMatch(matchedText)) {
          matchStyle = const TextStyle(
            color: Color(0xFFF92672),
            fontWeight: FontWeight.bold,
          );
        } else if (_numberRegex.hasMatch(matchedText)) {
          matchStyle = const TextStyle(color: Color(0xFFAE81FF));
        }

        children.add(TextSpan(text: matchedText, style: matchStyle));
        return '';
      },
      onNonMatch: (String nonMatch) {
        children.add(TextSpan(text: nonMatch, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }

  void onTextChangedDebounced(VoidCallback onChange) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(debounceDuration, onChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
