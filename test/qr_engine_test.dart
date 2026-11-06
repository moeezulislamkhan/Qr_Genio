import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:qr_genio/core/qr/bit_buffer.dart';
import 'package:qr_genio/core/qr/gf256.dart';
import 'package:qr_genio/core/qr/qr_encoder.dart';
import 'package:qr_genio/core/qr/reed_solomon.dart';

void main() {
  group('BitBuffer', () {
    test('encodes bits into bytes', () {
      final buffer = BitBuffer();
      buffer.put(10, 4);
      buffer.put(12, 4);
      expect(buffer.toBytes(), [0xAC]);
    });
  });

  group('GF256', () {
    test('multiplication and division are consistent', () {
      final product = GF256.multiply(25, 12);
      expect(GF256.divide(product, 12), 25);
      expect(GF256.multiply(0, 5), 0);
    });
  });

  group('ReedSolomon', () {
    test('generates requested number of ECC bytes', () {
      final ecc = ReedSolomon.encode([32, 91, 11, 120, 209, 114], 7);
      expect(ecc.length, 7);
    });
  });

  group('QREncoder', () {
    test('uses medium error correction', () {
      expect(QREncoder.errorCorrectionLevel, QrErrorCorrectLevel.medium);
    });

    test('generates a matrix for short text', () {
      final result = QREncoder.encode('HELLO');
      expect(result.version, 1);
      expect(result.size, 21);
      expect(result.matrix.length, 21);
      expect(result.matrix.every((row) => row.length == 21), isTrue);
    });

    test('supports UTF-8 input', () {
      final result = QREncoder.encode('Hello Pakistan');
      expect(result.matrix.length, result.size);
    });

    test('rejects empty input', () {
      expect(() => QREncoder.encode(''), throwsArgumentError);
    });

    test('rejects oversized input', () {
      expect(() => QREncoder.encode('A' * 1000), throwsArgumentError);
    });
  });
}
