import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutteversi/constants.dart';
import 'package:flutteversi/models/board.dart';
import 'package:flutteversi/models/game_model.dart';
import 'package:flutteversi/models/player.dart';
import 'package:flutteversi/utils/point_to_coord.dart';

/*
 * Interesting read:
 * http://www.hamedahmadi.com/gametree/
 * http://www.cs.cornell.edu/~yuli/othello/othello.html
 * http://play-othello.appspot.com/files/Othello.pdf
 */

class AIPlayer extends Participant {
  AIPlayer(Piece piece, {this.level = 1}) : super(piece);

  final int level;

  @override
  Future<Point<int>> move(Board board, List<Point<int>> possibleMoves) async {
    await Future.delayed(mediumAnimDuration);
    return await compute(
        _runAIEngine,
        NegamaxEngine(
            board: board, piece: piece, moves: possibleMoves, maxDepth: level));
  }

  @override
  String get name => 'NegamaxAI Level $level';
}

Point<int> _runAIEngine(NegamaxEngine engine) {
  return engine.run();
}

class NegamaxEngine {
  final Board board;
  final Piece piece;
  final List<Point<int>> moves;
  final int maxDepth;
  int _nodesExplored = 0;
  int _nodesPruned = 0;
  int _evaluated = 0;

  final evaluator = Evaluator();

  static const int infinity = 100000000000;

  NegamaxEngine({this.board, this.piece, this.moves, this.maxDepth});

  Point<int> run() {
    if (moves.isEmpty) return null;
    // If there are only single moves left just play that move.
    if (moves.length == 1) return moves.first;

    Point<int> bestMove = moves.first;
    int bestScore = -infinity;

    for (var move in moves) {
      var newBoard = board.makeMove(piece, move.x, move.y);
      var score = _negamax(newBoard, maxDepth, piece, -infinity, infinity);
      print('Score for ${move.coord} is $score');
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    if (bestMove != null)
      print("Fount best move ${bestMove.coord} with score $bestScore "
          "after exploring $_nodesExplored nodes "
          "(pruned: $_nodesPruned, evaluated: $_evaluated)");
    return bestMove;
  }

  // Negamax with alpha-beta pruning
  int _negamax(Board board, int depth, Piece p, int alpha, int beta) {
    _nodesExplored++;
    if (board.isGameOver || depth == 0) {
      _evaluated++;
      return evaluator.eval(board, p);
    }
    int max = -infinity;
    for (var move in board.findValidMovesFor(p)) {
      var newBoard = board.makeMove(p, move.x, move.y);
      int x = -_negamax(newBoard, depth - 1, p.opposite, -beta, -alpha);
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
  Evaluator();

  static const weight = [
    [100, -20, 10, 5, 5, 10, -20, 100],
    [-20, -50, -2, -2, -2, -2, -50, -20],
    [10, -2, -1, -1, -1, -1, -2, 10],
    [5, -2, -1, -1, -1, -1, -2, 5],
    [5, -2, -1, -1, -1, -1, -2, 5],
    [10, -2, -1, -1, -1, -1, -2, 10],
    [-20, -50, -2, -2, -2, -2, -50, -20],
    [100, -20, 10, 5, 5, 10, -20, 100],
  ];

  int eval(Board board, Piece p) {
//    final pieceDiff = p == Piece.black
//        ? board.blackPieces - board.whitePieces
//        : board.whitePieces - board.blackPieces;
//    final playerMobility = board.findValidMovesFor(p).length;
//    final opponentMobility = board.findValidMovesFor(p.opposite).length;
//    final mobility = 10 * countCorners(board, p) -
//        countCorners(board, p.opposite) +
//        (playerMobility - opponentMobility) ~/
//            (playerMobility + opponentMobility);
//    final positions = evalPositions(board, p);
//
//    return pieceDiff + mobility + positions;
//
    final pieceDiff = evalPieceDifference(board, p);
    final corners = evalCorners(board, p);
//    final positions = evalPositions(board, p);
    final mobility = evalMobility(board, p);
//    final frontiers = evalFrontiers(board, p);

    if (board.totalScore <= 50) // Early game
      return 5 * pieceDiff + 50 * mobility + 1000 * corners;
    else // Late game
      return 200 * pieceDiff + 15 * mobility + 1000 * corners;
  }

  // Normalize to range [-100, 100]
  int _normalize(int a, int b) {
    return 100 * (a - b) ~/ (a + b + 0.1);
  }

  int evalPieceDifference(Board board, Piece p) {
//    return _normalize(board.scoreFor(p), board.scoreFor(p.opposite));
    final playerScore = board.scoreFor(p);
    final opponentScore = board.scoreFor(p.opposite);
//    return playerScore - opponentScore;
    return _normalize(playerScore, opponentScore);
  }

  int evalMobility(Board board, Piece p) {
    final playerTotalMoves = board.findValidMovesFor(p).length;
    final opponentTotalMoves = board.findValidMovesFor(p.opposite).length;
//    return _normalize(playerTotalMoves, opponentTotalMoves);
    return _normalize(playerTotalMoves, opponentTotalMoves);
  }

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
    return _normalize(playerScore, opponentScore);
  }

  int evalCorners(Board board, Piece p) {
    final playerCorners = countCorners(board, p);
    final opponentCorners = countCorners(board, p.opposite);

//    return _normalize(playerCorners, opponentCorners);
    return (playerCorners - opponentCorners);
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

    return _normalize(opponentFrontiers, playerFrontiers);
//    return opponentFrontiers - playerFrontiers;
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
