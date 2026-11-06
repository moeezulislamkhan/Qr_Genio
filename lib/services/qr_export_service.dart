import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/qr/qr_encoder.dart';
import '../core/constants/app_constants.dart';

class QRExportService {
  static Future<Uint8List> generatePng({
    required QRCodeResult qrCode,
    int imageSize = AppConstants.qrExportSize,
    int quietZone = AppConstants.qrQuietZone,
    Color foreground = Colors.black,
    Color background = Colors.white,
  }) async {
    if (imageSize < 128 || imageSize > 4096) {
      throw ArgumentError('Image size must be between 128 and 4096 pixels.');
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final totalModules = qrCode.size + quietZone * 2;
    final moduleSize = imageSize / totalModules;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, imageSize.toDouble(), imageSize.toDouble()),
      Paint()..color = background,
    );

    final paint = Paint()
      ..color = foreground
      ..isAntiAlias = false;

    for (var y = 0; y < qrCode.size; y++) {
      for (var x = 0; x < qrCode.size; x++) {
        if (!qrCode.matrix[y][x]) continue;
        final left = (x + quietZone) * moduleSize;
        final top = (y + quietZone) * moduleSize;
        canvas.drawRect(
          Rect.fromLTWH(left, top, moduleSize + 0.15, moduleSize + 0.15),
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(imageSize, imageSize);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();

    if (data == null) throw StateError('PNG encoding failed.');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
