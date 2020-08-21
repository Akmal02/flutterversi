import 'package:flutter_test/flutter_test.dart';
import 'package:flutteversi/models/ai_player.dart';
import 'package:flutteversi/models/board.dart';
import 'package:flutteversi/models/game_model.dart';
import 'package:flutteversi/utils/array2d.dart';

void main() {
  final eval = Evaluator();
  test('Test corner value', () {
    final board = Board.from(
        Array2D(8, 8)..set(0, 0, Piece.black)..set(0, 7, Piece.white));
    expect(eval.evalCorners(board, Piece.black), 100);
  });
}
