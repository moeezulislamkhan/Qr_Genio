class BitBuffer {
  final List<int> _bits = [];

  int get length => _bits.length;

  void put(int value, int bitLength) {
    if (bitLength < 0 || bitLength > 31) {
      throw ArgumentError('Invalid bit length');
    }
    if (value < 0 || (bitLength == 0 ? value != 0 : value >= (1 << bitLength))) {
      throw ArgumentError('Value does not fit in bit length');
    }
    for (var i = bitLength - 1; i >= 0; i--) {
      _bits.add((value >> i) & 1);
    }
  }

  int getBit(int index) => _bits[index];

  List<int> toBytes() {
    final result = <int>[];
    for (var i = 0; i < _bits.length; i += 8) {
      var value = 0;
      for (var j = 0; j < 8; j++) {
        value <<= 1;
        if (i + j < _bits.length) value |= _bits[i + j];
      }
      result.add(value);
    }
    return result;
  }
}
