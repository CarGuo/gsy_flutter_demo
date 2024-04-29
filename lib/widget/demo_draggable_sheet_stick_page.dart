import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DemoDraggableSheetStickPage extends StatefulWidget {
  const DemoDraggableSheetStickPage({super.key});

  @override
  State<DemoDraggableSheetStickPage> createState() =>
      _DemoDraggableSheetStickPageState();
}

class _DemoDraggableSheetStickPageState
    extends State<DemoDraggableSheetStickPage> {
  @override
  Widget build(BuildContext context) {
    return const DraggableScrollablePage();
  }
}

class DraggableScrollablePage extends StatefulWidget {
  const DraggableScrollablePage({super.key});

  @override
  State<DraggableScrollablePage> createState() =>
      _DraggableScrollablePageState();
}

class _DraggableScrollablePageState extends State<DraggableScrollablePage>
    with SingleTickerProviderStateMixin {
  var controller = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DraggableScrollableSheet'),
      ),
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "static/gsy_cat.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox.expand(
            child: DraggableScrollableSheet(
              controller: controller,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                List<Widget> sliverList(int sliverChildCount) {
                  List<Widget> widgetList = [];
                  widgetList
                    ..add(
                      SliverPersistentHeader(
                        pinned: true,
                        floating: true,
                        delegate: GSYSliverHeaderDelegate(
                          maxHeight: 30,
                          minHeight: 30,
                          vSync: this,
                          snapConfig: FloatingHeaderSnapConfiguration(
                            curve: Curves.bounceInOut,
                            duration: const Duration(milliseconds: 10),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 8.0,
                              width: 70.0,
                              decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                      ),
                    )
                    ..add(SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return ListTile(title: Text('Item $index'));
                      }, childCount: sliverChildCount),
                    ));

                  return widgetList;
                }

                return Container(
                  color: Colors.blue[100],
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: sliverList(25),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.animateTo(1,
              duration: const Duration(milliseconds: 200), curve: Curves.linear);
        },
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

typedef Builder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);


/// 错误展示，因为只有类似 ListView 之类的 Scrollable 才能让 DraggableScrollableSheet
/// 因为 _DraggableScrollableSheetScrollPosition 里通过 listShouldScroll 改变 extent 的大小
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('DraggableScrollableSheet'),
    ),
    body: Stack(
      children: [
        Container(
          height: 300,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "static/gsy_cat.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox.expand(
          child: DraggableScrollableSheet(
            builder: (BuildContext context, ScrollController scrollController) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 8.0,
                        width: 70.0,
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                        child: Container(
                      color: Colors.blue[100],
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 25,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(title: Text('Item $index'));
                        },
                      ),
                    ))
                  ]);
            },
          ),
        )
      ],
    ),
  );
}
