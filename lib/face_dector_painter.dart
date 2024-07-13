// import 'package:face/condinate_painter.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// class FaceDetectorPainter extends CustomPainter {
//   final List<Face> faces;
//   final Size absoluteSize;
//   final InputImageRotation rotation;
//   FaceDetectorPainter(this.faces, this.absoluteSize, this.rotation);
//   @override
//   void paint(Canvas canvas, Size size) {
//     // TODO: implement paint
//     final Paint paint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;
//     for (var face in faces) {
//       final Rect rect = Rect.fromLTRB(
//           translateX(face.boundingBox.left, rotation, size, absoluteSize),
//           translateY(face.boundingBox.top, rotation, size, absoluteSize),
//           translateX(face.boundingBox.right, rotation, size, absoluteSize),
//           translateY(face.boundingBox.bottom, rotation, size, absoluteSize));

//       canvas.drawRect(rect, paint);
//       void paintContour(FaceContourType type) {
//         final faceContour = face.contours[type];
//         if (faceContour?.points != null) {
//           for (final point in faceContour!.points) {
//             canvas.drawCircle(
//                 Offset(
//                     translateX(
//                         point.x.toDouble(), rotation, size, absoluteSize),
//                     translateY(
//                         point.y.toDouble(), rotation, size, absoluteSize)),
//                 1.0,
//                 paint);
//           }
//         }
//       }

//       paintContour(FaceContourType.face);
//       paintContour(FaceContourType.leftEyebrowTop);
//       paintContour(FaceContourType.leftEyebrowBottom);
//       paintContour(FaceContourType.rightEyebrowTop);
//       paintContour(FaceContourType.rightEyebrowBottom);
//       paintContour(FaceContourType.leftEye);
//       paintContour(FaceContourType.rightEye);
//       paintContour(FaceContourType.upperLipTop);
//       paintContour(FaceContourType.upperLipBottom);
//       paintContour(FaceContourType.lowerLipTop);
//       paintContour(FaceContourType.lowerLipBottom);
//       paintContour(FaceContourType.noseBridge);
//       paintContour(FaceContourType.noseBottom);
//       paintContour(FaceContourType.leftCheek);
//       paintContour(FaceContourType.rightCheek);
//     }
//   }

//   @override
//   bool shouldRepaint(final FaceDetectorPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     return oldDelegate.absoluteSize != absoluteSize ||
//         oldDelegate.faces != faces;
//   }
// }
