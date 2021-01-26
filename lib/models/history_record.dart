import 'dart:math';

import 'package:flutteversi/models/game_model.dart';

import 'board.dart';

class HistoryRecord {
  final Board board;
  final Piece turn;
  final Point<int> move;

  HistoryRecord({this.board, this.turn, this.move});
}
