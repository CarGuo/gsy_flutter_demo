import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/test_center_sliver/test_center_sliver.dart';


class TestCenterSliverPage extends StatefulWidget {
  @override
  TestCenterSliverPageState createState() => TestCenterSliverPageState();
}

class TestCenterSliverPageState extends State<TestCenterSliverPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("TestCenterSliverPage"),
      ),
      body: Container(
        child: CustomScrollView(
            anchor: 0.5,
            ///回弹效果
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              TestCenterSliver(
                initLayoutExtent: 100,
                containerExtent: 100,
                triggerPullDistance: 100,
                pinned: false,
              ),

            ],
          ),
        ),
    );
  }
}
