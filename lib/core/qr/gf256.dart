class GF256 {
  static const int primitive = 0x11D;
  static final List<int> exp = List<int>.filled(512, 0);
  static final List<int> log = List<int>.filled(256, 0);
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    var x = 1;
    for (var i = 0; i < 255; i++) {
      exp[i] = x;
      log[x] = i;
      x <<= 1;
      if ((x & 0x100) != 0) x ^= primitive;
    }
    for (var i = 255; i < 512; i++) {
      exp[i] = exp[i - 255];
    }
    _initialized = true;
  }

  static int multiply(int a, int b) {
    initialize();
    if (a == 0 || b == 0) return 0;
    return exp[log[a] + log[b]];
  }

  static int divide(int a, int b) {
    initialize();
    if (b == 0) throw ArgumentError('Division by zero in GF(256)');
    if (a == 0) return 0;
    var index = log[a] - log[b];
    if (index < 0) index += 255;
    return exp[index];
  }

  static int power(int exponent) {
    initialize();
    return exp[exponent % 255];
  }
}
