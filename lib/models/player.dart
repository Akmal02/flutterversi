import 'dart:async';
import 'dart:math';

import 'board.dart';
import 'game_model.dart';

abstract class Participant {
  final Piece piece;

  Participant(this.piece);

  String get name;

  Future<Point<int>> move(Board board);
}

class HumanPlayer extends Participant {
  Completer<Point<int>> completer;

  HumanPlayer(Piece piece) : super(piece);

  @override
  Future<Point<int>> move(Board board) {
    completer = Completer<Point<int>>();
    return completer.future;
  }

  void send(int x, int y) {
    if (!completer.isCompleted) completer.complete(Point(x, y));
  }

  @override
  String get name => 'Human player';
}
