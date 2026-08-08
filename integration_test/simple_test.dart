import 'package:flutter_test/flutter_test.dart';
import 'package:ncode/main.dart';
import 'package:ncode/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ncode/main.dart'; // Sustituye "tu_proyecto" por el nombre definido en pubspec.yaml

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  testWidgets('Can call rust function', (WidgetTester tester) async {
    await tester.pumpWidget(const ncode());
    expect(find.textContaining('Result: `Hello, Tom!`'), findsOneWidget);
  });
}
