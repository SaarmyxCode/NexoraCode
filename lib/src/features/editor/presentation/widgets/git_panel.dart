import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class GitPanel extends StatelessWidget {
  const GitPanel({super.key});

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
                  Icons.alt_route_rounded,
                  size: 16,
                  color: NexoraColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'CONTROL DE VERSIONES',
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
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alt_route_rounded,
                    size: 32,
                    color: NexoraColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Repositorio Limpio',
                    style: TextStyle(
                      color: NexoraColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sin cambios pendientes',
                    style: TextStyle(
                      color: NexoraColors.textMuted,
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
