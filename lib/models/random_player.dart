import 'dart:math';

import 'board.dart';
import 'game_model.dart';
import 'player.dart';

class RandomPlayer extends Participant {
  RandomPlayer(Piece piece) : super(piece);

  @override
  Future<Point<int>> move(Board board) async {
    await Future.delayed(Duration(milliseconds: 300));
    final validMoves = board.findValidMovesFor(piece);

    if (validMoves.isEmpty) return null;

    final randomMove = (validMoves..shuffle()).first;
    return randomMove;
  }

  @override
  String get name => 'RandomAI';
}
