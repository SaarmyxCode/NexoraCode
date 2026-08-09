import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class AccountPanel extends StatelessWidget {
  const AccountPanel({super.key});

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
                  Icons.person_outline_rounded,
                  size: 16,
                  color: NexoraColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'CUENTA',
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: NexoraColors.accent,
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: NexoraColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Santiago Sarmiento',
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'saarmyx',
                  style: TextStyle(color: NexoraColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 16),
                Divider(color: NexoraColors.border),
                const SizedBox(height: 8),
                _buildAccountOption(
                  Icons.sync_rounded,
                  'Sincronización activada',
                ),
                _buildAccountOption(Icons.security_rounded, 'Nexora Auth'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: NexoraColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: NexoraColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
