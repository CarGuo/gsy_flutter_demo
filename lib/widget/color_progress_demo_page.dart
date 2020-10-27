import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class ColorProgressDemoPage extends StatefulWidget {
  @override
  _ColorProgressDemoPageState createState() => _ColorProgressDemoPageState();
}

class _ColorProgressDemoPageState extends State<ColorProgressDemoPage> {
  List<Gradient> colorList = [
    LinearGradient(
      begin: Alignment(0.52576, 0.80444),
      end: Alignment(0.52576, 0.20356),
      stops: [
        0,
        1,
      ],
      colors: [
        Color.fromARGB(255, 255, 228, 166),
        Color.fromARGB(255, 255, 216, 152),
      ],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [
        0,
        0.31865,
        0.5038,
        0.71541,
        1,
      ],
      colors: [
        Color.fromARGB(255, 133, 102, 30),
        Color.fromARGB(0, 133, 101, 30),
        Color.fromARGB(0, 133, 101, 30),
        Color.fromARGB(67, 133, 101, 30),
        Color.fromARGB(255, 133, 101, 30),
      ],
    ),
    LinearGradient(
      begin: Alignment(1, 0.5),
      end: Alignment(0.5857, 0.5),
      stops: [
        0,
        1,
      ],
      colors: [
        Color.fromARGB(255, 255, 255, 255),
        Color.fromARGB(0, 255, 185, 53),
      ],
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("data"),
      ),
      backgroundColor: Colors.grey,
      body: Center(
        child: Container(
          color: Colors.grey,
          alignment: Alignment.center,
          child: ColorProgress(
            colorList: colorList,
          ),
        ),
      ),
    );
  }
}

class ColorProgress extends StatefulWidget {
  final Color backgroundColor;
  final List<Gradient> colorList;

  ColorProgress({this.colorList, this.backgroundColor = Colors.black});

  @override
  _ColorProgressState createState() => _ColorProgressState();
}

class _ColorProgressState extends State<ColorProgress> {
  List<Widget> renderColorList() {
    List<Widget> widgetList = new List();
    widget.colorList?.forEach((element) {
      widgetList.add(
        Container(
          decoration: BoxDecoration(
            gradient: element,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          child: Container(),
        ),
      );
    });
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: 177,
        height: 9,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
        ),
        child: Stack(
          children: [
            ClipRect(
              child: OverflowBox(
                minHeight: 15,
                maxHeight: 15,
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Container(
                    width: 100,
                    child: Stack(
                      overflow: Overflow.visible,
                      alignment: Alignment.center,
                      children: renderColorList(),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
