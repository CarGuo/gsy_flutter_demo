import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/custom_sliver/custom_sliver.dart';

class SliverTabChildPage extends StatefulWidget {

  final List pageList;
  final tabIndex;

  SliverTabChildPage(this.tabIndex, this.pageList);

  @override
  _SliverTabChildPageState createState() => _SliverTabChildPageState();
}

class _SliverTabChildPageState extends State<SliverTabChildPage> with AutomaticKeepAliveClientMixin {

  GlobalKey<CustomSliverState> globalKey = new GlobalKey();

  double initLayoutExtent = 100;
  double showPullDistance = 150;
  final double indicatorExtent = 200;
  final double triggerPullDistance = 300;



  renderListByIndex(tabIndex, pageList) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            physics: BouncingScrollPhysics(),
            key: PageStorageKey<String>(tabIndex.toString()),
            slivers: <Widget>[
              CustomSliver(
                key: globalKey,
                initLayoutExtent: initLayoutExtent,
                containerExtent: indicatorExtent,
                triggerPullDistance: triggerPullDistance,
                pinned: false,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(10.0),
                sliver: SliverFixedExtentList(
                  itemExtent: 50.0, //item高度或宽度，取决于滑动方向
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return ListTile(
                        title: Text('Tab $tabIndex Item $index'),
                      );
                    },
                    childCount: pageList.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return renderListByIndex(widget.tabIndex, widget.pageList);
  }
}
