import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///用 Sliver 的模式实现 Stick
///目前的实现方式就是性能不大好
class SliverStickListDemoPage extends StatefulWidget {
  @override
  _SliverStickListDemoPageState createState() =>
      _SliverStickListDemoPageState();
}

class _SliverStickListDemoPageState extends State<SliverStickListDemoPage>
    with SingleTickerProviderStateMixin {
  bool isTranslate = false;

  ///header高度
  double headerHeight = 60;

  ///内容高度
  double contentHeight = 120;

  ScrollController scrollController = new ScrollController();

  var slivers = List<Widget>();

  void initItem() {
    slivers.clear();
    for (var i = 0; i < 50; i++) {
      slivers.add(
        ///头部信息
        SliverPersistentHeader(
          pinned: true,
          floating: true,
          delegate: GSYSliverHeaderDelegate(
              maxHeight: headerHeight,
              minHeight: headerHeight,
              snapConfig: FloatingHeaderSnapConfiguration(
                vsync: this,
                curve: Curves.bounceInOut,
                duration: const Duration(milliseconds: 10),
              ),
              builder: (context, shrinkOffset, overlapsContent) {
                var state = Scrollable.of(context);

                ///整个 item 的大小
                var itemHeight = headerHeight + contentHeight;

                ///当前顶部的位置
                var position = state.position.pixels ~/ itemHeight;

                ///当前和挂着的 header 相邻的 item 位置
                var offsetPosition =
                    (state.position.pixels + headerHeight) ~/ itemHeight;

                ///当前和挂着的 header 相邻的 item ，需要改变的偏移
                var changeOffset =
                    state.position.pixels - offsetPosition * itemHeight;

                /// header 动态显示需要的高度
                var height = offsetPosition == (i + 1)
                    ? (changeOffset < 0) ? -changeOffset : headerHeight
                    : headerHeight;

                if (isTranslate) {
                  ///越过去就不可见了
                  return Visibility(
                    visible: (position <= i),
                    child: new Transform.translate(
                      offset: Offset(0, -(headerHeight - height)),
                      child: new Container(
                        ///如果把 height 模式 Transform.translate 更有趣
                        height: headerHeight,
                        alignment: Alignment.center,
                        color: Colors.redAccent,
                        child: new Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          height: headerHeight,
                          child: new Text("Header $i"),
                        ),
                      ),
                    ),
                  );
                }

                ///越过去就不可见了
                return Visibility(
                  visible: (position <= i),
                  child: new Container(
                    ///如果把 height 模式 Transform.translate 更有趣
                    height: height,
                    alignment: Alignment.center,
                    color: Colors.redAccent,
                    child: new Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      height: headerHeight,
                      child: new Text("Header $i"),
                    ),
                  ),
                );
              }),
        ),
      );

      ///内容
      slivers.add(
        SliverToBoxAdapter(
          child: new Container(
            height: contentHeight,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            child: new Text("Content $i"),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    ///监听列表改变
    Future.delayed(Duration(seconds: 0), () {
      scrollController.addListener(() {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    initItem();
    return Scaffold(
      appBar: AppBar(
        title: new Text("SliverListDemoPage"),
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.transform),
              onPressed: () {
                setState(() {
                  isTranslate = false;
                });
              }),
          new IconButton(
              icon: Icon(Icons.swap_calls),
              onPressed: () {
                setState(() {
                  isTranslate = true;
                });
              }),
        ],
      ),
      body: new Container(
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: slivers,
        ),
      ),
    );
  }
}

///动态头部处理
class GSYSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  GSYSliverHeaderDelegate(
      {@required this.minHeight,
      @required this.maxHeight,
      @required this.snapConfig,
      this.child,
      this.builder,
      this.changeSize = false});

  final double minHeight;
  final double maxHeight;
  final Widget child;
  final Builder builder;
  final bool changeSize;
  final FloatingHeaderSnapConfiguration snapConfig;
  AnimationController animationController;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (builder != null) {
      return builder(context, shrinkOffset, overlapsContent);
    }
    return child;
  }

  @override
  bool shouldRebuild(GSYSliverHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => snapConfig;
}

typedef Widget Builder(
    BuildContext context, double shrinkOffset, bool overlapsContent);
