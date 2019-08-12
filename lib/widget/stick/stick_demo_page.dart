import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/stick/stick_widget.dart';

class StickDemoPage extends StatefulWidget {
  @override
  _StickDemoPageState createState() => _StickDemoPageState();
}

class _StickDemoPageState extends State<StickDemoPage> {
  @override
  Widget build(_) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StickDemoPage"),
      ),
      body: Container(
        child: new ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: 100,
            itemBuilder: (context, index) {
              return new Container(
                height: 200,
                color: Colors.deepOrange,
                child: new StickWidget(
                  ///header
                  stickHeader: new Container(
                    height: 50.0,
                    color: Colors.deepPurple,
                    padding: new EdgeInsets.only(left: 10.0),
                    alignment: Alignment.centerLeft,
                    child: new InkWell(
                      onTap: () {
                        print("header");
                      },
                      child: new Text(
                        '我的 $index 头啊',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  ///content
                  stickContent: new InkWell(
                    onTap: () {
                      print("content");
                    },
                    child: new Container(
                      margin: EdgeInsets.only(left: 10),
                      color: Colors.pinkAccent,
                      height: 150,
                      child: new Center(
                        child: new Text(
                          '我的$index 内容 啊',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
