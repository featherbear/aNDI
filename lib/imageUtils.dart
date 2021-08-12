import 'dart:typed_data';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ndi/flutter_ndi.dart';

typedef RGBAFrame = Uint8List;

Future<Image> VideoFrameData_to_Image(VideoFrameData frame) async {
  return Image.memory(await VideoFrameData_to_RGBAFrame(frame));

  // http://5.9.10.113/63714281/flutter-convert-raw-image-data-to-display-image-on-app
  // https://medium.com/@hugand/capture-photos-from-camera-using-image-stream-with-flutter-e9af94bc2bee
  // https://api.flutter.dev/flutter/painting/ImageStream-class.html
  // https://api.flutter.dev/flutter/painting/ImageProvider-class.html
  // https://github.com/flutter/flutter/issues/26348
  // VideoPlayerController
}

Future<RGBAFrame> VideoFrameData_to_RGBAFrame(VideoFrameData frame) async {
  return Bitmap.fromHeadless(frame.width, frame.height, frame.data)
      .buildHeaded();

  // http://5.9.10.113/63714281/flutter-convert-raw-image-data-to-display-image-on-app
  // https://medium.com/@hugand/capture-photos-from-camera-using-image-stream-with-flutter-e9af94bc2bee
  // https://api.flutter.dev/flutter/painting/ImageStream-class.html
  // https://api.flutter.dev/flutter/painting/ImageProvider-class.html
  // https://github.com/flutter/flutter/issues/26348
  // VideoPlayerController
}
