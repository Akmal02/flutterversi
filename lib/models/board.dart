import 'dart:math';

import 'package:flutteversi/utils/array2d.dart';

import 'game_model.dart';

class Board {
  final Array2D<Piece> grid;

  Board.fresh() : grid = _setStartingPoint();

  Board.from(this.grid);

  static Array2D<Piece> _setStartingPoint() {
    return Array2D<Piece>(8, 8)
      ..set(3, 3, Piece.white)
      ..set(3, 4, Piece.black)
      ..set(4, 3, Piece.black)
      ..set(4, 4, Piece.white);
  }

  Board makeMove(Piece piece, int x, int y) {
    final newGrid = Array2D<Piece>.from(grid);
    if (newGrid.get(x, y) != null) {
      return null;
    }
    final pointsToFlip = findFlippablePieces(piece, x, y);

    if (pointsToFlip.isEmpty) {
      return null;
    }
    newGrid.set(x, y, piece);

    for (var p in pointsToFlip) {
      newGrid.set(p.x, p.y, piece);
    }

    return Board.from(newGrid);
  }

  int scoreFor(Piece piece) => grid.countWhere((item) => item == piece);

  int get scoreDifference => scoreFor(Piece.black) - scoreFor(Piece.white);

  Array2D<bool> possibleMovesFor(Piece piece) {
    return Array2D<bool>(8, 8)
      ..fill((x, y) =>
          grid.get(x, y) == null &&
          findFlippablePieces(piece, x, y).isNotEmpty);
  }

  List<Point<int>> findFlippablePieces(Piece piece, int x, int y) {
    return [
      ..._flip(piece, x, y, dx: 0, dy: 1) ?? [],
      ..._flip(piece, x, y, dx: 1, dy: 1) ?? [],
      ..._flip(piece, x, y, dx: 1, dy: 0) ?? [],
      ..._flip(piece, x, y, dx: 1, dy: -1) ?? [],
      ..._flip(piece, x, y, dx: 0, dy: -1) ?? [],
      ..._flip(piece, x, y, dx: -1, dy: -1) ?? [],
      ..._flip(piece, x, y, dx: -1, dy: 0) ?? [],
      ..._flip(piece, x, y, dx: -1, dy: 1) ?? [],
    ];
  }

  List<Point<int>> _flip(Piece piece, int x, int y, {int dx, int dy}) {
    assert(!(dx == 0 && dy == 0));
    x += dx;
    y += dy;
    if (!grid.isInBounds(x, y) || grid.get(x, y) == null) {
      return null;
    } else if (grid.get(x, y) == piece) {
      return [];
    }
    final points = [
      Point(x, y),
    ];
    final iterated = _flip(piece, x, y, dx: dx, dy: dy);
    if (iterated != null) {
      points.addAll(iterated);
      return points;
    } else {
      return null;
    }
  }
}
