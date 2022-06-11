import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class VPListView extends StatefulWidget {
  const VPListView({Key? key}) : super(key: key);

  @override
  State<VPListView> createState() => _VPListViewState();
}

class _VPListViewState extends State<VPListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("VPListView"),
      ),
      extendBody: true,
      body: MediaQuery(
        ///调高 touchSlop 到 50 ，这样 pageview 滑动可能有点点影响，
        ///但是大概率处理了斜着滑动触发的问题
        data: MediaQuery.of(context).copyWith(
            gestureSettings: DeviceGestureSettings(
          touchSlop: 50,
        )),
        child: PageView(
          scrollDirection: Axis.horizontal,
          pageSnapping: true,
          children: [
            HandlerListView(),
            HandlerListView(),
          ],
        ),
      ),
    );
  }
}

class HandlerListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<HandlerListView> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      ///这里 touchSlop  需要调回默认
      data: MediaQuery.of(context).copyWith(
          gestureSettings: DeviceGestureSettings(
        touchSlop: kTouchSlop,
      )),
      child: ListView.separated(
        itemCount: 15,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            thickness: 3,
          );
        },
      ),
    );
  }
}
