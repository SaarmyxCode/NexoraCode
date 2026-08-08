import 'package:flutter/material.dart';
import 'package:nexora_ui/nexora_ui.dart';
import 'package:ncode/src/rust/api/terminal.dart';

class EmbeddedTerminal extends StatefulWidget {
  final VoidCallback onClose;

  const EmbeddedTerminal({super.key, required this.onClose});

  @override
  State<EmbeddedTerminal> createState() => _EmbeddedTerminalState();
}

class _EmbeddedTerminalState extends State<EmbeddedTerminal> {
  final TextEditingController _cmdController = TextEditingController();
  final List<String> _logs = ['Ncode Terminal v0.1.0 - Linux Shell Ready', ''];
  final ScrollController _scrollController = ScrollController();

  void _runCommand() async {
    final cmd = _cmdController.text.trim();
    if (cmd.isEmpty) return;

    setState(() {
      _logs.add('saarmyx@ncode:~\$ $cmd');
      _cmdController.clear();
    });

    final output = await executeCommand(cmd: cmd);

    setState(() {
      _logs.add(output);
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: NexoraColors.background,
        border: Border(top: BorderSide(color: NexoraColors.border, width: 1)),
      ),
      child: Column(
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: NexoraColors.surface,
            child: Row(
              children: [
                Icon(
                  Icons.terminal_rounded,
                  size: 14,
                  color: NexoraColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'TERMINAL',
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: widget.onClose,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: NexoraColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Text(
                  _logs[index],
                  style: TextStyle(
                    color: NexoraColors.textPrimary,
                    fontFamily: 'Cascadia Code',
                    fontSize: 12,
                    height: 1.3,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: NexoraColors.surface,
            child: Row(
              children: [
                Text(
                  '>\$ ',
                  style: TextStyle(
                    color: NexoraColors.accent,
                    fontFamily: 'Cascadia Code',
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _cmdController,
                    style: TextStyle(
                      color: NexoraColors.textPrimary,
                      fontFamily: 'Cascadia Code',
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _runCommand(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
