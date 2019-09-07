import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'custom_sliver.dart';

class ScrollHeaderDemoPage extends StatefulWidget {
  @override
  _ScrollHeaderDemoPageState createState() => _ScrollHeaderDemoPageState();
}

class _ScrollHeaderDemoPageState extends State<ScrollHeaderDemoPage> with SingleTickerProviderStateMixin {
  GlobalKey<CustomSliverState> globalKey = new GlobalKey();

  final double indicatorExtent = 200;
  final double triggerPullDistance = 300;

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
            print("${notification.metrics.pixels}");
            if (notification.metrics.pixels < -indicatorExtent) {
              globalKey.currentState.handleShow();
            } else if (notification.metrics.pixels > 5) {
              globalKey.currentState.handleHide();
            }
          }
          return false;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            CustomSliver(
              key: globalKey,
              indicatorExtent: indicatorExtent,
              triggerPullDistance: triggerPullDistance,
            ),

            ///列表区域
            SliverSafeArea(
              sliver: SliverList(
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
    );
  }
}
