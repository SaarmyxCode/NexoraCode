import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/rust/frb_generated.dart';
import 'package:ncode/src/features/editor/screens/editor_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const ProviderScope(child: NcodeApp()));
}

class NcodeApp extends StatelessWidget {
  const NcodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ncode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: NexoraColors.background,
        colorScheme: ColorScheme.dark(
          surface: NexoraColors.surface,
          primary: NexoraColors.accent,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
      ),
      home: const NcodeEditorScreen(),
    );
  }
}
