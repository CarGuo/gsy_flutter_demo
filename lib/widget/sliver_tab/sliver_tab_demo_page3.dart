import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gsy_flutter_demo/widget/sliver_tab/sliver_tab_child_page.dart';

const kMinHeight = 30.0;

/// 高级版 Sliver Tab
class SliverTabDemoPage3 extends StatefulWidget {
  const SliverTabDemoPage3({super.key});

  @override
  _SliverTabDemoPageState createState() => _SliverTabDemoPageState();
}

class _SliverTabDemoPageState extends State<SliverTabDemoPage3>
    with TickerProviderStateMixin {
  TabController? tabController;

  final PageController pageController = PageController();
  final int tabLength = 4;
  final double tabIconSize = 30;
  final List<List> dataList = [
    List.filled(30, null),
    List.filled(2, null),
    List.filled(8, null),
    List.filled(40, null),
  ];

  double minHeight = kToolbarHeight;
  double shrinkOffset = 0;

  final ScrollController controller =
      ScrollController(initialScrollOffset: -70);

  List<Widget> renderTabs(double shrinkOffset) {
    double offset = (shrinkOffset > tabIconSize) ? tabIconSize : shrinkOffset;
    if (minHeight == kToolbarHeight) {
      offset = 0;
    }
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
          Expanded(
            child: Center(
              child: Text(
                "Tab$index",
              ),
            ),
          )
        ],
      );
    });
  }

  List<Widget> renderPages() {
    return List.generate(dataList.length, (index) {
      return SliverTabChildPage(index, dataList[index]);
    });
  }

  @override
  void initState() {
    tabController = TabController(length: tabLength, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SliverTabDemoPage3"),
      ),
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics is PageMetrics) {
            return false;
          }
          if (notification.metrics is FixedScrollMetrics) {
            if (notification.metrics.axisDirection == AxisDirection.left ||
                notification.metrics.axisDirection == AxisDirection.right) {
              return false;
            }
          }
          if (notification is UserScrollNotification) {
            if (notification.direction == ScrollDirection.idle) {
              if (notification.metrics.pixels <= 0) {
                minHeight = kToolbarHeight;
                shrinkOffset = 0;
                setState(() {});
              } else {
                minHeight = kMinHeight;
                shrinkOffset = kMinHeight;
                setState(() {});
              }
            }
          } else if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels < 0 &&
                minHeight != kToolbarHeight) {
              var cur = minHeight - notification.metrics.pixels / 3;
              if (shrinkOffset > 0) {
                shrinkOffset =
                    (shrinkOffset + notification.metrics.pixels / 3).abs();
              }
              if (cur > kToolbarHeight) {
                cur = kToolbarHeight;
              }
              if (minHeight != cur) {
                minHeight = cur.abs();
                setState(() {});
              }
            } else if (notification.metrics.pixels >= 0 &&
                minHeight != kMinHeight) {
              var cur = kToolbarHeight - notification.metrics.pixels / 2;
              shrinkOffset = notification.metrics.pixels / 2;
              if (minHeight != cur) {
                minHeight = (cur > kMinHeight) ? cur : kMinHeight;
                setState(() {});
              }
            }
          }
          return false;
        },
        child: Column(
          children: <Widget>[
            Container(
              height: minHeight,
              color: Colors.blue,
              child: TabBar(
                controller: tabController,
                indicatorColor: Colors.cyanAccent,
                unselectedLabelColor: Colors.white.withAlpha(100),
                labelColor: Colors.cyanAccent,
                tabs: renderTabs(shrinkOffset),
                onTap: (index) {
                  setState(() {});
                  pageController.jumpToPage(index);
                },
              ),
            ),
            Expanded(
              child: PageView(
                //physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  tabController!.animateTo(index);
                },
                controller: pageController,
                children: renderPages(),
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
      {required this.minHeight,
      required this.maxHeight,
      required this.snapConfig,
      this.child,
      this.builder,
      this.changeSize = false});

  final double minHeight;
  final double maxHeight;
  final Widget? child;
  final BuilderDelegate? builder;
  final bool changeSize;
  final FloatingHeaderSnapConfiguration snapConfig;
  AnimationController? animationController;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

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

typedef BuilderDelegate = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);
