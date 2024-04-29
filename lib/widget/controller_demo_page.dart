import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 在 Flutter 中有很多内置的 Controller
/// 大部分内置控件都可以通过 Controller 设置和获取控件参数
/// 比如 TextField 的 TextEditingController
/// 比如 ListView  的 ScrollController
/// 一般想对控件做 OOXX 的事情，先找个 Controller 就对了。
class ControllerDemoPage extends StatelessWidget {
  const ControllerDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("######### MyHomePage ${MediaQuery.of(context).size}");
    }
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
              return const EditPage();
            }));
          },
          child: const Text(
            "Click",
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }
}


class EditPage extends StatelessWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ControllerDemoPage"),
      ),
      extendBody: true,
      body: Column(
        children: [
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(10),
            child: const Center(
              child: TextField(),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}