import 'dart:typed_data';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';

Future<Image> Uint8List_to_Image(List imageData) async {
  final Uint8List data = imageData[0];
  final int width = imageData[1];
  final int height = imageData[2];
  return Image.memory(Bitmap.fromHeadless(width, height, data).buildHeaded());

  // http://5.9.10.113/63714281/flutter-convert-raw-image-data-to-display-image-on-app
}
