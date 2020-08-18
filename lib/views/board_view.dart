import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_model.dart';
import '../widgets/flipping_transition.dart';
import 'game_piece.dart';

class BoardView extends StatefulWidget {
  @override
  _BoardViewState createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<GameModel>();
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              for (int i = 0; i < 8; i++) ...[
                Expanded(
                  child: Row(
                    children: [
                      for (int j = 0; j < 8; j++) ...[
                        Expanded(
                          child: _buildSlot(model, j, i),
                        ),
                        if (j < 7)
                          VerticalDivider(width: 1, color: Colors.white24),
                      ]
                    ],
                  ),
                ),
                if (i < 7) Divider(height: 1, color: Colors.white24),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(GameModel model, int x, int y) {
    return InkWell(
      splashColor: Colors.transparent,
      customBorder: CircleBorder(),
      onTap: () {
        model.player.send(x, y);
      },
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildMarker(model, x, y),
            _buildPiece(model, x, y),
          ],
        ),
      ),
    );
  }

  Widget _buildPiece(GameModel model, int x, int y) {
    final piece = model.board.grid.get(x, y);
    // Bearing angle from origin (last point) to this piece location
    double angle = atan2(x - model.lastPoint.x, y - model.lastPoint.y);

//    double distance = hypotenuse(
//        (x - model.lastPoint.x).toDouble(), (y - model.lastPoint.y).toDouble());
    int distance =
        max((x - model.lastPoint.x).abs(), (y - model.lastPoint.y).abs());

    return FractionallySizedBox(
      widthFactor: 0.75,
      heightFactor: 0.75,
      child: FlippingTransition(
//        enabled: x != model.lastPoint.x || y != model.lastPoint.y,
        angle: 2 * pi - angle,
        delay: Duration(milliseconds: distance * 80),
        child: piece != null
            ? GamePiece(
                piece: piece,
              )
            : null,
      ),
    );
  }

  Widget _buildMarker(GameModel model, int x, int y) {
    bool markerExists =
        model.currentTurn == Piece.black && model.marker.get(x, y) == true;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      width: markerExists ? 8 : 0,
      height: markerExists ? 8 : 0,
      decoration: ShapeDecoration(shape: CircleBorder(), color: Colors.white54),
    );
  }
}
