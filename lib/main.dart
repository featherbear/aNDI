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

  int _renderedFramesCount = 0;
  bool processingReady = true;

  List<NDISource>? _sources;

  Future<void> _doFindNDI() async {
    await FlutterNdi.initPlugin();
    var sources = FlutterNdi.findSources();

    setState(() {
      _sources = sources;
    });
  }

  ReceivePort? activeSource;

  Future<void> _connectNDI(NDISource source) async {
    if (activeSource != null) {
      debugPrint("Disconnecting from previous NDI source");
      FlutterNdi.stopListen(activeSource!);
    }

    debugPrint("Connecting to NDI source: ${source.name}");

    _renderedFramesCount = 0;

    // https://medium.com/@hugand/capture-photos-from-camera-using-image-stream-with-flutter-e9af94bc2bee

    final pair = await FlutterNdi.subscribe(
        source: source, bandwidth: NDIBandwidth.full);
    activeSource = pair.item1;
    final controlPort = pair.item2;

    activeSource!.cast<VideoFrameData>().listen((frame) async {
      displaySource = await VideoFrameData_to_Image(frame);
      _renderedFramesCount++;

      controlPort.send(true);

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
            Text(_renderedFramesCount.toString()),
            ...((_sources != null)
                ? (_sources!.isNotEmpty
                    ? _sources!
                        .map((source) => ElevatedButton(
                              onPressed: () => {_connectNDI(source)},
                              child: Text("${source.name} (${source.address})"),
                            ))
                        .toList()
                    : [Text("No sources found")])
                : [Text("Begin by searching for sources")])
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
