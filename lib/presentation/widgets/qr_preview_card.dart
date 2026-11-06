import 'package:flutter/material.dart';

import '../../core/qr/qr_encoder.dart';
import '../painters/qr_painter.dart';

class QRPreviewCard extends StatelessWidget {
  final QRCodeResult? qrCode;

  const QRPreviewCard({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Text('QR Preview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            const SizedBox(height: 26),
            LayoutBuilder(
              builder: (context, constraints) {
                final qrSize = constraints.maxWidth >= 298
                    ? 250.0
                    : constraints.maxWidth - 48;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: qrCode == null
                      ? Container(
                          key: const ValueKey('empty'),
                          width: qrSize + 48,
                          height: qrSize + 48,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                                size: 65,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              const Text('QR appears here'),
                            ],
                          ),
                        )
                      : Container(
                          key: ValueKey('${qrCode!.version}_${qrCode!.size}'),
                          width: qrSize + 48,
                          height: qrSize + 48,
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: CustomPaint(
                            size: Size(qrSize, qrSize),
                            painter: QRPainter(
                              qrCode: qrCode!,
                              foreground: Colors.black,
                              background: Colors.white,
                              quietZone: 4,
                            ),
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: 22),
            if (qrCode != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'VERSION ${qrCode!.version}  •  ${qrCode!.size} × ${qrCode!.size}  •  M',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text('Enter content to generate your QR code.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
