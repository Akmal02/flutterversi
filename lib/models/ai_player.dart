import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutteversi/constants.dart';
import 'package:flutteversi/models/board.dart';
import 'package:flutteversi/models/game_model.dart';
import 'package:flutteversi/models/player.dart';

/*
 * Interesting read:
 * http://www.hamedahmadi.com/gametree/
 * http://www.cs.cornell.edu/~yuli/othello/othello.html
 */

class AIPlayer extends Participant {
  AIPlayer(Piece piece) : super(piece);

  @override
  Future<Point<int>> move(Board board, List<Point<int>> possibleMoves) async {
    await Future.delayed(mediumAnimDuration);
    return await compute(_runAIEngine,
        NegamaxEngine(board: board, piece: piece, moves: possibleMoves));
  }

  @override
  String get name => 'NegamaxAI';
}

Point<int> _runAIEngine(NegamaxEngine engine) {
  return engine.run();
}

class NegamaxEngine {
  final Board board;
  final Piece piece;
  final List<Point<int>> moves;
  int _nodesExplored = 0;
  int _nodesPruned = 0;

  final evaluator = Evaluator();

  static const int infinity = 100000000000;

  int maxDepth = 3;

  NegamaxEngine({this.board, this.piece, this.moves});

  Point<int> run() {
    Point<int> bestMove;
    int bestScore = -infinity;
    for (var move in moves) {
      var newBoard = board.makeMove(piece, move.x, move.y);
      var score = _negamax(newBoard, 1, piece, -infinity, infinity);
      print('Score for ${_pointToCoord(move)} is $score');
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    if (bestMove != null)
      print("Fount best move ${_pointToCoord(bestMove)} with score $bestScore "
          "after exploring $_nodesExplored nodes (pruned: $_nodesPruned)");
    return bestMove;
  }

  // Negamax with alpha-beta pruning
  int _negamax(Board board, int depth, Piece p, int alpha, int beta) {
    _nodesExplored++;
    if (board.isGameOver || depth > maxDepth) {
      return _signValue(p) * evaluator.eval(board, p);
    }
    int max = -infinity;
    for (var move in board.findValidMovesFor(p)) {
      var newBoard = board.makeMove(p, move.x, move.y);
      int x = -_negamax(newBoard, depth + 1, p.opposite, -beta, -alpha);
//      if (depth <= 1) {
//        print('D: $depth, move: ${_pointToCoord(move)}, score: $x');
//      }
      if (x > max) max = x;
      if (x > alpha) alpha = x;
      if (alpha >= beta) {
        _nodesPruned++;
        break;
      }
    }
    return max;
  }
}

class Evaluator {
  int eval(Board board, Piece p) {
    final pieceDiff = evalPieceDifference(board, p);
    final corners = evalCorners(board, p);
//    final positions = _evalPositions(board, p);
    final mobility = evalMobility(board, p);
    final frontiers = evalFrontiers(board, p);
    return pieceDiff + 10 * mobility + 2 * frontiers + 300 * corners;
  }

  // Normalize to range [-100, 100]
  int _normalize(int a, int b) {
    return 100 * (a - b) ~/ (a + b + 1);
  }

  int evalPieceDifference(Board board, Piece p) {
//    return _normalize(board.scoreFor(p), board.scoreFor(p.opposite));
    final playerScore = board.scoreFor(p);
    final opponentScore = board.scoreFor(p.opposite);
    return playerScore - opponentScore;
  }

  int evalMobility(Board board, Piece p) {
    final playerTotalMoves = board.findValidMovesFor(p).length;
    final opponentTotalMoves = board.findValidMovesFor(p.opposite).length;
//    return _normalize(playerTotalMoves, opponentTotalMoves);
    return playerTotalMoves - opponentTotalMoves;
  }

  static const weight = [
    [100, -20, 11, 6, 6, 11, -20, 100],
    [-20, -10, 1, 2, 2, 1, -10, -20],
    [11, 1, 5, 4, 4, 5, 1, 11],
    [6, 2, 4, 2, 2, 4, 2, 6],
    [6, 2, 4, 2, 2, 4, 2, 6],
    [11, 1, 5, 4, 4, 5, 1, 11],
    [-20, -10, 1, 2, 2, 1, -10, -20],
    [100, -20, 11, 6, 6, 11, -20, 100],
  ];

  int evalPositions(Board board, Piece p) {
    int playerScore = 0;
    int opponentScore = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        var x = board.grid(j, i);
        if (x == p) playerScore += weight[j][i];
        if (x == p.opposite) opponentScore += weight[j][i];
      }
    }
    return playerScore;
  }

  int evalCorners(Board board, Piece p) {
    final playerCorners = countCorners(board, p);
    final opponentCorners = countCorners(board, p.opposite);

//    return _normalize(playerCorners, opponentCorners);
    return playerCorners - opponentCorners;
  }

  int countCorners(Board board, Piece p) {
    int ownedCorners = 0;
    if (board.grid(0, 0) == p) ownedCorners++;
    if (board.grid(0, board.grid.col - 1) == p) ownedCorners++;
    if (board.grid(board.grid.row - 1, 0) == p) ownedCorners++;
    if (board.grid(board.grid.row - 1, board.grid.col - 1) == p) ownedCorners++;
    return ownedCorners;
  }

  int evalFrontiers(Board board, Piece p) {
    final playerFrontiers = countFrontiers(board, p);
    final opponentFrontiers = countFrontiers(board, p.opposite);

//    return _normalize(opponentFrontiers, playerFrontiers);
    return opponentFrontiers - playerFrontiers;
  }

  int countFrontiers(Board board, Piece p) {
    int frontiers = 0;

    for (int i = 0; i < board.grid.row; i++) {
      for (int j = 0; j < board.grid.col; j++) {
        if (board.grid(j, i) == p) {
          for (var dir in Board.allDirections) {
            if (!board.grid.isInBounds(j + dir.x, i + dir.y)) {
              continue;
            } else if (board.grid(j + dir.x, i + dir.y) == null) {
              frontiers++;
              break;
            }
          }
        }
      }
    }
    return frontiers;
  }
}

int _signValue(Piece p) {
  if (p == Piece.black)
    return 1;
  else if (p == Piece.white)
    return -1;
  else
    return 0;
}

String _pointToCoord(Point point) {
  return '${String.fromCharCode(point.x + 97)}${point.y + 1}';
}
