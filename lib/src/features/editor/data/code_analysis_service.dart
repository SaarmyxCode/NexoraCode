import 'dart:async';
import 'package:ncode/src/features/editor/data/file_service.dart';

class CodeDiagnostic {
  final int line;
  final String message;
  final DiagnosticType type;

  CodeDiagnostic({
    required this.line,
    required this.message,
    required this.type,
  });
}

enum DiagnosticType { error, warning, info }

class CodeAnalysisService {
  // Detector automático de lenguaje según la extensión
  static String detectLanguage(String? filePath) {
    if (filePath == null) return 'Plain Text';
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'dart':
        return 'Dart';
      case 'rs':
        return 'Rust';
      case 'js':
      case 'jsx':
        return 'JavaScript';
      case 'ts':
      case 'tsx':
        return 'TypeScript';
      case 'py':
        return 'Python';
      case 'json':
        return 'JSON';
      case 'html':
        return 'HTML';
      case 'css':
        return 'CSS';
      default:
        return 'Plain Text';
    }
  }

  // Analizador ligero de sintaxis y recomendaciones
  static List<CodeDiagnostic> analyzeCode(String content, String language) {
    final List<CodeDiagnostic> diagnostics = [];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final lineText = lines[i];

      // Verificaciones sintácticas básicas rápidas
      if (language == 'Dart' ||
          language == 'JavaScript' ||
          language == 'Rust') {
        if (lineText.contains('var ') && language == 'Dart') {
          diagnostics.add(
            CodeDiagnostic(
              line: i + 1,
              message:
                  'Recomendación: Usa "final" o "const" en lugar de "var" para tipos inmutables.',
              type: DiagnosticType.info,
            ),
          );
        }
        if ((lineText.contains('{') && !lineText.contains('}')) &&
            i == lines.length - 1) {
          diagnostics.add(
            CodeDiagnostic(
              line: i + 1,
              message: 'Error de sintaxis: Llave "{" no cerrada.',
              type: DiagnosticType.error,
            ),
          );
        }
      } else if (language == 'JSON') {
        if (lineText.trim().endsWith(',') && i == lines.length - 1) {
          diagnostics.add(
            CodeDiagnostic(
              line: i + 1,
              message: 'Error JSON: Coma sobrante al final del objeto.',
              type: DiagnosticType.error,
            ),
          );
        }
      }
    }

    return diagnostics;
  }

  // Formateador de código
  static String formatCode(String content, String language) {
    final lines = content.split('\n');
    final StringBuffer formatted = StringBuffer();
    int indentLevel = 0;

    for (var line in lines) {
      var trimmed = line.trim();
      if (trimmed.isEmpty) {
        formatted.writeln();
        continue;
      }

      if (trimmed.startsWith('}') || trimmed.startsWith(']')) {
        indentLevel = (indentLevel - 1).clamp(0, 50);
      }

      final indent = '  ' * indentLevel;
      formatted.writeln('$indent$trimmed');

      if (trimmed.endsWith('{') || trimmed.endsWith('[')) {
        indentLevel++;
      }
    }

    return formatted.toString().trimRight();
  }
}
