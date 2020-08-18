import 'dart:math';

class Array2D<T> {
  final List<T> _data;

  final int row;
  final int col;

  final bool immutable;

  Array2D(this.row, this.col, {this.immutable = false}) : _data = List<T>(row * col);

  T get(int x, int y) {
    return _data[x * col + y];
  }

  T call(int x, int y) => get(x, y);

  factory Array2D.from(Array2D other) {
    return Array2D(other.row, other.col)..fill((x, y) => other.get(x, y));
  }

  void set(int x, int y, T data) {
    assert(!immutable);
    _data[x * col + y] = data;
  }

  void remove(int x, int y) {
    assert(!immutable);
    _data[x * col + y] = null;
  }

  List<Point<int>> pointWhere(bool Function(T item) test) {
    final points = <Point<int>>[];
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        if (test(get(j, i))) {
          points.add(Point(j, i));
        }
      }
    }
    return points;
  }

  int countWhere(bool Function(T item) test) {
    var count = 0;
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        if (test(get(j, i))) {
          count++;
        }
      }
    }
    return count;
  }

  void fill(T Function(int x, int y) builder) {
    assert(!immutable);
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < col; j++) {
        set(i, j, builder(i, j));
      }
    }
  }

  bool isInBounds(int x, int y) {
    return (x >= 0 && x < row) && (y >= 0 && y < col);
  }
}
