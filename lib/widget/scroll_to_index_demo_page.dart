import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// 滑动到指定位置
/// 因为官方一直未支持滑动都执行 item
/// 所有有第三方库另辟蹊径
class ScrollToIndexDemoPage extends StatefulWidget {
  const ScrollToIndexDemoPage({super.key});

  @override
  _ScrollToIndexDemoPageState createState() => _ScrollToIndexDemoPageState();
}

class _ScrollToIndexDemoPageState extends State<ScrollToIndexDemoPage> {

  static const maxCount = 100;

  /// pub  scroll_to_index 项目的 controller
  AutoScrollController? controller;

  final random = math.Random();

  final scrollDirection = Axis.vertical;

  late List<List<int>> randomList;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.paddingOf(context).bottom),
        axis: scrollDirection);
    ///一个 index 和 item 高度的数组
    randomList = List.generate(maxCount,
        (index) => <int>[index, (1000 * random.nextDouble()).toInt()]);
  }

  Widget _getRow(int index, double height) {
    return _wrapScrollTag(
        index: index,
        child: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          height: height,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue, width: 4),
              borderRadius: BorderRadius.circular(12)),
          child: Text('index: $index, height: $height'),
        ));
  }

  Widget _wrapScrollTag({required int index, required Widget child}) => AutoScrollTag(
        key: ValueKey(index),
        controller: controller!,
        index: index,
        highlightColor: Colors.black.withOpacity(0.1),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ScrollToIndexDemoPage"),
      ),
      body: ListView(
        scrollDirection: scrollDirection,
        controller: controller,
        children: randomList.map<Widget>((data) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: _getRow(data[0], math.max(data[1].toDouble(), 50.0)),
          );
        }).toList(),
      ),
      persistentFooterButtons: <Widget>[
        TextButton(
          onPressed: () async {
            ///滑动到第13个的位置
            await controller!.scrollToIndex(13,
                preferPosition: AutoScrollPosition.begin);
            controller!.highlight(13);
          },
          child: const Text("Scroll to 13"),
        ),
      ],
    );
  }
}
