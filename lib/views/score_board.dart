import 'package:flutter/material.dart';
import 'package:flutteversi/constants.dart';
import 'package:flutteversi/models/game_model.dart';
import 'package:flutteversi/widgets/ticking_number.dart';
import 'package:provider/provider.dart';

class ScoreBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<GameModel>();

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
                    _buildSegment(context, constraints, model, Piece.black),
                    _buildSegment(context, constraints, model, Piece.white),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(BuildContext context, BoxConstraints constraints,
      GameModel model, Piece piece) {
    final playerPiece = model.board.scoreFor(piece);
    final totalPiece = model.board.totalScore;

    final isGameOver = !model.ongoing;
    Piece winningSide;

    if (isGameOver) {
      if (model.board.scoreDifference > 0) {
        winningSide = Piece.black;
      } else if (model.board.scoreDifference < 0) {
        winningSide = Piece.white;
      }
    }

    double width;
    if (isGameOver) {
      width = winningSide == piece ? constraints.maxWidth : 0;
    } else {
      width = constraints.maxWidth * playerPiece / totalPiece;
    }

    String promptText;
    if (isGameOver) {
      promptText = winningSide == piece ? '${winningSide.name} wins' : '';
    }
    return AnimatedContainer(
      duration: mediumAnimDuration,
      curve: Curves.fastOutSlowIn,
      color: piece == Piece.black ? Colors.black12 : Colors.white12,
      width: width,
      height: double.infinity,
      child: AnimatedSwitcher(
          duration: mediumAnimDuration,
          child: isGameOver
              ? _buildFinishingPrompt(context, promptText)
              : _buildScore(context, piece.name, playerPiece,
                  showIndicator: model.ongoing && model.currentTurn == piece)),
    );
  }

  Widget _buildFinishingPrompt(BuildContext context, String text) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(text,
          style: textTheme.headline6.copyWith(fontWeight: FontWeight.w400)),
    );
  }

  Widget _buildScore(BuildContext context, String label, int count,
      {bool showIndicator = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.w300, color: Colors.white70),
              ),
              showIndicator
                  ? Container(
                      margin: EdgeInsets.only(left: 8),
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white70),
                        strokeWidth: 2,
                      ),
                    )
                  : SizedBox()
            ],
          ),
          SizedBox(height: 4),
          TickingNumber(count,
              duration: mediumAnimDuration,
              style: textTheme.headline4.copyWith(
                  fontWeight: FontWeight.w300, color: Colors.white70)),
        ],
      ),
    );
  }
}
