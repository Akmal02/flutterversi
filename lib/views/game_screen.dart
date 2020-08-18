import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteversi/models/game_model.dart';
import 'package:provider/provider.dart';

import '../widgets/background.dart';
import 'board_view.dart';
import 'score_board.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static final List<List<Color>> colorSets = [
    [Colors.green, Colors.teal, Colors.blue],
    [Colors.purple, Colors.red, Colors.orange],
    [Colors.teal, Colors.orange],
    [Colors.indigo, Colors.yellow],
    [Colors.purple, Colors.pink.shade200],
    [Colors.blueGrey, Colors.lime],
    [Colors.blueGrey, Colors.brown.shade200],
    [Colors.blue.shade900, Colors.lime.shade700, Colors.yellow],
    [Colors.teal.shade200, Colors.orange.shade400, Colors.pink],
    [Colors.grey.shade700, Colors.deepOrange],
  ];

  List<Color> _selectedGradientColors = colorSets.first;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameModel()..start(),
      child: Scaffold(
        body: GradientBackground(
          colors: _selectedGradientColors,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ScoreBoard(),
                  BoardView(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildControls(context),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        tooltip: 'Restart',
        icon: Icon(Icons.refresh),
        onPressed: () {
          final model = context.read<GameModel>();
          model.reset();
          model.start();
          HapticFeedback.mediumImpact();
          setState(() {
            _selectedGradientColors =
                colorSets[Random().nextInt(colorSets.length)];
          });
        },
      ),
    );
  }
}
