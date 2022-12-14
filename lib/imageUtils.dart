import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ndi/flutter_ndi.dart';
import 'dart:ui' as ui;

typedef RGBAFrame = Uint8List;

Future<RawImage> VideoFrameData_to_Image(VideoFrameData frame) async {
  Completer<RawImage> completer = new Completer();

  ui.decodeImageFromPixels(
      frame.data, frame.width, frame.height, ui.PixelFormat.bgra8888, (result) {
    completer.complete(RawImage(image: result));
  });

  return completer.future;
}
