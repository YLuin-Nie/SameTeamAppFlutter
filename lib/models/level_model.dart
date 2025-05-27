import 'package:flutter/material.dart';

class Level {
  final String name;
  final Color color;

  Level(this.name, this.color);

  static Level getLevel(int points) {
    if (points < 1) return Level('Level 0 - Newbie', Colors.white);
    if (points < 200) return Level('Level 1 - Beginner', Colors.grey);
    if (points < 400) return Level('Level 2 - Rising Star', Colors.green);
    if (points < 600) return Level('Level 3 - Helper Pro', Colors.blue);
    if (points < 1000) return Level('Level 4 - Superstar', Colors.yellow);
    return Level('Level 5 - Legend', Colors.orange);
  }
}
