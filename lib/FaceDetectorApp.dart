import 'package:flutter/material.dart';




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

  Future _fncGetImage() async {

  }

  Future _fncProcessFile(String path) async {

  }

  Future<void> _fncProcessImage() async {
    
  }

}
