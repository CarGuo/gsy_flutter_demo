import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class DragImgDemoPage extends StatefulWidget {
  @override
  _DragImgDemoPageState createState() => _DragImgDemoPageState();
}

class _DragImgDemoPageState extends State<DragImgDemoPage> {

  Matrix4 transform = Matrix4.diagonal3Values(1, 1, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("DragImgDemoPage"),
      ),
      body: new Container(
        child: MatrixGestureDetector(
          onMatrixUpdate: (m, tm, sm, rm) {
            setState(() {
              transform = m;
            });
          },
          child: Transform(
              transform: transform,
              child: new Image.asset(
                "static/gsy_cat.png",
                fit: BoxFit.fitWidth,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
              )
          ),
        ),
      ),
    );
  }
}
