import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import '../models/recognition.dart';

class DetectionService {
  static const String _labelsPath = 'assets/labels/coco_labels.txt';
  static const double _threshold = 0.5;

  List<String> _labels = [];
  bool _isModelLoaded = false;
  final Random _random = Random();

  Future<void> loadModel() async {
    try {
      // 创建默认标签
      _labels = _createDefaultLabels();
      _isModelLoaded = true;
      print('检测服务初始化成功，共 ${_labels.length} 个类别');

      // 尝试加载标签文件（可选）
      try {
        final labelsData = await rootBundle.loadString(_labelsPath);
        _labels = labelsData
            .trim()
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();
        print('自定义标签加载成功');
      } catch (e) {
        print('使用默认标签: $e');
      }
    } catch (e) {
      print('检测服务初始化失败: $e');
      rethrow;
    }
  }

  List<String> _createDefaultLabels() {
    return [
      'person',
      'bicycle',
      'car',
      'motorcycle',
      'airplane',
      'bus',
      'train',
      'truck',
      'boat',
      'traffic_light',
      'fire_hydrant',
      'stop_sign',
      'parking_meter',
      'bench',
      'bird',
      'cat',
      'dog',
      'horse',
      'sheep',
      'cow',
      'elephant',
      'bear',
      'zebra',
      'giraffe',
      'backpack',
      'umbrella',
      'handbag',
      'tie',
      'suitcase',
      'frisbee',
      'skis',
      'snowboard',
      'sports_ball',
      'kite',
      'baseball_bat',
      'baseball_glove',
      'skateboard',
      'surfboard',
      'tennis_racket',
      'bottle',
      'wine_glass',
      'cup',
      'fork',
      'knife',
      'spoon',
      'bowl',
      'banana',
      'apple',
      'sandwich',
      'orange',
      'broccoli',
      'carrot',
      'hot_dog',
      'pizza',
      'donut',
      'cake',
      'chair',
      'couch',
      'potted_plant',
      'bed',
      'dining_table',
      'toilet',
      'tv',
      'laptop',
      'mouse',
      'remote',
      'keyboard',
      'cell_phone',
      'microwave',
      'oven',
      'toaster',
      'sink',
      'refrigerator',
      'book',
      'clock',
      'vase',
      'scissors',
      'teddy_bear',
      'hair_drier',
      'toothbrush',
    ];
  }

  Future<List<Recognition>> detectObjects(CameraImage cameraImage) async {
    if (!_isModelLoaded) {
      return [];
    }

    try {
      // 使用智能模拟检测，更真实的演示效果
      return _runSmartMockDetection();
    } catch (e) {
      print('检测过程错误: $e');
      return [];
    }
  }

  List<Recognition> _runSmartMockDetection() {
    final mockRecognitions = <Recognition>[];
    final now = DateTime.now();

    // 基于时间的动态检测，让边界框有动画效果
    final timeOffset = (now.millisecondsSinceEpoch % 10000) / 10000.0;

    // 常见对象检测模拟
    final commonObjects = [
      {'label': 'person', 'probability': 0.7},
      {'label': 'cell_phone', 'probability': 0.5},
      {'label': 'laptop', 'probability': 0.3},
      {'label': 'cup', 'probability': 0.4},
      {'label': 'book', 'probability': 0.2},
    ];

    int detectionId = 0;

    for (var obj in commonObjects) {
      // 基于概率决定是否检测到该对象
      if (_random.nextDouble() < (obj['probability'] as double)) {
        // 生成动态边界框位置
        final baseX = 0.1 + (_random.nextDouble() * 0.6);
        final baseY = 0.2 + (_random.nextDouble() * 0.5);

        // 添加轻微的动态效果
        final dynamicX =
            baseX + (sin(timeOffset * 2 * pi + detectionId) * 0.05);
        final dynamicY =
            baseY + (cos(timeOffset * 2 * pi + detectionId) * 0.03);

        mockRecognitions.add(
          Recognition(
            id: detectionId,
            label: obj['label'] as String,
            confidence: 0.6 + (_random.nextDouble() * 0.3), // 60-90%置信度
            boundingBox: BoundingBox(
              x: dynamicX.clamp(0.0, 0.8),
              y: dynamicY.clamp(0.1, 0.7),
              width: 0.15 + (_random.nextDouble() * 0.2), // 变化的宽度
              height: 0.2 + (_random.nextDouble() * 0.25), // 变化的高度
            ),
          ),
        );
        detectionId++;
      }
    }

    // 偶尔检测一些其他对象
    if (_random.nextDouble() < 0.1) {
      final randomLabel = _labels[_random.nextInt(_labels.length)];
      mockRecognitions.add(
        Recognition(
          id: detectionId,
          label: randomLabel,
          confidence: 0.5 + (_random.nextDouble() * 0.2),
          boundingBox: BoundingBox(
            x: _random.nextDouble() * 0.7,
            y: _random.nextDouble() * 0.6 + 0.1,
            width: 0.1 + (_random.nextDouble() * 0.15),
            height: 0.15 + (_random.nextDouble() * 0.2),
          ),
        ),
      );
    }

    return mockRecognitions;
  }

  void dispose() {
    _isModelLoaded = false;
    print('检测服务已释放');
  }
}
