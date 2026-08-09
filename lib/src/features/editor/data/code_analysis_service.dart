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
  static String detectLanguage(String? filePath) {
    if (filePath == null || filePath.isEmpty) return 'Plain Text';

    final pathLower = filePath.toLowerCase();
    if (pathLower.endsWith('.dart')) return 'Dart';
    if (pathLower.endsWith('.rs')) return 'Rust';
    if (pathLower.endsWith('.js') || pathLower.endsWith('.jsx')) {
      return 'JavaScript';
    }
    if (pathLower.endsWith('.ts') || pathLower.endsWith('.tsx')) {
      return 'TypeScript';
    }
    if (pathLower.endsWith('.py')) return 'Python';
    if (pathLower.endsWith('.json')) return 'JSON';
    if (pathLower.endsWith('.html') || pathLower.endsWith('.htm')) {
      return 'HTML';
    }
    if (pathLower.endsWith('.css')) return 'CSS';

    return 'Plain Text';
  }

  static List<CodeDiagnostic> analyzeCode(String content, String language) {
    final List<CodeDiagnostic> diagnostics = [];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final lineText = lines[i];

      if (language == 'Dart' ||
          language == 'JavaScript' ||
          language == 'Rust' ||
          language == 'TypeScript') {
        if (lineText.contains('var ') && language == 'Dart') {
          diagnostics.add(
            CodeDiagnostic(
              line: i + 1,
              message: 'Sugerencia: Se recomienda usar "final" o "const".',
              type: DiagnosticType.info,
            ),
          );
        }
      } else if (language == 'JSON') {
        if (lineText.trim().endsWith(',') && i == lines.length - 1) {
          diagnostics.add(
            CodeDiagnostic(
              line: i + 1,
              message: 'Error JSON: Coma al final del objeto.',
              type: DiagnosticType.error,
            ),
          );
        }
      }
    }

    return diagnostics;
  }

  static String formatCode(String content, String language) {
    final lines = content.split('\n');
    final StringBuffer formatted = StringBuffer();
    int indentLevel = 0;

    for (int i = 0; i < lines.length; i++) {
      String trimmed = lines[i].trim();

      if (trimmed.isEmpty) {
        if (i < lines.length - 1) formatted.writeln();
        continue;
      }

      // Reducir sangría si la línea cierra un bloque
      if (trimmed.startsWith('}') ||
          trimmed.startsWith(']') ||
          trimmed.startsWith(')')) {
        indentLevel = (indentLevel - 1).clamp(0, 50);
      }

      final String indent = '  ' * indentLevel;
      formatted.write(indent + trimmed);
      if (i < lines.length - 1) formatted.writeln();

      // Aumentar sangría si la línea abre un bloque
      if (trimmed.endsWith('{') ||
          trimmed.endsWith('[') ||
          trimmed.endsWith('(') ||
          trimmed.endsWith(':')) {
        indentLevel++;
      }
    }

    return formatted.toString();
  }
}
