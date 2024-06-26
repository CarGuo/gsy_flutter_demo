import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 滑动到指定位置 GlobalKey 版本
/// 基于 SingleChildScrollView 和 Column
class ScrollToIndexDemoPage2 extends StatefulWidget {
  const ScrollToIndexDemoPage2({super.key});

  @override
  _ScrollToIndexDemoPageState2 createState() => _ScrollToIndexDemoPageState2();
}

class _ScrollToIndexDemoPageState2 extends State<ScrollToIndexDemoPage2> {
  GlobalKey scrollKey = GlobalKey();

  ScrollController controller = ScrollController();

  List<ItemModel> dataList = [];

  @override
  void initState() {
    dataList.clear();
    for (int i = 0; i < 100; i++) {
      dataList.add(ItemModel(i));
    }
    super.initState();
  }

  _scrollToIndex() {
    var key = dataList[12];

    ///获取 renderBox
    RenderBox renderBox =
        key.globalKey.currentContext!.findRenderObject() as RenderBox;

    ///获取位置偏移，基于 ancestor: SingleChildScrollView 的 RenderObject()
    double dy = renderBox
        .localToGlobal(Offset.zero,
            ancestor: scrollKey.currentContext!.findRenderObject())
        .dy;

    ///计算真实位移
    var offset = dy + controller.offset;

    if (kDebugMode) {
      print("*******$offset");
    }

    controller.animateTo(offset,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ScrollToIndexDemoPage2"),
      ),
      body: SingleChildScrollView(
        key: scrollKey,
        controller: controller,
        child: Column(
          children: dataList.map<Widget>((data) {
            return CardItem(data, key: dataList[data.index].globalKey);
          }).toList(),
        ),
      ),
      persistentFooterButtons: <Widget>[
        TextButton(
          onPressed: () async {
            _scrollToIndex();
          },
          child: const Text("Scroll to 12"),
        ),
      ],
    );
  }
}

class CardItem extends StatelessWidget {
  final random = math.Random();

  final ItemModel data;

  CardItem(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: (300 * random.nextDouble()),
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(5),
          child: Text("Item ${data.index}"),
        ),
      ),
    );
  }
}

class ItemModel {
  ///这个key是关键
  GlobalKey globalKey = GlobalKey();

  ///可以添加你的代码
  final int index;

  ItemModel(this.index);
}
