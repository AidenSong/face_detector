import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';




class FaceDetectorApp extends StatefulWidget {
  const FaceDetectorApp({super.key});

  @override
  State<FaceDetectorApp> createState() => _FaceDetectorAppState();
}

class _FaceDetectorAppState extends State<FaceDetectorApp> {

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("얼굴 인식 앱"),
        actions: [
          IconButton(
            onPressed: () {

            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Future _fncGetImage(ImageSource source) async {

  }

  Future _fncProcessFile(String path) async {

  }

  Future<void> _fncProcessImage(InputImage inputImage) async {

  }

}
