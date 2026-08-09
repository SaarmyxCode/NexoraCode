import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ncode/src/core/theme/theme_provider.dart';

class NexoraFloatingCard extends ConsumerWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const NexoraFloatingCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.margin = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(activePaletteProvider);

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(11), child: child),
    );
  }
}
