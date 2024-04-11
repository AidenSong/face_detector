import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';




class CameraView extends StatefulWidget {
  const CameraView({
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.back,
    super.key,
  });

  final CustomPaint customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {

  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex            = -1;
  double _currentZoomLevel    = 1.0;
  double _minAvailableZoom    = 1.0;
  double _maxAvailableZoom    = 1.0;
  bool _changingCameraLens    = false;

  final _orientations = {
    DeviceOrientation.portraitUp      : 0,
    DeviceOrientation.landscapeLeft   : 90,
    DeviceOrientation.portraitDown    : 180,
    DeviceOrientation.landscapeRight  : 270,
  };


  @override
  void initState() {
    super.initState();

  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (int i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _fncStartLiveFeed();
    }
  }

  @override
  void dispose() {
    _fncStopLiveFeed();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildLiveFeedBody(),
    );
  }

  Widget _buildLiveFeedBody() {
    if(_cameras.isEmpty) return Container();
    if(_controller == null) return Container();
    if(_controller?.value.isInitialized == false) return Container();

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [

          Center(
            child: switch(_changingCameraLens) {
              true => Center(child: Text("Changing camera lens")),
              false => CameraPreview(
                _controller!,
                child: widget.customPaint,
              )
            },
          ),



        ],
      ),
    );
  }

  Widget _buildSwitchLiveCameraToggle() => Positioned(
    bottom: 16,
    right: 16,
    child: SizedBox(
      height: 50,
      width: 50,
      child: FloatingActionButton(
        heroTag: Object(),
        onPressed: _fncSwitchLiveCamera,
        child: Icon(
          Platform.isIOS
              ? Icons.flip_camera_ios_outlined
              : Icons.flip_camera_android_outlined,
          size: 25,
        ),
      ),
    )
  );

  Widget _buildZoomControl() => Positioned(
    bottom: 16,
    left: 0,
    right: 0,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 250,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Slider(
                value: _currentZoomLevel,
                min: _minAvailableZoom,
                max: _maxAvailableZoom,
                onChanged: (value) async {
                  setState(() {
                    _currentZoomLevel = value;
                  });
                  await _controller?.setZoomLevel(value);
                },
              ),
            ),
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    "${_currentZoomLevel.toStringAsFixed(1)}x",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future _fncStartLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    _controller?.initialize().then((value) {
      if (!mounted) return;

      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) => _maxAvailableZoom = value);
      _controller?.startImageStream(_fncProcessCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) widget.onCameraFeedReady!();
        if (widget.onCameraLensDirectionChanged != null) widget.onCameraLensDirectionChanged!(camera.lensDirection);
      });
      setState(() {});
    });
  }

  Future _fncStopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _fncSwitchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _fncStopLiveFeed();
    await _fncStartLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  InputImage? _fncInputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompesation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompesation == null) return null;
      if(camera.lensDirection == CameraLensDirection.front) {
        rotationCompesation = (sensorOrientation + rotationCompesation) % 360;
      } else {
        rotationCompesation = (sensorOrientation + rotationCompesation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompesation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888))
      return null;

    if (image.planes.length != 1) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _fncProcessCameraImage(CameraImage image) {
    final inputImage = _fncInputImageFromCameraImage(image);
    if (inputImage == null) return;

    widget.onImage(inputImage);
  }


}
