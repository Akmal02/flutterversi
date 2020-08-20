import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteversi/constants.dart';
import 'package:flutteversi/utils/array2d.dart';

import 'board.dart';
import 'ai_player.dart';
import 'player.dart';

class GameModel extends ChangeNotifier {
  Board board;

  Array2D<bool> marker;

  // Bottom right of the board, just outside the corner
  Point<int> lastPoint = Point(9, 9);

  Participant firstPlayer = HumanPlayer(Piece.black);
  Participant secondPlayer = AIPlayer(Piece.white);

  bool ongoing = false;

  Piece currentTurn = Piece.black;

  GameModel() {
    reset();
  }

  Future<void> start() async {
    while (true) {
      bool eitherOneMoved = false;
      for (var player in [firstPlayer, secondPlayer]) {
        while (true) {
          print('Waiting for ${player.name} (${player.piece}) move...');

          if (!board.canMove(player.piece)) {
            break;
          }
          eitherOneMoved = true;

          final playerMove = await player.move(board);

          if (playerMove == null) break;

          print('Player moves (${playerMove.x}, ${playerMove.y})');

          final moved = _conductMove(player.piece, playerMove.x, playerMove.y);

          if (!moved) continue;

          marker = board.possibleMoveArrayFor(player.piece.opposite);

          if (marker.countWhere((item) => item == true) == 0) {
            marker = board.possibleMoveArrayFor(player.piece);
            notifyListeners();
            await Future.delayed(mediumAnimDuration);
            continue;
          } else {
            currentTurn = player.piece.opposite;
            notifyListeners();
            await Future.delayed(mediumAnimDuration);
            break;
          }
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

  void reset() {
    board = Board.fresh(size: 8);
    currentTurn = Piece.black;
    marker = board.possibleMoveArrayFor(Piece.black);
    ongoing = true;
    notifyListeners();
  }
}

enum Piece { black, white }

// Well it would be great is enum can implement functions as well...
extension PieceExt on Piece {
  get opposite => this == Piece.black ? Piece.white : Piece.black;

  get name => this == Piece.black ? 'Black' : 'White';
}
