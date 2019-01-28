import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

List<CameraDescription> cameras;

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future analyzePicture() async {
    print('take pic!');
    final dir = await getApplicationDocumentsDirectory();
    final imagePath = dir.path + '/analyzer_image';
    await controller.takePicture(imagePath);

    final image = FirebaseVisionImage.fromFilePath(imagePath);
    final VisionText visionText = await textRecognizer.processImage(image);
    print(visionText.text);

    await File(imagePath).delete();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return GestureDetector(
        onTap: analyzePicture,
        child: AspectRatio(
          aspectRatio:
          controller.value.aspectRatio,
          child: CameraPreview(controller)),
    );
  }
}