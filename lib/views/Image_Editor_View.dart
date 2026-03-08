import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../models/drawing_line.dart';

class ImageEditorView extends StatefulWidget {
  final String imagePath;
  const ImageEditorView({super.key, required this.imagePath});

  @override
  State<ImageEditorView> createState() => _ImageEditorViewState();
}

class _ImageEditorViewState extends State<ImageEditorView> {
  ui.Image? _uiImage;
  bool _isLoading = true;
  final List<DrawingLine> _lines = [];
  Offset? _startPoint;
  Offset? _currentEndPoint;
  LineType _currentLineType = LineType.straight;
  Color _currentColor = Colors.red;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final File file = File(widget.imagePath);
    final data = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    setState(() {
      _uiImage = frame.image;
      _isLoading = false;
    });
  }

  Future<void> _saveImage() async {
    setState(() => _isLoading = true);
    RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/edit_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(pngBytes);
    Get.back(result: path);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final allLines = List<DrawingLine>.from(_lines);
    if (_startPoint != null && _currentEndPoint != null) {
      allLines.add(DrawingLine(start: _startPoint!, end: _currentEndPoint!, color: _currentColor, type: _currentLineType));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Tarik Garis / Panah"),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _saveImage)],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _globalKey,
                child: GestureDetector(
                  onPanStart: (d) => setState(() => _startPoint = d.localPosition),
                  onPanUpdate: (d) => setState(() => _currentEndPoint = d.localPosition),
                  onPanEnd: (d) {
                    _lines.add(DrawingLine(start: _startPoint!, end: _currentEndPoint!, color: _currentColor, type: _currentLineType));
                    _startPoint = null; _currentEndPoint = null;
                    setState(() {});
                  },
                  child: AspectRatio(
                    aspectRatio: _uiImage!.width / _uiImage!.height,
                    child: CustomPaint(
                      painter: EditorPainter(backgroundImage: _uiImage, lines: allLines),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      color: Colors.white10,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.horizontal_rule, color: _currentLineType == LineType.straight ? Colors.blue : Colors.white),
            onPressed: () => setState(() => _currentLineType = LineType.straight),
          ),
          IconButton(
            icon: Icon(Icons.trending_flat, color: _currentLineType == LineType.arrow ? Colors.blue : Colors.white),
            onPressed: () => setState(() => _currentLineType = LineType.arrow),
          ),
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: () => setState(() { if(_lines.isNotEmpty) _lines.removeLast(); }),
          ),
          _colorCircle(Colors.red),
          _colorCircle(Colors.yellow),
          _colorCircle(Colors.green),
        ],
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _currentColor = color),
      child: CircleAvatar(backgroundColor: color, radius: 15, child: _currentColor == color ? const Icon(Icons.check, size: 15) : null),
    );
  }
}

class EditorPainter extends CustomPainter {
  final ui.Image? backgroundImage;
  final List<DrawingLine> lines;
  EditorPainter({this.backgroundImage, required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      paintImage(canvas: canvas, image: backgroundImage!, rect: Rect.fromLTWH(0, 0, size.width, size.height), fit: BoxFit.contain);
    }
    final paint = Paint()..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    for (var line in lines) {
      paint.color = line.color;
      paint.strokeWidth = line.width;
      if (line.type == LineType.straight) {
        canvas.drawLine(line.start, line.end, paint);
      } else {
        _drawArrow(canvas, line.start, line.end, paint);
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const headLen = 20.0;
    canvas.drawLine(end, end - Offset(headLen * math.cos(angle - 0.5), headLen * math.sin(angle - 0.5)), paint);
    canvas.drawLine(end, end - Offset(headLen * math.cos(angle + 0.5), headLen * math.sin(angle + 0.5)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}