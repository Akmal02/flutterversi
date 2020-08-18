import 'package:flutter/material.dart';

import 'views/game_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutteversi',
      theme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        splashFactory: InkRipple.splashFactory,
        textTheme: Typography.englishLike2018,
      ),
      home: GameScreen(),
    );
  }
}
