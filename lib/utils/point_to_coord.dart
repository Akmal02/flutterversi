import 'dart:math';

extension PointToCoord on Point<int> {
  String get coord {
    return '${String.fromCharCode(this.x + 97)}${this.y + 1}';
  }
}
