import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String link = '';
  String directoryPath = '';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    initDownloadsDirectoryState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initDownloadsDirectoryState() async {
    List<Directory>? downloadsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      downloadsDirectory = await getExternalStorageDirectories();
    } on PlatformException {
      print('Could not get the downloads directory');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      directoryPath =
          '${downloadsDirectory![0].parent.parent.parent.parent.path}/Download';
    });
  }

  void _requestDownload(String link) async {
    setState(() {
      _isDownloading = true;
    });
    List<String> _splited = link.split('/');
    String saveName = _splited[_splited.length - 1];
    String savePath = '$directoryPath/$saveName';
    print(savePath);
    //output:  /storage/emulated/0/Download/banner.png

    try {
      await Dio().download(link, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print((received / total * 100).toStringAsFixed(0) + '%');
          //you can build progressbar feature too
        }
      });
      print("File is saved to download folder.");
    } on DioError catch (e) {
      print(e.message);
    } catch (error) {
      rethrow;
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                directoryPath != ''
                    ? 'Downloads directory: $directoryPath'
                    : 'Could not get the downloads directory',
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => link = value,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _requestDownload(link),
                child: const Text('Download'),
              ),
              if (_isDownloading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                const Text('File is downloading'),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
