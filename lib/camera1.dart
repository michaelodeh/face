// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:face/main.dart';
// import 'package:face/util.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:developer';

// class CameraView extends StatefulWidget {
//   final String title;
//   final CustomPaint? customPaint;
//   final Widget? message;
//   final Function(InputImage inputImage) onImage;
//   final CameraLensDirection initialDirection;

//   const CameraView(
//       {super.key,
//       required this.title,
//       this.customPaint,
//       required this.initialDirection,
//       required this.onImage,
//       this.message});

//   @override
//   _CameraViewState createState() => _CameraViewState();
// }

// class _CameraViewState extends State<CameraView> {
//   final ScreenMode _mode = ScreenMode.live;
//   CameraController? _cameraController;
//   File? _file;
//   String? _path;
//   ImagePicker? _imagePicker;
//   int _cameraIndex = 0;
//   double zoomLevel = 0.0;
//   double minZoomLevel = 0.0;
//   double maxZoomLevel = 0.0;
//   bool _changingCameraLens = false;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     _imagePicker = ImagePicker();
//     if (cameras.any(
//       (element) =>
//           element.lensDirection == widget.initialDirection &&
//           element.sensorOrientation == 90,
//     )) {
//       _cameraIndex = cameras.indexOf(cameras.firstWhere((element) =>
//           element.lensDirection == widget.initialDirection &&
//           element.sensorOrientation == 90));
//     } else {
//       _cameraIndex = cameras.indexOf(cameras.firstWhere(
//           (element) => element.lensDirection == widget.initialDirection));
//     }
//     _startLive();
//     if (mounted) setState(() {});
//   }

//   Future<void> _startLive() async {
//     log("sSensorOrientation");
//     final camera = cameras[_cameraIndex];
//     _cameraController = CameraController(
//       camera,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );
//     _cameraController?.initialize().then((_) {
//       if (!mounted) return;
//       _cameraController?.getMaxZoomLevel().then((value) {
//         maxZoomLevel = value;
//       });
//       _cameraController?.getMinZoomLevel().then((value) {
//         zoomLevel = value;
//         minZoomLevel = value;
//       });
//       _cameraController?.startImageStream(_processImage);
//       setState(() {});
//     });
//   }

//   Future<void> _processImage(CameraImage image) async {
//     log("Streaming image");
//     WriteBuffer allBytes = WriteBuffer();
//     for (final Plane plane in image.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();
//     final imageSize = Size(image.width.toDouble(), image.height.toDouble());
//     final camera = cameras[_cameraIndex];
//     final imageRotation =
//         InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
//             InputImageRotation.rotation0deg;
//     final inputImageFormat =
//         InputImageFormatValue.fromRawValue(image.format.raw) ??
//             InputImageFormat.nv21;
//     final planData = image.planes.map((final Plane plane) {
//       return InputImageMetadata(
//           size: imageSize,
//           rotation: imageRotation,
//           format: inputImageFormat,
//           bytesPerRow: plane.bytesPerRow);
//     }).toList();

//     final inputImage = InputImage.fromBytes(
//       bytes: bytes,
//       metadata: InputImageMetadata(
//           size: imageSize,
//           rotation: imageRotation,
//           format: inputImageFormat,
//           bytesPerRow: image.planes.first.bytesPerRow),
//     );
//     widget.onImage(inputImage);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title), actions: [
//         if (cameras.length > 1)
//           IconButton(
//               icon: const Icon(Icons.cameraswitch_outlined),
//               onPressed: _switchCamera),
//       ]),
//       body: _body(),
//     );
//   }

//   Future<void> _switchCamera() async {
//     setState(() {
//       _changingCameraLens = !_changingCameraLens;
//     });
//     _cameraIndex = (_cameraIndex + 1) % cameras.length;
//     await _stopLive();
//     await _startLive();
//     setState(() {
//       _changingCameraLens = false;
//     });
//   }

//   Widget _body() {
//     if (_cameraController == null) return Container();
//     if (_cameraController!.value.isInitialized == false) return Container();

//     final size = MediaQuery.of(context).size;
//     var scale = size.aspectRatio * _cameraController!.value.aspectRatio;
//     if (scale < 1) scale = 1 / scale;
//     return Container(
//       color: Colors.black,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           Transform.scale(
//             scale: scale,
//             child: Center(
//               child: _changingCameraLens
//                   ? const Center(
//                       child: Text("Changing Camera Lens"),
//                     )
//                   : CameraPreview(_cameraController!),
//             ),
//           ),
//           if (widget.customPaint != null) widget.customPaint!,
//           if (widget.message != null)
//             Positioned(left: 0, right: 0, bottom: 100, child: widget.message!),
//           Positioned(
//               left: 50,
//               right: 50,
//               bottom: 50,
//               child: Slider(
//                 label: "Zoom",
//                 value: zoomLevel,
//                 max: maxZoomLevel,
//                 min: minZoomLevel,
//                 onChanged: (value) {
//                   setState(() {
//                     zoomLevel = value;
//                     _cameraController!.setZoomLevel(zoomLevel);
//                   });
//                 },
//                 // divisions: (zoomLevel - 1).toInt() < 1
//                 //     ? null
//                 //     : (zoomLevel - 1).toInt(),
//               ))
//         ],
//       ),
//     );
//   }

//   Future<void> _stopLive() async {
//     _cameraController?.stopImageStream();
//     _cameraController?.dispose();
//     _cameraController = null;
//   }
// }
