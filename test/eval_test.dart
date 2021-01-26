import 'package:flutter_test/flutter_test.dart';
import 'package:flutteversi/models/ai_player.dart';
import 'package:flutteversi/models/board.dart';
import 'package:flutteversi/models/game_model.dart';
import 'package:flutteversi/utils/array2d.dart';

void main() {
  final evaluator = Evaluator();
  test('Test corner value', () {
    final board = Board.from(Array2D(8, 8)..set(7, 6, Piece.black));
    print('Corners: ' + evaluator.evalCorners(board, Piece.black).toString());
    print(
        'Frontiers: ' + evaluator.evalFrontiers(board, Piece.black).toString());
    print('Diff: ' +
        evaluator.evalPieceDifference(board, Piece.black).toString());
    print('Mobility: ' + evaluator.evalMobility(board, Piece.black).toString());
    print('Total: ' + evaluator.eval(board, Piece.black).toString());
  });
  test('Test positional value', () {
    final board = Board.fresh();
    print(evaluator.evalPositions(board, Piece.black));
  });
}
