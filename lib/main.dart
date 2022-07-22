// main.dart
import 'dart:convert';
import 'dart:ffi';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:read_csv/func.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MonkeyPox Statistics',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _writeDataD();
      _readData();
    });
  }

  // This will be displayed on the screen
  int cnt=0;
  List<Widget> list = [];
  List<Widget> listtmp = [];
  final _scrollController = ScrollController();
  // Find the Documents path
  Future<String> _getDirPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<List<String>> loadAsset() async {
    listtmp = [];
    final dirPath = await _getDirPath();
    final myFile = File('$dirPath/tmp.csv');
    final myData = await myFile.readAsString(encoding: utf8);
    print('Myfile');
    //var myData = await rootBundle.loadString("$dirPath/tmp.csv");
    List<List<dynamic>> csvTable = await CsvToListConverter(eol: '\n').convert(myData);
    print('Ready');
    //
    listtmp.add(
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Country"),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Total"),
            ),
            /*Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Add by day"),
                  ),*/
          ],
        )
    );
    List<String> data = [];
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    csvTable.forEach((value) {
      if(value[0]==formattedDate) {
        cnt++;
      }
    });
    if (cnt==0){
      DateTime now = DateTime.now().subtract(Duration(days:1));
      formattedDate = DateFormat('yyyy-MM-dd').format(now);
    }
    csvTable.forEach((value) {
      if(value[0]==formattedDate){
        print(value[3].toString());
        Country tmp = countries.firstWhere((element) => element.fullName == value[3], orElse: () {return Country('🇦🇷','Argentina');});
        print(tmp.toString());
        listtmp.add(
            Card(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${tmp.shortName}"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${value[3]}"),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${value[2]}"),
                  ),
                  /*Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${value[1]}"),
                  ),*/
                  //Flexible(child: Text(" +${value[1]}")),
                ],
              ),
            )
        );
        data.add(value.toString());
      }
    });

    print(data.length);
    return data;
  }

  // This function is triggered when the "Read" button is pressed
  Future<void> _readData() async {
    //final myFile = File('$dirPath/tmp.csv');
    //final data = await myFile.readAsString(encoding: utf8);
    final data  = await loadAsset();

    setState(() {
      list = listtmp;
    });
  }

  // TextField controller
  final _textController = TextEditingController();
  // This function is triggered when the "Write" buttion is pressed
  Future<void> _writeData() async {
    final _dirPath = await _getDirPath();

    //final _myFile = File('$_dirPath/data.txt');
    final _myFile = File('$_dirPath/tmp.csv');
    // If data.txt doesn't exist, it will be created automatically

    await _myFile.writeAsString(_textController.text);
    _textController.clear();
  }
  static var httpClient = new HttpClient();

  Future<void> _writeDataD() async {

    Future<File> _downloadFile(String url, String filename) async {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = await _getDirPath();
      print('$dir');
      File file = new File('$dir/$filename');
      await file.writeAsBytes(bytes);
      print('DONE DOWNLOAD');
      return file;
    }
    await _downloadFile('https://raw.githubusercontent.com/globaldothealth/monkeypox/main/timeseries-country-confirmed.csv', 'tmp.csv');

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MonkeyPox Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: list,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}