import 'package:flutter/material.dart';

class TextSizeDemoPage extends StatefulWidget {
  @override
  _TextSizeDemoPageState createState() => _TextSizeDemoPageState();
}

class _TextSizeDemoPageState extends State<TextSizeDemoPage> {
  TextScaler textScaler = TextScaler.noScaling;
  int scale = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQueryData.fromView(
                WidgetsBinding.instance.platformDispatcher.views.first)
            .copyWith(textScaler: textScaler),
        child: Scaffold(
          appBar: AppBar(
            title: new Text("TextLineHeightDemoPage"),
          ),
          body: new Stack(
            children: <Widget>[
              Container(
                color: Colors.blueGrey,
                margin: EdgeInsets.all(20),

                ///利用 Transform 偏移将对应权重部分位置
                child: new Text(
                  textContent,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              new Align(
                alignment: Alignment.bottomCenter,
                child: new Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new TextButton(
                        onPressed: () {
                          if (scale > 1) {
                            setState(() {
                              textScaler.scale(scale - 1);
                              scale--;
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        child: new Text("-"),
                      ),
                      new SizedBox(
                        width: 10,
                      ),
                      new TextButton(
                        onPressed: () {
                          setState(() {
                            textScaler.scale(scale + 1);
                            scale++;
                          });
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.greenAccent),
                        child: new Text("+"),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

const textContent =
    "Today I was amazed to see the usually positive and friendly VueJS community descend into a bitter war. Two weeks ago Vue creator Evan You released a Request for Comment (RFC) for a new function-based way of writing Vue components in the upcoming Vue 3.0. Today a critical "
    "Reddit thread followed by similarly "
    "critical comments in a Hacker News thread caused a "
    "flood of developers to flock to the original RFC to "
    "voice their outrage, some of which were borderline abusive. "
    "It was claimed in various places that";
