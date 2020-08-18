import 'package:flutter/material.dart';
import 'package:flutteversi/models/game_model.dart';

class GamePiece extends StatelessWidget {
  final Piece piece;

  GamePiece({this.piece}) : super(key: ObjectKey(piece));

  @override
  Widget build(BuildContext context) {
    switch (piece) {
      case Piece.white:
        return Container(
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 4,
              ),
            ],
          ),
        );
      case Piece.black:
        return Container(
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            color: Colors.black,
            shadows: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 4,
              ),
            ],
          ),
        );
      default:
        return SizedBox();
    }
  }
}
