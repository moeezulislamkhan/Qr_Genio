class QRVersion {
  final int version;
  final int totalCodewords;
  final List<int> blockDataLengths;
  final List<int> blockTotalLengths;

  const QRVersion({
    required this.version,
    required this.totalCodewords,
    required this.blockDataLengths,
    required this.blockTotalLengths,
  });

  int get dataCodewords => blockDataLengths.fold(0, (a, b) => a + b);
  int get moduleCount => 17 + version * 4;

  static const List<QRVersion> supported = [
    QRVersion(version: 1, totalCodewords: 26, blockDataLengths: [19], blockTotalLengths: [26]),
    QRVersion(version: 2, totalCodewords: 44, blockDataLengths: [34], blockTotalLengths: [44]),
    QRVersion(version: 3, totalCodewords: 70, blockDataLengths: [55], blockTotalLengths: [70]),
    QRVersion(version: 4, totalCodewords: 100, blockDataLengths: [80], blockTotalLengths: [100]),
    QRVersion(version: 5, totalCodewords: 134, blockDataLengths: [108], blockTotalLengths: [134]),
    QRVersion(version: 6, totalCodewords: 172, blockDataLengths: [68, 68], blockTotalLengths: [86, 86]),
    QRVersion(version: 7, totalCodewords: 196, blockDataLengths: [78, 78], blockTotalLengths: [98, 98]),
    QRVersion(version: 8, totalCodewords: 242, blockDataLengths: [97, 97], blockTotalLengths: [121, 121]),
    QRVersion(version: 9, totalCodewords: 292, blockDataLengths: [116, 116], blockTotalLengths: [146, 146]),
    QRVersion(version: 10, totalCodewords: 346, blockDataLengths: [68, 68, 69, 69], blockTotalLengths: [86, 86, 87, 87]),
  ];

  static const Map<int, List<int>> alignmentCenters = {
    1: [], 2: [6, 18], 3: [6, 22], 4: [6, 26], 5: [6, 30],
    6: [6, 34], 7: [6, 22, 38], 8: [6, 24, 42],
    9: [6, 26, 46], 10: [6, 28, 50],
  };

  static QRVersion? selectForByteLength(int byteLength) {
    for (final item in supported) {
      final countBits = item.version <= 9 ? 8 : 16;
      // ECI mode + assignment, byte mode + count + payload.
      final requiredBits = 12 + 4 + countBits + byteLength * 8;
      if (requiredBits <= item.dataCodewords * 8) return item;
    }
    return null;
  }
}
