import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class DebugPanel extends StatelessWidget {
  const DebugPanel({super.key});

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
                  Icons.bug_report_outlined,
                  size: 16,
                  color: NexoraColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'EJECUTAR Y DEPURAR',
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexoraColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.play_arrow_rounded,
                  size: 16,
                  color: NexoraColors.textPrimary,
                ),
                label: Text(
                  'Iniciar Depuración',
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: NexoraColors.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VARIABLES',
                    style: TextStyle(
                      color: NexoraColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sin variables activas',
                    style: TextStyle(
                      color: NexoraColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PUNTOS DE INTERRUPCIÓN',
                    style: TextStyle(
                      color: NexoraColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No se han fijado breakpoints',
                    style: TextStyle(
                      color: NexoraColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
