import 'dart:math' as math;

import 'package:flutter/material.dart';

///通过 CustomMultiChildLayout 自定义控件
class CustomMultiRenderDemoPage extends StatefulWidget {
  @override
  _CustomMultiRenderDemoPageState createState() =>
      _CustomMultiRenderDemoPageState();
}

class _CustomMultiRenderDemoPageState extends State<CustomMultiRenderDemoPage> {
  ///用于 LayoutId 指定
  ///CircleLayoutDelegate 操作具体 Child 的 ChildId 是通过 LayoutId 指定的
  List customLayoutId = ["0", "1", "2", "3", "4"].toList();

  @override
  Widget build(BuildContext context) {
    double childSize = 66;
    return Scaffold(
      appBar: AppBar(
        title: new Text("CustomMultiRenderDemoPage"),
      ),
      body: new Center(
        child: new Container(
          color: Colors.greenAccent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,

          ///使用 CustomMultiChildLayout
          child: CustomMultiChildLayout(
            ///使用 CircleLayoutDelegate 实现 child 的布局
            delegate: CircleLayoutDelegate(customLayoutId as List<String>,

                ///这里外部指定 child 的大小
                childSize: Size(childSize, childSize),

                ///中心点位置
                center: Offset(MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.width / 2)),
            children: <Widget>[
              ///使用 LayoutId 指定 childId
              for (var item in customLayoutId)
                new LayoutId(id: item, child: ContentItem(item, childSize)),
            ],
          ),
        ),
      ),
      persistentFooterButtons: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.amberAccent,
          ),
          onPressed: () {
            setState(() {
              customLayoutId.add("${customLayoutId.length}");
            });
          },
          child: new Text(
            "加",
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.indigoAccent),
          onPressed: () {
            setState(() {
              if (customLayoutId.length > 1) {
                customLayoutId.removeLast();
              }
            });
          },
          child: new Text(
            "减",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

///自定义实现圆形布局
class CircleLayoutDelegate extends MultiChildLayoutDelegate {
  final List<String> customLayoutId;

  final Offset center;

  Size? childSize;

  CircleLayoutDelegate(this.customLayoutId,
      {this.center = Offset.zero, this.childSize});

  @override
  void performLayout(Size size) {
    for (var item in customLayoutId) {
      if (hasChild(item)) {
        double r = 100;

        int index = int.parse(item);

        double step = 360 / customLayoutId.length;

        double hd = (2 * math.pi / 360) * step * index;

        var x = center.dx + math.sin(hd) * r;

        var y = center.dy - math.cos(hd) * r;

        childSize ??= Size(size.width / customLayoutId.length,
            size.height / customLayoutId.length);

        ///设置 child 大小
        layoutChild(item, BoxConstraints.loose(childSize!));

        final double centerX = childSize!.width / 2.0;

        final double centerY = childSize!.height / 2.0;

        var result = new Offset(x - centerX, y - centerY);

        ///设置 child 位置
        positionChild(item, result);
      }
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}

///child
class ContentItem extends StatelessWidget {
  final String text;

  final double childSize;

  ContentItem(this.text, this.childSize);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(childSize / 2.0),
      child: InkWell(
        radius: childSize / 2.0,
        customBorder: CircleBorder(),
        onTap: () {},
        child: Container(
          width: childSize,
          height: childSize,
          child: Center(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
