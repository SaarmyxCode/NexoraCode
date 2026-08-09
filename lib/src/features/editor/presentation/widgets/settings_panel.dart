import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

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
                  Icons.settings_outlined,
                  size: 16,
                  color: NexoraColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'CONFIGURACIÓN',
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
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildSettingItem('Tema de color', 'Nexora Dark'),
                _buildSettingItem('Tipografía del editor', 'Cascadia Code'),
                _buildSettingItem('Tamaño de fuente', '13px'),
                _buildSettingItem('Formatear al guardar', 'Activado'),
                _buildSettingItem('Auto-completar pares', 'Activado'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: NexoraColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: NexoraColors.accent, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
