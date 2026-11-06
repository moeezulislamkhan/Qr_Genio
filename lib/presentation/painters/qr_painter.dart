import 'package:flutter/material.dart';

import '../../core/qr/qr_encoder.dart';

class QRPainter extends CustomPainter {
  final QRCodeResult qrCode;
  final Color foreground;
  final Color background;
  final int quietZone;

  QRPainter({
    required this.qrCode,
    this.foreground = Colors.black,
    this.background = Colors.white,
    this.quietZone = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = qrCode.size + quietZone * 2;
    final module = size.width / total;
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final paint = Paint()..color = foreground..isAntiAlias = false;

    for (var y = 0; y < qrCode.size; y++) {
      for (var x = 0; x < qrCode.size; x++) {
        if (!qrCode.matrix[y][x]) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            (x + quietZone) * module,
            (y + quietZone) * module,
            module + 0.1,
            module + 0.1,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant QRPainter oldDelegate) {
    return oldDelegate.qrCode != qrCode ||
        oldDelegate.foreground != foreground ||
        oldDelegate.background != background ||
        oldDelegate.quietZone != quietZone;
  }
}
