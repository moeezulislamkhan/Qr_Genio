import 'qr_version.dart';

class QRMatrix {
  final QRVersion version;
  final int size;
  late final List<List<bool>> modules;
  late final List<List<bool>> reserved;

  QRMatrix(this.version) : size = version.moduleCount {
    modules = List.generate(size, (_) => List<bool>.filled(size, false));
    reserved = List.generate(size, (_) => List<bool>.filled(size, false));
  }

  void _set(int x, int y, bool value) {
    if (x < 0 || y < 0 || x >= size || y >= size) return;
    modules[y][x] = value;
    reserved[y][x] = true;
  }

  void _finder(int x, int y) {
    for (var dy = -1; dy <= 7; dy++) {
      for (var dx = -1; dx <= 7; dx++) {
        final xx = x + dx, yy = y + dy;
        final inside = dx >= 0 && dx <= 6 && dy >= 0 && dy <= 6;
        final dark = inside && (dx == 0 || dx == 6 || dy == 0 || dy == 6 ||
            (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4));
        _set(xx, yy, dark);
      }
    }
  }

  void _alignment(int cx, int cy) {
    for (var dy = -2; dy <= 2; dy++) {
      for (var dx = -2; dx <= 2; dx++) {
        final distance = dx.abs() > dy.abs() ? dx.abs() : dy.abs();
        _set(cx + dx, cy + dy, distance != 1);
      }
    }
  }

  void _timing() {
    for (var i = 8; i < size - 8; i++) {
      _set(i, 6, i.isEven);
      _set(6, i, i.isEven);
    }
  }

  void _alignmentPatterns() {
    for (final cy in QRVersion.alignmentCenters[version.version]!) {
      for (final cx in QRVersion.alignmentCenters[version.version]!) {
        if (reserved[cy][cx]) continue;
        _alignment(cx, cy);
      }
    }
  }

  void _formatInformation(int mask) {
    // Format data: ECC level L = 01, followed by the mask index.
    final data = (1 << 3) | mask;
    var remainder = data;
    for (var i = 0; i < 10; i++) {
      remainder = (remainder << 1) ^ (((remainder >> 9) & 1) * 0x537);
    }
    final bits = ((data << 10) | remainder) ^ 0x5412;

    for (var i = 0; i < 15; i++) {
      final bit = ((bits >> i) & 1) != 0;
      if (i < 6) {
        _set(8, i, bit);
      } else if (i < 8) {
        _set(8, i + 1, bit);
      } else {
        _set(14 - i, 8, bit);
      }

      if (i < 8) {
        _set(size - 1 - i, 8, bit);
      } else {
        _set(8, size - 15 + i, bit);
      }
    }
    _set(8, size - 8, true);
  }

  void _versionInformation() {
    if (version.version < 7) return;
    var remainder = version.version;
    for (var i = 0; i < 12; i++) {
      remainder = (remainder << 1) ^ (((remainder >> 11) & 1) * 0x1F25);
    }
    final bits = (version.version << 12) | remainder;
    for (var i = 0; i < 18; i++) {
      final bit = ((bits >> i) & 1) != 0;
      final a = size - 11 + (i % 3);
      final b = i ~/ 3;
      _set(a, b, bit);
      _set(b, a, bit);
    }
  }

  void initializePatterns() {
    _finder(0, 0);
    _finder(size - 7, 0);
    _finder(0, size - 7);
    _timing();
    _alignmentPatterns();
    _formatInformation(0);
    _versionInformation();
  }

  bool _mask(int pattern, int x, int y) {
    switch (pattern) {
      case 0: return (x + y).isEven;
      case 1: return y.isEven;
      case 2: return x % 3 == 0;
      case 3: return (x + y) % 3 == 0;
      case 4: return (y ~/ 2 + x ~/ 3).isEven;
      case 5: return (x * y) % 2 + (x * y) % 3 == 0;
      case 6: return ((x * y) % 2 + (x * y) % 3).isEven;
      case 7: return ((x + y) % 2 + (x * y) % 3).isEven;
      default: return false;
    }
  }

  void placeData(List<int> codewords, int mask) {
    final bits = <int>[];
    for (final byte in codewords) {
      for (var i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1);
      }
    }

    var bitIndex = 0;
    var upward = true;
    for (var right = size - 1; right >= 1; right -= 2) {
      if (right == 6) right--;
      for (var vertical = 0; vertical < size; vertical++) {
        final y = upward ? size - 1 - vertical : vertical;
        for (var j = 0; j < 2; j++) {
          final x = right - j;
          if (reserved[y][x]) continue;
          final bit = bitIndex < bits.length ? bits[bitIndex++] : 0;
          modules[y][x] = (bit == 1) ^ _mask(mask, x, y);
        }
      }
      upward = !upward;
    }
    _formatInformation(mask);
  }

  int penaltyScore() {
    var penalty = 0;

    void scoreLine(List<bool> line) {
      var run = 1;
      for (var i = 1; i < line.length; i++) {
        if (line[i] == line[i - 1]) {
          run++;
        } else {
          if (run >= 5) penalty += 3 + run - 5;
          run = 1;
        }
      }
      if (run >= 5) penalty += 3 + run - 5;

      const p1 = [true, false, true, true, true, false, true, false, false, false, false];
      const p2 = [false, false, false, false, true, false, true, true, true, false, true];
      for (var i = 0; i <= line.length - 11; i++) {
        var a = true, b = true;
        for (var j = 0; j < 11; j++) {
          a = a && line[i + j] == p1[j];
          b = b && line[i + j] == p2[j];
        }
        if (a || b) penalty += 40;
      }
    }

    for (var y = 0; y < size; y++) {
      scoreLine(modules[y]);
    }
    for (var x = 0; x < size; x++) {
      scoreLine(List.generate(size, (y) => modules[y][x]));
    }

    for (var y = 0; y < size - 1; y++) {
      for (var x = 0; x < size - 1; x++) {
        final value = modules[y][x];
        if (modules[y][x + 1] == value &&
            modules[y + 1][x] == value &&
            modules[y + 1][x + 1] == value) {
          penalty += 3;
        }
      }
    }

    var dark = 0;
    for (final row in modules) {
      for (final cell in row) {
        if (cell) dark++;
      }
    }
    final percent = dark * 100 / (size * size);
    penalty += ((percent - 50).abs() / 5).floor() * 10;
    return penalty;
  }

  List<List<bool>> get result => modules;
}
