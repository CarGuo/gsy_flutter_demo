import 'package:flutter/material.dart';
import 'custom_sliver.dart';

class ScrollHeaderDemoPage extends StatefulWidget {
  @override
  _ScrollHeaderDemoPageState createState() => _ScrollHeaderDemoPageState();
}

class _ScrollHeaderDemoPageState extends State<ScrollHeaderDemoPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<CustomSliverState> globalKey = new GlobalKey();

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
        title: new Text("ScrollHeaderDemoPage"),
      ),
      body: new NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification) {
            if (initLayoutExtent > 0) {
              if (notification.metrics.pixels < -showPullDistance) {
                globalKey.currentState!.handleShow();
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 2,
                ),

                ///代理显示
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
                  childCount: 40,
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        new ElevatedButton(
          onPressed: () async {
            setState(() {
              pinned = !pinned;
            });
          },
          child: new Text(
            pinned ? "pinned" : "scroll",
            style: TextStyle(color: Colors.white),
          ),
        ),
        new ElevatedButton(
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
          child: new Text(
            initLayoutExtent != 0 ? "minHeight" : "non Height",
            style: TextStyle(color: Colors.white),
          ),
        ),
        new ElevatedButton(
          onPressed: () async {
            setState(() {
              if (showPullDistance > 150) {
                showPullDistance = 150;
              } else {
                showPullDistance = 1500;
              }
            });
          },
          child: new Text(
            showPullDistance > 150 ? "autoBack" : "non autoBack",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
