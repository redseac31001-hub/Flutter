import 'package:flutter/material.dart';
import '../models/recognition.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Recognition> recognitions;
  final Size previewSize;
  final Size screenSize;

  BoundingBoxPainter({
    required this.recognitions,
    required this.previewSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    for (final recognition in recognitions) {
      final left = recognition.boundingBox.x * size.width;
      final top = recognition.boundingBox.y * size.height;
      final width = recognition.boundingBox.width * size.width;
      final height = recognition.boundingBox.height * size.height;

      final rect = Rect.fromLTWH(left, top, width, height);

      // 设置边界框颜色
      paint.color = _getColorForClass(recognition.label);

      // 绘制边界框
      canvas.drawRect(rect, paint);

      // 绘制标签
      final labelText =
          '${recognition.label} ${(recognition.confidence * 100).toInt()}%';
      textPainter.text = TextSpan(
        text: labelText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        left,
        top - 25,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      // 绘制标签背景
      canvas.drawRect(labelRect, Paint()..color = paint.color.withOpacity(0.8));

      // 绘制标签文字
      textPainter.paint(canvas, Offset(left + 4, top - 23));
    }
  }

  Color _getColorForClass(String className) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
    ];

    return colors[className.hashCode % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
