import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gsy_flutter_demo/widget/custom_viewport/custom_viewport.dart';
import 'package:gsy_flutter_demo/widget/custom_viewport/first_tab_bar.dart';
import 'package:gsy_flutter_demo/widget/custom_viewport/first_tab_bar_render_sliver.dart';
import 'package:gsy_flutter_demo/widget/custom_viewport/secondary_tab_bar.dart';
import 'package:gsy_flutter_demo/widget/custom_viewport/secondary_tab_bar_render_sliver.dart';

class CustomViewportPage extends StatelessWidget {
  const CustomViewportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Scrollable(
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return CustomViewport(
            offset: position,
            highestChildInPaintOrderClassList: [
              FirstTabBarRenderSliver,
              SecondaryTabBarRenderSliver,
            ],
            slivers: <Widget>[
              const FirstTabBar(),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 4.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.teal[100 * (index % 9)],
                      child: Text('Grid Item $index'),
                    );
                  },
                  childCount: 20,
                ),
              ),
              const SecondaryTabBar(),
              SliverFixedExtentList(
                itemExtent: 50.0,
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.lightBlue[100 * (index % 9)],
                      child: Text('List Item $index'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
