import 'dart:typed_data';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ndi/flutter_ndi.dart';

Future<Image> VideoFrameData_to_Image(VideoFrameData frame) async {
  return Image.memory(
      Bitmap.fromHeadless(frame.width, frame.height, frame.data).buildHeaded());

  // http://5.9.10.113/63714281/flutter-convert-raw-image-data-to-display-image-on-app
}
