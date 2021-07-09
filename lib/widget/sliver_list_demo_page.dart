import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as W;
import 'package:flutter/rendering.dart';

class SliverListDemoPage extends StatefulWidget {
  @override
  _SliverListDemoPageState createState() => _SliverListDemoPageState();
}

class _SliverListDemoPageState extends State<SliverListDemoPage>
    with SingleTickerProviderStateMixin {
  int listCount = 30;

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      ///头部信息
      SliverPersistentHeader(
        delegate: GSYSliverHeaderDelegate(
          maxHeight: 180,
          minHeight: 180,
          vSync: this,
          snapConfig: FloatingHeaderSnapConfiguration(
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 10),
          ),
          child: new Container(
            color: Colors.redAccent,
          ),
        ),
      ),
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverPersistentHeader(
          pinned: true,

          /// SliverPersistentHeaderDelegate 的实现
          delegate: GSYSliverHeaderDelegate(
              maxHeight: 60,
              minHeight: 60,
              changeSize: true,
              vSync: this,
              snapConfig: FloatingHeaderSnapConfiguration(
                curve: Curves.bounceInOut,
                duration: const Duration(milliseconds: 10),
              ),
              builder: (BuildContext context, double shrinkOffset,
                  bool overlapsContent) {
                ///根据数值计算偏差
                var lr = 10 - shrinkOffset / 60 * 10;
                return SizedBox.expand(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: 10, left: lr, right: lr, top: lr),
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Expanded(
                          child: new Container(
                            alignment: Alignment.center,
                            color: Colors.orangeAccent,
                            child: new TextButton(
                              onPressed: () {
                                setState(() {
                                  listCount = 30;
                                });
                              },
                              child: new Text("按键1"),
                            ),
                          ),
                        ),
                        new Expanded(
                          child: new Container(
                            alignment: Alignment.center,
                            color: Colors.orangeAccent,
                            child: new TextButton(
                              onPressed: () {
                                setState(() {
                                  listCount = 4;
                                });
                              },
                              child: new Text("按键2"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("SliverListDemoPage"),
      ),
      body: new Container(
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: _sliverBuilder,
          body: CustomScrollView(
            slivers: [
              W.Builder(
                builder: (context) {
                  return SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context));
                },
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Card(
                      child: new Container(
                        height: 60,
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: new Text("Item $index"),
                      ),
                    );
                  },
                  childCount: 100,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///动态头部处理
class GSYSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  GSYSliverHeaderDelegate(
      {required this.minHeight,
      required this.maxHeight,
      required this.snapConfig,
      required this.vSync,
      this.child,
      this.builder,
      this.changeSize = false});

  final double minHeight;
  final double maxHeight;
  final Widget? child;
  final Builder? builder;
  final bool changeSize;
  final TickerProvider vSync;
  final FloatingHeaderSnapConfiguration snapConfig;
  AnimationController? animationController;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  TickerProvider get vsync => vSync;

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
