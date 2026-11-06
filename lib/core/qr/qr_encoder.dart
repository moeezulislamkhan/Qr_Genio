import 'package:qr/qr.dart';

class QRCodeResult {
  final List<List<bool>> matrix;
  final int version;
  final int size;

  const QRCodeResult({
    required this.matrix,
    required this.version,
    required this.size,
  });
}

class QREncoder {
  static const errorCorrectionLevel = QrErrorCorrectLevel.medium;

  static QRCodeResult encode(String input) {
    if (input.isEmpty) throw ArgumentError('Input cannot be empty');

    final payload = QrPayload()
      ..addECI(QrEciValue.utf8)
      ..addString(input);
    final code = QrCode(
      payload: payload,
      errorCorrectLevel: errorCorrectionLevel,
    );
    if (code.typeNumber > 10) {
      throw ArgumentError('Input is too long for QR Version 10-M.');
    }

    final image = QrImage(code);
    final matrix = List.generate(
      image.moduleCount,
      (row) => List.generate(
        image.moduleCount,
        (column) => image.isDark(row, column),
      ),
    );

    return QRCodeResult(
      matrix: matrix,
      version: image.typeNumber,
      size: image.moduleCount,
    );
  }
}
