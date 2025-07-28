class Recognition {
  final int id;
  final String label;
  final double confidence;
  final BoundingBox boundingBox;

  const Recognition({
    required this.id,
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  @override
  String toString() {
    return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
  }
}
