import 'dart:math';

import 'board.dart';
import 'game_model.dart';
import 'player.dart';

import 'package:flutteversi/utils/list_ext.dart';

class RandomPlayer extends Participant {
  RandomPlayer(Piece piece) : super(piece);

  @override
  Future<Point<int>> move(Board board, List<Point<int>> possibleMoves) async {
    await Future.delayed(Duration(milliseconds: 300));

    final randomMove = possibleMoves.pickRandom();
    return randomMove;
  }

  @override
  String get name => 'RandomAI';
}
