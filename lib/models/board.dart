import 'dart:math';

import 'package:flutteversi/utils/array2d.dart';

import 'game_model.dart';

class Board {
  final Array2D<Piece> grid;

  Board.fresh({int size = 8}) : grid = _setStartingPoint(size);

  Board.from(this.grid);

  static const allDirections = [
    Point(1, 0),
    Point(-1, 0),
    Point(0, 1),
    Point(0, -1),
    Point(1, 1),
    Point(1, -1),
    Point(-1, 1),
    Point(-1, -1),
  ];

  static Array2D<Piece> _setStartingPoint(int size) {
    int halfsize = size ~/ 2 - 1;
    return Array2D<Piece>(size, size)
      ..set(halfsize, halfsize, Piece.white)
      ..set(halfsize + 1, halfsize, Piece.black)
      ..set(halfsize, halfsize + 1, Piece.black)
      ..set(halfsize + 1, halfsize + 1, Piece.white);
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

  int get totalScore => grid.countWhere((item) => item != null);

  int get scoreDifference => scoreFor(Piece.black) - scoreFor(Piece.white);

  bool get isGameOver => totalScore == grid.row * grid.col;
//      || (!canMove(Piece.black) && !canMove(Piece.white));

  Array2D<bool> possibleMoveArrayFor(Piece piece) {
    return Array2D<bool>(grid.row, grid.col)
      ..fill((x, y) => isMoveValid(piece, x, y));
  }

  List<Point<int>> findValidMovesFor(Piece piece) {
    return [
      for (int i = 0; i < grid.row; i++)
        for (int j = 0; j < grid.col; j++)
          if (isMoveValid(piece, j, i)) Point(j, i),
    ];
  }

  bool canMove(Piece piece) {
    return findValidMovesFor(piece).isNotEmpty;
  }

  bool isMoveValid(Piece playerPiece, int x, int y) {
    if (grid.get(x, y) != null) return false;
    for (var offset in allDirections) {
      for (int i = 1;; i++) {
        if (!grid.isInBounds(x + offset.x * i, y + offset.y * i)) {
          break;
        }
        var piece = grid.get(x + offset.x * i, y + offset.y * i);
        if (piece == null) {
          break;
        } else if (piece != playerPiece) {
          continue; // Skip to the next direction
        } else if (piece == playerPiece && i > 1) {
          return true;
        } else {
          break;
        }
      }
    }
    return false;
  }

  List<Point<int>> findFlippablePieces(Piece playerPiece, int x, int y) {
//    return [
//      ..._flip(playerPiece, x, y, dx: 0, dy: 1) ?? [],
//      ..._flip(playerPiece, x, y, dx: 1, dy: 1) ?? [],
//      ..._flip(playerPiece, x, y, dx: 1, dy: 0) ?? [],
//      ..._flip(playerPiece, x, y, dx: 1, dy: -1) ?? [],
//      ..._flip(playerPiece, x, y, dx: 0, dy: -1) ?? [],
//      ..._flip(playerPiece, x, y, dx: -1, dy: -1) ?? [],
//      ..._flip(playerPiece, x, y, dx: -1, dy: 0) ?? [],
//      ..._flip(playerPiece, x, y, dx: -1, dy: 1) ?? [],
//    ];

    if (grid.get(x, y) != null) return List.empty();

    final pieceList = <Point<int>>[];

    for (var offset in allDirections) {
      for (int i = 1;; i++) {
        if (!grid.isInBounds(x + offset.x * i, y + offset.y * i)) {
          break;
        }
        var piece = grid.get(x + offset.x * i, y + offset.y * i);
        if (piece == null) {
          break;
        } else if (piece != playerPiece) {
          continue; // Skip to the next direction
        } else if (piece == playerPiece && i > 1) {
          // Include all the opponent pieces in between
          for (int j = 1; j < i; j++) {
            pieceList.add(Point(x + offset.x * j, y + offset.y * j));
          }
        }
        break;
      }
    }
    return pieceList;
  }
//
//  List<Point<int>> _flip(Piece piece, int x, int y, {int dx, int dy}) {
//    assert(!(dx == 0 && dy == 0));
//    x += dx;
//    y += dy;
//    if (!grid.isInBounds(x, y) || grid.get(x, y) == null) {
//      return null;
//    } else if (grid.get(x, y) == piece) {
//      return [];
//    }
//    final points = [
//      Point(x, y),
//    ];
//    final iterated = _flip(piece, x, y, dx: dx, dy: dy);
//    if (iterated != null) {
//      points.addAll(iterated);
//      return points;
//    } else {
//      return null;
//    }
//  }
}
