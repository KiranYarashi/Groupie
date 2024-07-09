import 'package:flutter/material.dart';
import 'package:groupchat/download.dart';
import 'package:groupchat/widgets/widgets.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class MyHomePage extends StatefulWidget {
  final String file;
  MyHomePage({Key? key, required this.title, required this.file})
      : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SfPdfViewer.network(widget.file,
            controller: _pdfViewerController, key: _pdfViewerStateKey),
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _pdfViewerStateKey.currentState!.openBookmarkView();
              },
              icon: Icon(
                Icons.bookmark,
                color: Colors.blue,
              ),
            ),
            IconButton(
              onPressed: () {
                _pdfViewerController.jumpToPage(5);
              },
              icon: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.blue,
              ),
            ),
            IconButton(
              onPressed: () {
                _pdfViewerController.zoomLevel = 1.25;
              },
              icon: Icon(
                Icons.zoom_in,
                color: Colors.blue,
              ),
            ),
            IconButton(
              onPressed: () {
                nextScreen(context, Download());
              },
              icon: Icon(
                Icons.download,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
