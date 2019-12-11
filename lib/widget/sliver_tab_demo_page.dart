import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverTabDemoPage extends StatefulWidget {
  @override
  _SliverTabDemoPageState createState() => _SliverTabDemoPageState();
}

class _SliverTabDemoPageState extends State<SliverTabDemoPage>
    with TickerProviderStateMixin {
  TabController tabController;

  final int tabLength = 4;
  final double maxHeight = kToolbarHeight;
  final double minHeight = 30;
  final double tabIconSize = 30;

  List<Widget> renderTabs(double shrinkOffset) {
    double offset = (shrinkOffset > tabIconSize) ? tabIconSize : shrinkOffset;
    return List.generate(tabLength, (index) {
      return Column(
        children: <Widget>[
          Opacity(
            opacity: 1 - offset / tabIconSize,
            child: Icon(
              Icons.map,
              size: tabIconSize - offset,
            ),
          ),
          new Expanded(
            child: new Center(
              child: new Text(
                "Tab$index",
              ),
            ),
          )
        ],
      );
    });
  }

  @override
  void initState() {
    tabController = new TabController(length: tabLength, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("SliverTabDemoPage"),
      ),
      body: new Container(
        child: new CustomScrollView(
          slivers: <Widget>[
            ///动态放大缩小的tab控件
            SliverPersistentHeader(
              pinned: true,

              /// SliverPersistentHeaderDelegate 的实现
              delegate: GSYSliverHeaderDelegate(
                  maxHeight: maxHeight,
                  minHeight: minHeight,
                  changeSize: true,
                  snapConfig: FloatingHeaderSnapConfiguration(
                    vsync: this,
                    curve: Curves.bounceInOut,
                    duration: const Duration(milliseconds: 10),
                  ),
                  builder: (BuildContext context, double shrinkOffset,
                      bool overlapsContent) {
                    return Container(
                      height: maxHeight,
                      color: Colors.blue,
                      child: TabBar(
                        indicatorColor: Colors.cyanAccent,
                        unselectedLabelColor: Colors.white.withAlpha(100),
                        labelColor: Colors.cyanAccent,
                        controller: tabController,
                        tabs: renderTabs(shrinkOffset),
                      ),
                    );
                  }),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Card(
                    child: new Container(
                      height: 60,
                      alignment: Alignment.centerLeft,
                      child: new Text("Item $index"),
                    ),
                  );
                },
                childCount: 30,
              ),
            )
          ],
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
