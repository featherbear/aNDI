import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_ndi/flutter_ndi.dart';
import 'package:flutter_ndi/libndi_bindings.dart';

import 'imageUtils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aNDI',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'aNDI - NDI Tools'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget? displaySource;

  int _receivedFrameCount = 0;
  bool processingReady = true;

  List<NDISource> _sources = [];

  Future<void> _doFindNDI() async {
    await FlutterNdi.initPlugin();
    var sources = FlutterNdi.findSources(); // Find sources in func stack

    setState(() {
      _sources = sources;
    });
  }

  Stream? activeSource;

  Future<void> _connectNDI(NDISource source) async {
    if (activeSource != null) {
      FlutterNdi.stopListen(activeSource as ReceivePort);
    }

    _receivedFrameCount = 0;
    processingReady = true;

    // https://medium.com/@hugand/capture-photos-from-camera-using-image-stream-with-flutter-e9af94bc2bee

    // TODO: Don't process all frames
    // If too many frames are received at the same time, too many compute threads are started

    // https://api.dart.dev/stable/2.13.4/dart-async/StreamConsumer-class.html
    // https://dart.dev/tutorials/language/streams
    // https://dart.academy/streams-and-sinks-in-dart-and-flutter/
    // https://kikt.gitee.io/flutter-doc/dart-async/Stream/pipe.html
    activeSource = FlutterNdi.listenToFrameData(source).cast<VideoFrameData>();

    activeSource!.listen((frame) async {
      _receivedFrameCount++;
      if (processingReady) {
        processingReady = false;

        RGBAFrame frameData = await compute<VideoFrameData, RGBAFrame>(
            VideoFrameData_to_RGBAFrame, frame);

        // https://github.com/flutter/flutter/issues/33641
        displaySource = Image.memory(frameData, gaplessPlayback: true);
        // MemoryImage
        processingReady = true;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            displaySource ?? Text("NDI not started"),
            Text(_receivedFrameCount.toString()),
            // Text(_sources.length.toString())
            ..._sources.isNotEmpty
                ? _sources
                    .map((source) => ElevatedButton(
                          onPressed: () => {_connectNDI(source)},
                          child: Text("${source.name} (${source.address})"),
                        ))
                    .toList()
                : [Text("No sources found")]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _doFindNDI,
        tooltip: 'Find sources',
        child: Icon(Icons.autorenew),
      ),
    );
  }
}
