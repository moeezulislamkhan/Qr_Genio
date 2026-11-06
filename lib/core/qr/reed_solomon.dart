import 'gf256.dart';

class ReedSolomon {
  static List<int> _multiplyPolynomials(List<int> a, List<int> b) {
    final result = List<int>.filled(a.length + b.length - 1, 0);
    for (var i = 0; i < a.length; i++) {
      for (var j = 0; j < b.length; j++) {
        result[i + j] ^= GF256.multiply(a[i], b[j]);
      }
    }
    return result;
  }

  static List<int> _generatorPolynomial(int degree) {
    var polynomial = <int>[1];
    for (var i = 0; i < degree; i++) {
      polynomial = _multiplyPolynomials(polynomial, [1, GF256.power(i)]);
    }
    return polynomial;
  }

  static List<int> encode(List<int> data, int eccLength) {
    if (eccLength <= 0) throw ArgumentError('Invalid ECC length');
    final generator = _generatorPolynomial(eccLength);
    final message = [...data, ...List<int>.filled(eccLength, 0)];

    for (var i = 0; i < data.length; i++) {
      final coefficient = message[i];
      if (coefficient == 0) continue;
      for (var j = 0; j < generator.length; j++) {
        message[i + j] ^= GF256.multiply(generator[j], coefficient);
      }
    }
    return message.sublist(data.length);
  }
}
