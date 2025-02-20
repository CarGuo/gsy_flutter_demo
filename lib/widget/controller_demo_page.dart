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
      body: const DefaultTabController(
          length: 3,
          child: TabBarView(
            //physics: const BouncingScrollPhysics(),
            children: [
              EditPage(),
              EditPage(),
              EditPage(),
            ],
          )),
    );
  }
}

class EditPage extends StatelessWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ListTile(
          title: Text("Title"),
          subtitle: Text("Subtitle"),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        Container(
          color: Colors.red,
          alignment: Alignment.center,
          height: 40,
          child: const Text("FFFF"),
        ),
        Container(
          color: Colors.red,
          alignment: Alignment.center,
          height: 40,
          child: const Text("FFFF"),
        )
      ],
    );
  }
}
