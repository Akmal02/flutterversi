import 'dart:math';

import 'board.dart';
import 'game_model.dart';
import 'player.dart';

class GameAI extends Participant {
  GameAI(Piece piece) : super(piece);

  @override
  Future<Point<int>> move(Board board) async {
    await Future.delayed(Duration(milliseconds: 950));
    final validMoves = board.possibleMovesFor(piece);
    final possibleMovePoint =
        validMoves.pointWhere((item) => item == true).toList();

    if (possibleMovePoint.isEmpty) return null;

    final randomMove = (possibleMovePoint..shuffle()).first;
    return randomMove;
  }
}
