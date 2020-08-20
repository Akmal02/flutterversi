import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutteversi/constants.dart';
import 'package:flutteversi/models/board.dart';
import 'package:flutteversi/models/game_model.dart';
import 'package:flutteversi/models/player.dart';

// http://www.hamedahmadi.com/gametree/

class AIPlayer extends Participant {
  AIPlayer(Piece piece) : super(piece);

  @override
  Future<Point<int>> move(Board board) async {
    await Future.delayed(mediumAnimDuration);
    return await compute(
        _runAIEngine, NegamaxEngine(board: board, piece: piece));
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
  int _nodesExplored = 0;
  int _nodesPruned = 0;

  final evaluator = Evaluator();

  static const int infinity = 100000000000;

  int maxDepth = 3;

  NegamaxEngine({this.board, this.piece});

  Point<int> run() {
    final possibleMoves = board.findValidMovesFor(piece);

    Point<int> bestMove;
    int bestScore = -infinity;
    for (var move in possibleMoves) {
      var newBoard = board.makeMove(piece, move.x, move.y);
      var score = _negamax(newBoard, 1, piece, -infinity, infinity);
      print('Score for ${_pointToCoord(move)} is $score');
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
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
      if (depth <= 1) {
        print('D: $depth, move: ${_pointToCoord(move)}, score: $x');
      }
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
    final pieceDiff = _evalPieceDifference(board, p);
//    final corners = _evalCorners(board, p);
//    final edges = _evalEdges(board, p);
    final positions = _evalPositions(board, p);
    final mobility = _evalMobility(board, p);
    return 2 * pieceDiff + 3 * mobility + positions;
  }

  int _evalPieceDifference(Board board, Piece p) {
//    final value = 100 * board.scoreDifference / (board.totalScore + 1);
//    return value.toInt();
    return board.scoreDifference;
  }

  int _evalMobility(Board board, Piece p) {
    final playerTotalMoves = board.findValidMovesFor(p).length;
    final opponentTotalMoves = board.findValidMovesFor(p.opposite).length;
//    return 100 *
//        (playerTotalMoves - opponentTotalMoves) ~/
//        (playerTotalMoves + opponentTotalMoves + 1);
    return playerTotalMoves - opponentTotalMoves;
  }

  static const weight = [
    [1000, -200, 11, 6, 6, 11, -200, 1000],
    [-200, -100, 1, 2, 2, 1, -100, -200],
    [11, 1, 5, 4, 4, 5, 1, 11],
    [6, 2, 4, 2, 2, 4, 2, 6],
    [6, 2, 4, 2, 2, 4, 2, 6],
    [11, 1, 5, 4, 4, 5, 1, 11],
    [-200, -100, 1, 2, 2, 1, -100, -200],
    [1000, -200, 11, 6, 6, 11, -200, 1000],
  ];

  int _evalPositions(Board board, Piece p) {
    int score = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        var x = board.grid(j, i);
        if (x == p) score += weight[j][i];
      }
    }
    return score;
  }

  int _evalCorners(Board board, Piece p) {
    final playerCorners = _countCorners(board, p);
    final opponentCorners = _countCorners(board, p.opposite);

    return 100 *
        (playerCorners - opponentCorners) ~/
        (playerCorners + opponentCorners + 1);
  }

  int _countCorners(Board board, Piece p) {
    int ownedCorners = 0;
    if (board.grid(0, 0) == p) ownedCorners++;
    if (board.grid(0, board.grid.col - 1) == p) ownedCorners++;
    if (board.grid(board.grid.row - 1, 0) == p) ownedCorners++;
    if (board.grid(board.grid.row - 1, board.grid.col - 1) == p) ownedCorners++;
    return ownedCorners;
  }

  int _evalEdges(Board board, Piece p) {
    final playerEdges = _countEdges(board, p);
    final opponentEdges = _countEdges(board, p.opposite);

    return 100 *
        (playerEdges - opponentEdges) ~/
        (playerEdges + opponentEdges + 1);
  }

  int _countEdges(Board board, Piece p) {
    int ownedEdges = 0;

    for (int i = 1; i < board.grid.row - 1; i++) {
      if (board.grid(i, 0) == p) ownedEdges++;
      if (board.grid(i, board.grid.col - 1) == p) ownedEdges++;
    }
    for (int j = 1; j < board.grid.col - 1; j++) {
      if (board.grid(0, j) == p) ownedEdges++;
      if (board.grid(board.grid.row - 1, j) == p) ownedEdges++;
    }
    return ownedEdges;
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
