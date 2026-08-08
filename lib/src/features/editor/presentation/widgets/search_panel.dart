import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class SearchPanel extends StatelessWidget {
  const SearchPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: NexoraColors.surface,
        border: Border(right: BorderSide(color: NexoraColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: NexoraColors.border, width: 1),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: NexoraColors.accent,
                ),
                SizedBox(width: 8),
                Text(
                  'BUSCAR',
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
              style: const TextStyle(
                color: NexoraColors.textPrimary,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar en el proyecto...',
                hintStyle: const TextStyle(
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
                  borderSide: const BorderSide(color: NexoraColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: NexoraColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: NexoraColors.accent),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Sin resultados',
                style: TextStyle(color: NexoraColors.textMuted, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
