import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/camera_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置屏幕方向
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 请求权限
  await _requestPermissions();

  // 初始化摄像头
  await _initializeCameras();

  runApp(const CameraDetectionApp());
}

Future<void> _requestPermissions() async {
  final permissions = [Permission.camera, Permission.storage];

  for (var permission in permissions) {
    final status = await permission.request();
    if (status != PermissionStatus.granted) {
      print('权限 $permission 未授予');
    }
  }
}

Future<void> _initializeCameras() async {
  try {
    cameras = await availableCameras();
    print('找到 ${cameras.length} 个摄像头');
  } on CameraException catch (e) {
    print('摄像头初始化错误: ${e.code}\n${e.description}');
  }
}

class CameraDetectionApp extends StatelessWidget {
  const CameraDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI实时检测',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
