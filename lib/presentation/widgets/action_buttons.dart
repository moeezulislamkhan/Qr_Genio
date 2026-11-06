import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onExport;
  final VoidCallback onReset;
  final bool enabled;
  final bool exporting;

  const ActionButtons({
    super.key,
    required this.onCopy,
    required this.onExport,
    required this.onReset,
    required this.enabled,
    required this.exporting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: enabled ? onCopy : null,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: enabled && !exporting ? onExport : null,
                icon: exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(exporting ? 'Exporting...' : 'Export PNG'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset'),
          ),
        ),
      ],
    );
  }
}
