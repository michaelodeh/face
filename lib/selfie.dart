import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:face/globals.dart';
import 'package:face/login.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_face_api/flutter_face_api.dart';

import 'constant.dart';

class Selfie extends StatefulWidget {
  const Selfie({super.key});

  @override
  _SelfieState createState() => _SelfieState();
}

class _SelfieState extends State<Selfie> {
  final _phone = Globals.phone;
  final _dio = Dio();
  List<dynamic> _images = [];
  final _faceSdk = FaceSDK.instance;

  Uint8List? _bytes;
  bool _busy = false;

  @override
  void initState() {
    _initFaceSdk();
    _getImages();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Live Verification",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: _getImages,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Images',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _busy
            ? const Center(child: CircularProgressIndicator())
            : _images.isEmpty
                ? const Center(
                    child: Text(
                      "No images available.\nTap the add button to To take a Selfie.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _buildImageRows(),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startLiveness,
        tooltip: 'Add Image',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _saveImage(Uint8List? image) async {
    log("Picture taken");
    if (image == null) return;
    try {
      String base64String = base64Encode(image);
      String header = "data:image/png;base64,";
      String photo = header + base64String;
      final request = await _dio
          .post('$serverURL/add', data: {'phone': _phone, 'image': photo});
      if (request.statusCode == 200) {
        final response = request.data;
        if (response["status"] == "success") {
          _getImages();
        }
      }

      // final Directory appDocumentsDir =
      //     await getApplicationDocumentsDirectory();
      // final String photoPath = "${appDocumentsDir.path}/photo.jpg";
      // File photo = File(photoPath);
      // await photo.writeAsBytes(image);
    } catch (e) {
      // Handle any errors here
      log('Error taking snapshot: $e');
    } finally {
      // Optional: Restart the image stream if needed
      // await controller.startImageStream((image) => processImage(image));
    }
  }

  Future<void> _startLiveness() async {
    final response = await _faceSdk.startLiveness(
      config: LivenessConfig(
        cameraSwitchEnabled: true,
        copyright: false,
        livenessType: LivenessType.PASSIVE,
      ),
    );
    log("Age ${response.estimatedAge}");
    log("Error ${response.error!.message}");
    if (response.error != null) {
      _stopLiveness();
      log("Error ${response.error?.message}");
      switch (response.error?.code) {
        case LivenessErrorCode.CANCELLED:
          log('liveness: User cancelled the processing.');
          break;
        case LivenessErrorCode.NO_LICENSE:
          log('liveness: Web Service is missing a valid License.');
          break;
        case LivenessErrorCode.PROCESSING_FAILED:
          log('liveness: Bad input data.');
          break;
        case LivenessErrorCode.PROCESSING_TIMEOUT:
          log('liveness: Processing finished by timeout.');
          break;
        case LivenessErrorCode.API_CALL_FAILED:
          log('liveness: Web Service API call failed due to networking error or backend internal error.');
          break;
        case LivenessErrorCode.CONTEXT_IS_NULL:
          log('liveness: Provided context is null.');
          break;
        case LivenessErrorCode.IN_PROGRESS_ALREADY:
          log('liveness: Liveness has already started.');
          break;
        case LivenessErrorCode.ZOOM_NOT_SUPPORTED:
          log('liveness: Camera zoom support is required.');
          break;
        default:
          log('liveness: error.');
          break;
      }
    } else if (response.liveness == LivenessStatus.PASSED) {
      _saveImage(response.image);
    }
  }

  Future<void> _stopLiveness() async {
    _faceSdk.stopLiveness();
  }

  Future<void> _getImages() async {
    if (_images.isEmpty) {
      _busy = true;
      if (mounted) {
        setState(() {});
      }
    }
    final request = await _dio.get("$serverURL/get/$_phone");
    if (request.statusCode == 200) {
      final response = request.data;
      try {
        // final body = jsonDecode(response);
        if (response["status"] == "success") {
          _images = response["data"];
          log(_images.toString());
          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        log("erorr" + e.toString());
      }
    }
    _busy = false;
    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> _buildImageRows() {
    List<Widget> rows = [
      const SizedBox(
        height: 10,
      )
    ];
    for (int i = 0; i < _images.length; i += 3) {
      List<Widget> rowChildren = [];
      for (int j = i; j < i + 3 && j < _images.length; j++) {
        rowChildren.add(
          SizedBox(
            width: 100,
            height: 100,
            child: CachedNetworkImage(
              imageUrl: _images[j],
              fit: BoxFit.cover,
            ),
          ),
        );
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: rowChildren,
      ));
      rows.add(SizedBox(height: 8.0)); // Add some space between rows
    }
    return rows;
  }

  Future<void> _logout() async {
    Globals.phone = "";
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
        (route) => false);
  }

  @override
  void dispose() {
    _faceSdk.deinitialize();
    super.dispose();
  }

  Future<void> _ui() async {
    _faceSdk.customization.colors.cameraScreenFrontHintLabelText = Colors.white;
    _faceSdk.customization.colors.cameraScreenFrontHintLabelBackground =
        Colors.black;
    _faceSdk.customization.fonts.cameraScreenHintLabel =
        Font("sans-serif", size: 20);

    // _faceSdk.localizationDictionary = {
    //   "hint.addIllumination": "Add illumination",
    //   "hint.fit2": "Center your face",
    //   "hint.lookStraight": "Look straight",
    //   "hint.moveAway": "Move away",
    //   "hint.moveCloser": "Move closer",
    //   "hint.stayStill": "Hold steady",
    //   "hint.turnHead": "Turn your head a bit",
    //   "livenessDone.status": "Done!",
    //   "livenessGuide.button": "Go",
    //   "livenessGuide.head": "Selfie time!",
    //   "livenessProcessing.title.processing": "Processing...",
    //   "livenessRetry.action.retry": "Retry",
    //   "livenessRetry.text.environment":
    //       "Ambient lighting is not too bright or too dark and there are no shadows or glare on your face",
    //   "livenessRetry.text.guidelines": "But please follow these guidelines:",
    //   "livenessRetry.text.subject":
    //       "Neutral facial expression (no smiling, eyes open and mouth closed), no mask, sunglasses or headwear",
    //   "livenessRetry.title.tryAgain": "Let’s try that again",
    //   "livenssStart.promptText.cameraLevel": "Camera at eye level.",
    //   "livenssStart.promptText.getReady": "Get ready",
    //   "livenssStart.promptText.illumination": "Good illumination.",
    //   "livenssStart.promptText.noAccessories":
    //       "No accessories: glasses, mask, hat, etc.",
    //   "noCameraPermission.title.unavailable": "Camera unavailable!",
    //   "strAccessibilityCloseButton": "Close",
    //   "strAccessibilitySwapCameraButton": "The Switch Camera button",
    //   "strAccessibilityTorchButton": "Torch"
    // };
  }

  Future<void> _initFaceSdk() async {
    await _faceSdk.initialize();
    _faceSdk.localizationDictionary = {
      "hint.addIllumination": "Add more light",
      "hint.fit2": "Center your face",
      "hint.lookStraight": "Look straight ahead",
      "hint.moveAway": "Step back",
      "hint.moveCloser": "Move closer",
      "hint.stayStill": "Stay still",
      "hint.turnHead": "Turn your head a bit",
      "livenessDone.status": "Done!",
      "livenessGuide.button": "Go",
      "livenessGuide.head": "Selfie time!",
      "livenessProcessing.title.processing": "Processing...",
      "livenessRetry.action.retry": "Retry",
      "livenessRetry.text.environment":
          "Make sure the lighting is not too bright or too dark and there are no shadows or glare on your face",
      "livenessRetry.text.guidelines": "But please follow these guidelines:",
      "livenessRetry.text.subject":
          "Keep a neutral facial expression (no smiling, eyes open and mouth closed), and don’t wear a mask, sunglasses, or headwear",
      "livenessRetry.title.tryAgain": "Let’s try that again",
      "livenssStart.promptText.cameraLevel": "Keep the camera at eye level.",
      "livenssStart.promptText.getReady": "Get ready",
      "livenssStart.promptText.illumination": "Make sure the lighting is good.",
      "livenssStart.promptText.noAccessories":
          "Don’t wear accessories like glasses, mask, hat, etc.",
      "noCameraPermission.title.unavailable": "Camera unavailable!",
      "strAccessibilityCloseButton": "Close",
      "strAccessibilitySwapCameraButton": "Switch Camera",
      "strAccessibilityTorchButton": "Torch"
    };
  }
}
