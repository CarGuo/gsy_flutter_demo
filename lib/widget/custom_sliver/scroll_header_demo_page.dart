import 'package:flutter/material.dart';
import 'custom_sliver.dart';

class ScrollHeaderDemoPage extends StatefulWidget {
  const ScrollHeaderDemoPage({super.key});

  @override
  _ScrollHeaderDemoPageState createState() => _ScrollHeaderDemoPageState();
}

class _ScrollHeaderDemoPageState extends State<ScrollHeaderDemoPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<CustomSliverState> globalKey = GlobalKey();

  final ScrollController controller =
      ScrollController(initialScrollOffset: -70);

  double initLayoutExtent = 70;
  double showPullDistance = 150;
  final double indicatorExtent = 200;
  final double triggerPullDistance = 300;
  bool pinned = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        title: const Text("ScrollHeaderDemoPage"),
      ),
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification) {
            if (initLayoutExtent > 0) {
              if (notification.metrics.pixels < -showPullDistance) {
                ///用户松手之后才触发完全展开显示
                if (notification.dragDetails == null) {
                  globalKey.currentState?.handleShow();
                  controller.jumpTo(-(showPullDistance + 1));
                }
              } else if (notification.metrics.pixels > 5) {
                globalKey.currentState!.handleHide();
              }
            }
          }
          return false;
        },
        child: CustomScrollView(
          controller: controller,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            CustomSliver(
              key: globalKey,
              initLayoutExtent: initLayoutExtent,
              containerExtent: indicatorExtent,
              triggerPullDistance: triggerPullDistance,
              pinned: pinned,
            ),

            ///列表区域
            SliverPadding(
              padding: EdgeInsets.only(bottom: pinned ? initLayoutExtent : 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 2,
                ),

                ///代理显示
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Card(
                      child: Container(
                        height: 60,
                        alignment: Alignment.centerLeft,
                        child: Text("Item $index"),
                      ),
                    );
                  },
                  childCount: 40,
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        ElevatedButton(
          onPressed: () async {
            setState(() {
              pinned = !pinned;
            });
          },
          child: Text(
            pinned ? "pinned" : "scroll",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              if (initLayoutExtent == 0) {
                initLayoutExtent = 70;
              } else {
                initLayoutExtent = 0;
                globalKey.currentState!.handleShow();
              }
            });
          },
          child: Text(
            initLayoutExtent != 0 ? "minHeight" : "non Height",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              if (showPullDistance > 150) {
                showPullDistance = 150;
              } else {
                showPullDistance = 1500;
              }
            });
          },
          child: Text(
            showPullDistance > 150 ? "autoBack" : "non autoBack",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
