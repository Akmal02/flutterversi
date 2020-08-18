import 'dart:async';
import 'dart:math';

import 'board.dart';
import 'game_model.dart';

abstract class Participant {
  Future<Point<int>> move(Board board);

  Piece get piece;
}

class Player implements Participant {
  Completer<Point<int>> completer;

  @override
  Future<Point<int>> move(Board board) {
    return completer.future;
  }

  @override
  Piece get piece => Piece.black;

  void prepare() {
    completer = Completer<Point<int>>();
  }

  void send(int x, int y) {
    if (!completer.isCompleted) completer.complete(Point(x, y));
  }
}
