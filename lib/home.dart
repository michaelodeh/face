// import 'dart:developer';
// import 'dart:io';

// import 'package:face/camera.dart';
// import 'package:face/face_dector_painter.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart';

// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   Offset? _previousFaceCenter;
//   DateTime? _lastFaceDetectionTime;
//   bool _smileBefore = false;
//   bool _blinkBefore = false;
//   bool _lookedBefore = false;
//   bool _moveBefore = false;
//   bool _centeredBefore = false;

//   final FaceDetector _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//           enableLandmarks: true,
//           enableClassification: true,
//           enableTracking: true,
//           enableContours: true));
//   bool _canProcess = true;
//   bool _isBusy = false;
//   CustomPaint? _customPaint = null;
//   Widget? _message = null;
//   @override
//   Widget build(BuildContext context) {
//     return CameraView(
//       initialDirection: CameraLensDirection.front,
//       title: "FaceDetector",
//       message: _message,
//       customPaint: _customPaint,
//       onImage: _processImage,
//     );
//   }

//   Future<void> _processImage(
//       InputImage inputImage, CameraController? controller) async {
//     String text = "";
//     bool ready = true;
//     if (!_canProcess) {
//       return;
//     }
//     _isBusy = true;
//     setState(() {});
//     final faces = await _faceDetector.processImage(inputImage);

//     // Check for multiple faces
//     if (faces.length > 1) {
//       text = "Only one person is allowed on the photo";
//       ready = false;
//     }
//     // Proceed if one face is detected
//     if (faces.isEmpty) return;
//     final face = faces.first;

//     // Eye Blink Detection
//     if ((face.leftEyeOpenProbability != null &&
//             face.leftEyeOpenProbability! < 0.2) &&
//         (face.rightEyeOpenProbability != null &&
//             face.rightEyeOpenProbability! < 0.2) &&
//         !_blinkBefore) {
//       text = "You blinked. Please keep your eyes open.";
//       ready = false;
//     } else {
//       _blinkBefore = true;
//     }

//     // Smile Detection
//     if ((face.smilingProbability == null || face.smilingProbability! < 0.2) &&
//         !_smileBefore) {
//       text = "Please smile";
//       ready = false;
//     } else {
//       _smileBefore = true;
//     }

//     // Check if the face is centered
//     final imageWidth = inputImage.metadata!.size.width;
//     final imageHeight = inputImage.metadata!.size.height;
//     final faceCenterX = face.boundingBox.center.dx;
//     final faceCenterY = face.boundingBox.center.dy;
//     final imageCenterX = imageWidth / 2;
//     final imageCenterY = imageHeight / 2;

//     // Allow some margin for the face to be considered centered
//     final marginX = imageWidth * 0.1; // 10% of the image width
//     final marginY = imageHeight * 0.1; // 10% of the image height

//     // log('Image Width: $imageWidth');
//     // log('Image Height: $imageHeight');
//     // log('Face Center Y: $faceCenterY');
//     // log('Face Center X: $faceCenterX');
//     // log('Image Center X: $imageCenterX');
//     // log('Image Center Y: $imageCenterY');
//     // log('Margin X: $marginX');
//     // log("marginY: $marginY");
//     log((faceCenterX < imageCenterX - marginX).toString());
//     log((faceCenterY < imageCenterY).toString());

//     if ((faceCenterY < imageCenterY && !_centeredBefore)) {
//       text =
//           "Please center your face in the frame  ${face.boundingBox.center.dx} ${face.boundingBox.center.dy}";
//       ready = false;
//     } else {
//       _centeredBefore = true;
//     }

//     // Check if the face is looking straight
//     final headYaw = face.headEulerAngleY ?? 0;
//     final headRoll = face.headEulerAngleZ ?? 0;
//     final headPitch = face.headEulerAngleX ?? 0;
//     final headYawThreshold = 10; // 10 degrees tolerance
//     final headRollThreshold = 10; // 10 degrees tolerance
//     final headPitchThreshold = 10; // 10 degrees tolerance

//     if (headYaw.abs() > headYawThreshold ||
//         headRoll.abs() > headRollThreshold ||
//         headPitch.abs() > headPitchThreshold) {
//       text = "Please look straight at the camera";
//       ready = false;
//     }

//     // Liveness Detection: Ensure slight movement over time
//     // Assuming _previousFaceCenter is a stored value from the previous frame
//     if (_previousFaceCenter != null) {
//       final movementThreshold = 10.0; // Minimum movement in pixels
//       if (!_moveBefore &&
//           (faceCenterX - _previousFaceCenter!.dx).abs() < movementThreshold &&
//           (faceCenterY - _previousFaceCenter!.dy).abs() < movementThreshold) {
//         text = "Please move slightly to verify liveness";
//         ready = false;
//       } else {
//         _moveBefore = true;
//       }
//     }
//     _previousFaceCenter = Offset(faceCenterX, faceCenterY);

//     // Ensure face is consistently detected over a period
//     final faceDetectionDuration = Duration(seconds: 2);
//     if (_lastFaceDetectionTime != null &&
//         DateTime.now().difference(_lastFaceDetectionTime!) <
//             faceDetectionDuration &&
//         !_lookedBefore) {
//       text =
//           "Face must be detected consistently for ${faceDetectionDuration.inSeconds} seconds";
//       ready = false;
//     } else {
//       _lookedBefore = true;
//       _lastFaceDetectionTime = DateTime.now();
//     }

//     // Drawing detected face
//     if (inputImage.metadata?.size != null &&
//         inputImage.metadata?.rotation != null) {
//       final painter = FaceDetectorPainter(
//           faces, inputImage.metadata!.size, inputImage.metadata!.rotation);
//       _customPaint = CustomPaint(painter: painter);
//     } else {
//       text = "Face found ${faces.length}\n\n";
//       for (var face in faces) {
//         text += "Face ${face.boundingBox}\n\n";
//       }
//       _customPaint = null;
//     }

//     _isBusy = false;

//     if (ready) {
//       Fluttertoast.showToast(
//           msg: "All passed, please wait...",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.TOP,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//           fontSize: 16.0);
//       _takeSnapshot(controller);
//     } else {
//       if (text.isNotEmpty) {
//         Fluttertoast.showToast(
//             msg: text,
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.TOP,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       }
//     }

//     text = "";
//     setState(() {});
//   }

// // Variables to track previous face position and last detection time

//   Future<void> _takeSnapshot(CameraController? controller) async {
//     if (controller == null) return;
//     try {
//       await controller.stopImageStream();
//       final photo = await controller.takePicture();
//       log(photo.toString());
//       final Directory appDocumentsDir =
//           await getApplicationDocumentsDirectory();
//       final String photoPath = "${appDocumentsDir.path}/photo.jpg";
//       await photo.saveTo(photoPath);
//     } catch (e) {
//       // Handle any errors here
//       print('Error taking snapshot: $e');
//     } finally {
//       // Optional: Restart the image stream if needed
//       // await controller.startImageStream((image) => processImage(image));
//     }
//   }

//   @override
//   void dispose() {
//     _faceDetector.close();
//     _canProcess = false;
//     _isBusy = false;
//     super.dispose();
//   }
// }
