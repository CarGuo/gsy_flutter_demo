import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/stick/stick_widget.dart';

class StickDemoPage extends StatefulWidget {
  const StickDemoPage({super.key});

  @override
  _StickDemoPageState createState() => _StickDemoPageState();
}

class _StickDemoPageState extends State<StickDemoPage> {
  @override
  Widget build(_) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("StickDemoPage"),
      ),
      body: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 100,
          itemBuilder: (context, index) {
            return Container(
              height: 200,
              color: Colors.deepOrange,
              child: StickWidget(
                ///header
                stickHeader: Container(
                  height: 50.0,
                  color: Colors.deepPurple,
                  padding: const EdgeInsets.only(left: 10.0),
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      if (kDebugMode) {
                        print("header");
                      }
                    },
                    child: Text(
                      '我的 $index 头啊',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                ///content
                stickContent: InkWell(
                  onTap: () {
                    if (kDebugMode) {
                      print("content");
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    color: Colors.pinkAccent,
                    height: 150,
                    child: Center(
                      child: Text(
                        '我的$index 内容 啊',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
