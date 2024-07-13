// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// double translateX(final double x, final InputImageRotation rotation,
//     final Size size, final Size absoluteSize) {
//   switch (rotation) {
//     case InputImageRotation.rotation90deg:
//       return x *
//           size.width /
//           (Platform.isIOS ? absoluteSize.width : absoluteSize.height);
//     case InputImageRotation.rotation270deg:
//       return size.width -
//           x *
//               size.width /
//               (Platform.isIOS ? absoluteSize.width : absoluteSize.height);
//     default:
//       return x * size.width / absoluteSize.width;
//   }
// }

// double translateY(final double y, final InputImageRotation rotation,
//     final Size size, final Size absoluteSize) {
//   switch (rotation) {
//     case InputImageRotation.rotation90deg:
//     case InputImageRotation.rotation270deg:
//       return y *
//           size.height /
//           (Platform.isIOS ? absoluteSize.height : absoluteSize.width);
//     default:
//       return y * size.width / absoluteSize.width;
//   }
// }
