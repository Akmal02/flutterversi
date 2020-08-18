import 'package:flutter/material.dart';
import 'package:flutteversi/models/game_model.dart';
import 'package:flutteversi/widgets/ticking_number.dart';
import 'package:provider/provider.dart';

class ScoreBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<GameModel>();

    final blackPieces = _countPieces(model, Piece.black);
    final whitePieces = _countPieces(model, Piece.white);
    final totalScore = blackPieces + whitePieces;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 96,
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                      color: Colors.black12,
                      width: constraints.maxWidth * blackPieces / totalScore,
                      height: double.infinity,
                      child: _buildScore(context, 'Black', blackPieces),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                      color: Colors.white12,
                      width: constraints.maxWidth * whitePieces / totalScore,
                      height: double.infinity,
                      child: _buildScore(context, 'White', whitePieces),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScore(BuildContext context, String label, int count) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: textTheme.subtitle1
                .copyWith(fontWeight: FontWeight.w300, color: Colors.white70),
          ),
          SizedBox(height: 4),
          TickingNumber(count,
              duration: Duration(milliseconds: 500),
              style: textTheme.headline4.copyWith(
                  fontWeight: FontWeight.w300, color: Colors.white70)),
        ],
      ),
    );
  }

  int _countPieces(GameModel model, Piece piece) {
    return model.board.scoreFor(piece);
  }
}
