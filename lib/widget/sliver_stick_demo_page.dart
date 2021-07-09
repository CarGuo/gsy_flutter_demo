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

class _SliverStickListDemoPageState extends State<SliverStickListDemoPage> {
  ScrollController scrollController = new ScrollController();

  List<Widget> slivers = [];

  ///header高度
  final double headerHeight = 60;

  ///内容高度
  final double contentHeight = 120;

  void initItem() {
    slivers.clear();
    for (var i = 0; i < 50; i++) {
      slivers.add(
        SliverHeaderItem(
          i,
          child: new Container(
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
          headerHeight: headerHeight,
          contentHeight: contentHeight,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        initItem();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("SliverListDemoPage"),
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

class SliverHeaderItem extends StatefulWidget {
  final int index;

  final Widget child;

  ///header高度
  final double headerHeight;

  ///内容高度
  final double contentHeight;

  SliverHeaderItem(this.index,
      {required this.child, this.headerHeight = 60, this.contentHeight = 120});

  @override
  _SliverHeaderItemState createState() => _SliverHeaderItemState();
}

class _SliverHeaderItemState extends State<SliverHeaderItem>
    with SingleTickerProviderStateMixin {
  scrollListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    ///监听列表改变
    Future.delayed(Duration(seconds: 0), () {
      Scrollable.of(context)!.position.addListener(scrollListener);
    });
  }

  @override
  void deactivate() {
    Scrollable.of(context)!.position.removeListener(scrollListener);
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: GSYSliverHeaderDelegate(
          maxHeight: widget.headerHeight,
          minHeight: widget.headerHeight,
          vSync: this,
          snapConfig: FloatingHeaderSnapConfiguration(
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 10),
          ),
          builder: (context, shrinkOffset, overlapsContent) {
            var state = Scrollable.of(context)!;

            ///整个 item 的大小
            var itemHeight = widget.headerHeight + widget.contentHeight;

            ///当前顶部的位置
            var position = state.position.pixels ~/ itemHeight;

            ///当前和挂着的 header 相邻的 item 位置
            var offsetPosition =
                (state.position.pixels + widget.headerHeight) ~/ itemHeight;

            ///当前和挂着的 header 相邻的 item ，需要改变的偏移
            var changeOffset =
                state.position.pixels - offsetPosition * itemHeight;

            /// header 动态显示需要的高度
            var height = offsetPosition == (widget.index + 1)
                ? (changeOffset < 0) ? -changeOffset : widget.headerHeight
                : widget.headerHeight;

            return Visibility(
              visible: (position <= widget.index),
              child: new Transform.translate(
                offset: Offset(0, -(widget.headerHeight - height)),
                child: widget.child,
              ),
            );
          }),
    );
  }
}

///动态头部处理
class GSYSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  GSYSliverHeaderDelegate(
      {required this.minHeight,
      required this.maxHeight,
      required this.snapConfig,
      this.child,
      this.builder,
      this.vSync,
      this.changeSize = false});

  final double minHeight;
  final double maxHeight;
  final Widget? child;
  final Builder? builder;
  final TickerProvider? vSync;
  final bool changeSize;
  final FloatingHeaderSnapConfiguration snapConfig;
  AnimationController? animationController;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);


  @override
  TickerProvider? get vsync => vSync;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (builder != null) {
      return builder!(context, shrinkOffset, overlapsContent);
    }
    return child!;
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
