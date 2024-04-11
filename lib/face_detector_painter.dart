import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';





class FaceDetectorPainter extends CustomPaint {
  FaceDetectorPainter({
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    super.key,
  });



  final List<Face>? faces;
  final Size? imageSize;
  final InputImageRotation? rotation;
  final CameraLensDirection? cameraLensDirection;



  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.orange;

    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.orange;

    final Paint paint3 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.blue;
  }


  bool shouldRepaint(FaceDetectorPainter oldDelegate)
  => oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;

}