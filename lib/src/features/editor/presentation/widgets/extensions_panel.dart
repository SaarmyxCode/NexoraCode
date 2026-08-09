import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class ExtensionsPanel extends StatelessWidget {
  const ExtensionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: NexoraColors.surface,
        border: Border(right: BorderSide(color: NexoraColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: NexoraColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.extension_outlined,
                  size: 16,
                  color: NexoraColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'EXTENSIONES',
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: TextStyle(color: NexoraColors.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Buscar extensión...',
                hintStyle: TextStyle(
                  color: NexoraColors.textMuted,
                  fontSize: 12,
                ),
                filled: true,
                fillColor: NexoraColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: NexoraColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: NexoraColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: NexoraColors.accent),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildExtensionItem(
                  'Nexora Theme',
                  'Tema oficial para Ncode',
                  'v1.0.0',
                  true,
                ),
                _buildExtensionItem(
                  'Dart & Flutter',
                  'Soporte de lenguaje para Dart',
                  'v3.2.0',
                  true,
                ),
                _buildExtensionItem(
                  'Rust Analyzer',
                  'Soporte LSP para Rust',
                  'v0.4.1',
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionItem(
    String name,
    String desc,
    String version,
    bool isInstalled,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: NexoraColors.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: NexoraColors.border),
            ),
            child: Icon(
              Icons.extension_rounded,
              size: 18,
              color: NexoraColors.accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(color: NexoraColors.textMuted, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            isInstalled
                ? Icons.check_circle_outline_rounded
                : Icons.download_rounded,
            size: 16,
            color: isInstalled ? Colors.green : NexoraColors.textMuted,
          ),
        ],
      ),
    );
  }
}
