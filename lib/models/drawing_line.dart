import 'package:flutter/material.dart';

enum LineType { straight, arrow }

class DrawingLine {
  final Offset start;
  final Offset end;
  final Color color;
  final double width;
  final LineType type;

  DrawingLine({
    required this.start,
    required this.end,
    this.color = Colors.black,
    this.width = 4.0,
    this.type = LineType.straight,
  });
}