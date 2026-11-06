import 'package:flutter/material.dart';

class QRInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const QRInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your content',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          onChanged: onChanged,
          minLines: 3,
          maxLines: 5,
          maxLength: 271,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            hintText: 'Enter a URL or any text...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 45),
              child: Icon(Icons.edit_note_rounded),
            ),
            suffixIcon: IconButton(
              onPressed: onClear,
              tooltip: 'Clear input',
              icon: const Icon(Icons.close_rounded),
            ),
            counterStyle: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your QR code updates automatically as you type.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
