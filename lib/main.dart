import 'dart:async';

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
  String _sources = "No sources.";

  Widget X = Text("-not init-");
  int _ncount = 0;

  Future<void> _doNDI() async {
    await FlutterNdi.initPlugin();
    var res = FlutterNdi.findSources();

// https://medium.com/@hugand/capture-photos-from-camera-using-image-stream-with-flutter-e9af94bc2bee

    if (res.isNotEmpty) {
      FlutterNdi.listenToFrameData(res.first).cast<VideoFrameData>()
          // .cast<Future<void> Function(Future<void> Function(VideoFrameData))>()
          .listen((frame) async {
        _ncount++;
        X = await compute(VideoFrameData_to_Image, frame);
        setState(() {});
      });

      setState(() {
        _sources = res
            .map((e) => e.address)
            .reduce((value, element) => value + "\n" + element);
      });
    } else {
      X = Text("No source found");
      setState(() {});
    }
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
            X,
            Text(_ncount.toString()),
            Text(_sources),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _doNDI,
        tooltip: 'Start',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
