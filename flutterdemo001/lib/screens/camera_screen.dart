import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../services/detection_service.dart';
import '../models/recognition.dart';
import '../widgets/bounding_box_painter.dart';
import '../main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  DetectionService? _detectionService;

  bool _isDetecting = false;
  bool _isInitialized = false;
  List<Recognition> _recognitions = [];

  Timer? _fpsTimer;
  int _frameCount = 0;
  double _fps = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fpsTimer?.cancel();
    _cameraController?.dispose();
    _detectionService?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeServices() async {
    await _initializeDetectionService();
    await _initializeCamera();
    _startFpsCounter();
  }

  Future<void> _initializeDetectionService() async {
    try {
      _detectionService = DetectionService();
      await _detectionService!.loadModel();
      print('检测服务初始化成功');
    } catch (e) {
      print('检测服务初始化失败: $e');
      if (mounted) {
        _showErrorDialog('模型加载失败', '请检查模型文件是否存在: $e');
      }
    }
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      if (mounted) {
        _showErrorDialog('摄像头错误', '未找到可用的摄像头');
      }
      return;
    }

    try {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startImageStream();
      }
    } on CameraException catch (e) {
      print('摄像头初始化错误: ${e.code}\n${e.description}');
      if (mounted) {
        _showErrorDialog('摄像头错误', e.description ?? '摄像头初始化失败');
      }
    }
  }

  void _startImageStream() {
    _cameraController!.startImageStream((CameraImage image) {
      if (!_isDetecting && _detectionService != null && mounted) {
        _isDetecting = true;
        _runDetection(image);
      }
    });
  }

  Future<void> _runDetection(CameraImage image) async {
    try {
      final recognitions = await _detectionService!.detectObjects(image);

      if (mounted) {
        setState(() {
          _recognitions = recognitions;
          _frameCount++;
        });
      }
    } catch (e) {
      print('检测错误: $e');
    } finally {
      _isDetecting = false;
    }
  }

  void _startFpsCounter() {
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _fps = _frameCount.toDouble();
          _frameCount = 0;
        });
      }
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI实时检测'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized || _cameraController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              '正在初始化摄像头...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        _buildCameraPreview(),
        _buildOverlay(),
        _buildDetectionInfo(),
        _buildFpsCounter(),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      painter: BoundingBoxPainter(
        recognitions: _recognitions,
        previewSize: _cameraController!.value.previewSize!,
        screenSize: MediaQuery.of(context).size,
      ),
      child: Container(),
    );
  }

  Widget _buildDetectionInfo() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _isDetecting ? Icons.radar : Icons.radar_outlined,
                  color: _isDetecting ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '检测到 ${_recognitions.length} 个对象',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (_recognitions.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._recognitions
                  .take(3)
                  .map(
                    (recognition) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recognition.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(recognition.confidence * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFpsCounter() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'FPS: ${_fps.toStringAsFixed(1)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
