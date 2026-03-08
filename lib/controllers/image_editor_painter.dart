import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/drawing_line.dart'; // Import model di atas

class ImageEditorPainter extends CustomPainter {
  final ui.Image? backgroundImage;
  final List<DrawingLine> lines;

  ImageEditorPainter({
    required this.backgroundImage,
    required this.lines,
  });

  @override
void paint(Canvas canvas, Size size) {
  if (backgroundImage != null) {
    // Menghitung ukuran gambar agar fit di dalam canvas
    double imageWidth = backgroundImage!.width.toDouble();
    double imageHeight = backgroundImage!.height.toDouble();
    
    double scale = math.min(size.width / imageWidth, size.height / imageHeight);
    
    double dx = (size.width - imageWidth * scale) / 2;
    double dy = (size.height - imageHeight * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    canvas.restore();
  }

  // Persiapkan Paint untuk Garis (Pindahkan ke luar loop agar efisien)
  final paint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  for (var line in lines) {
    paint.color = line.color;
    paint.strokeWidth = line.width;

    if (line.type == LineType.straight) {
      canvas.drawLine(line.start, line.end, paint);
    } else if (line.type == LineType.arrow) {
     _drawArrow(canvas, line.start, line.end, paint);
    }
  }
}
  // Logika Matematika untuk menggambar kepala panah di ujung garis
  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    // Gambar batang panah
    canvas.drawLine(start, end, paint);

    // Hitung sudut garis
    double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

    // Parameter kepala panah
    const arrowHeadLength = 20.0;
    const arrowHeadAngle = math.pi / 6; // 30 derajat

    // Hitung titik-titik untuk sayap panah
    Offset x1 = end - Offset(arrowHeadLength * math.cos(angle - arrowHeadAngle),
                             arrowHeadLength * math.sin(angle - arrowHeadAngle));
    Offset x2 = end - Offset(arrowHeadLength * math.cos(angle + arrowHeadAngle),
                             arrowHeadLength * math.sin(angle + arrowHeadAngle));

    // Gambar sayap panah
    canvas.drawLine(end, x1, paint);
    canvas.drawLine(end, x2, paint);
  }

  @override
  bool shouldRepaint(covariant ImageEditorPainter oldDelegate) {
    return oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.lines != lines;
  }
}