import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutteversi/utils/array2d.dart';

import 'board.dart';
import 'game_ai.dart';
import 'player.dart';

class GameModel extends ChangeNotifier {
  Board board;

  Array2D<bool> marker;

  // Bottom right of the board, just outside the corner
  Point<int> lastPoint = Point(9, 9);

  Participant player = Player(Piece.black);
  Participant computer = GameAI(Piece.white);

  Piece currentTurn = Piece.black;

  GameModel() {
    reset();
  }

  Future<void> start() async {
    while (true) {
      bool eitherOneMoved = false;
      while (true) {
        print('Waiting for player move...');
        final playerMove = await player.move(board);

        print('Player moves (${playerMove.x}, ${playerMove.y})');

        final moved = _move(Piece.black, playerMove.x, playerMove.y);

        if (!moved) continue;

        marker = board.possibleMovesFor(Piece.white);

        if (marker.countWhere((item) => item == true) == 0) {
          marker = board.possibleMovesFor(Piece.black);
          notifyListeners();
          continue;
        } else {
          eitherOneMoved = true;

          currentTurn = Piece.white;
          notifyListeners();
          break;
        }
      }

      while (true) {
        print('Waiting for computer move...');
        final computerMove = await computer.move(board);

        if (computerMove == null) {
          break;
        }

        print('Computer moves (${computerMove.x}, ${computerMove.y})');
        bool moved = _move(Piece.white, computerMove.x, computerMove.y);

        if (!moved) continue;

        marker = board.possibleMovesFor(Piece.black);
        if (marker.countWhere((item) => item == true) == 0) {
          marker = board.possibleMovesFor(Piece.white);
          notifyListeners();
          continue;
        } else {
          eitherOneMoved = true;

          currentTurn = Piece.black;
          notifyListeners();
          break;
        }
      }

      if (!eitherOneMoved) {
        print('Finished!');
        break;
      }
    }
  }

  bool _move(Piece piece, int x, int y) {
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
    marker = board.possibleMovesFor(Piece.black);
    notifyListeners();
  }
}

enum Piece { black, white }
