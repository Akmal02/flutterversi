import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteversi/models/history_record.dart';
import 'package:flutteversi/utils/array2d.dart';

import 'package:flutteversi/utils/point_to_coord.dart';

import 'ai_player.dart';
import 'board.dart';
import 'player.dart';

class GameModel extends ChangeNotifier {
  Board board;

  Array2D<bool> marker;

  // Bottom right of the board, just outside the corner
  Point<int> lastPoint = Point(9, 9);

  Participant firstPlayer = HumanPlayer(Piece.black);
  Participant secondPlayer = AIPlayer(Piece.white, level: 3);

  List<HistoryRecord> history;

  bool ongoing = false;

  Piece currentTurn = Piece.black;

  GameModel() {
    reset();
  }

  void reset() {
    board = Board.fresh(size: 8);
    currentTurn = Piece.black;
    marker = board.possibleMoveArrayFor(Piece.black);
    history = [];
    ongoing = true;
    notifyListeners();
  }

  Future<void> start() async {
    while (true) {
      bool eitherOneMoved = false;
      for (var player in [firstPlayer, secondPlayer]) {
        currentTurn = player.piece;
        while (true) {
          print('Waiting for ${player.name} (${player.piece}) move...');

          final validMoves = board.findValidMovesFor(player.piece);

          if (validMoves.isEmpty) break;

          eitherOneMoved = true;
          marker = board.possibleMoveArrayFor(player.piece);
          notifyListeners();
          await Future.delayed(Duration(milliseconds: 250));

          final playerMove = await player.move(board, validMoves);

          if (playerMove == null) break;
          if (!validMoves.contains(playerMove)) continue;

          print('${player.name} moves ${playerMove.coord}');

          final moved = _conductMove(player.piece, playerMove.x, playerMove.y);

          if (!moved) continue;

          history.add(
              HistoryRecord(board: board, turn: currentTurn, move: playerMove));
          break;
        }
      }

      if (!eitherOneMoved) {
        print('Finished!');
        HapticFeedback.mediumImpact();
        ongoing = false;
        notifyListeners();
        break;
      }
    }
  }

  bool _conductMove(Piece piece, int x, int y) {
    final newBoard = board.makeMove(piece, x, y);
    if (newBoard != null) {
      board = newBoard;
      lastPoint = Point(x, y);
      return true;
    } else {
      return false;
    }
  }
}

enum Piece { black, white }

// Well it would be great is enum can implement functions as well...
extension PieceExt on Piece {
  get opposite => this == Piece.black ? Piece.white : Piece.black;

  get name => this == Piece.black ? 'Black' : 'White';
}
