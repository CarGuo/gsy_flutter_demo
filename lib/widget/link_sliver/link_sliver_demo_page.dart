import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/link_sliver/link_flexible_space_bar.dart';

import 'link_sliver_header.dart';

class LinkSliverDemoPage extends StatefulWidget {
  const LinkSliverDemoPage({super.key});

  @override
  _LinkSliverDemoPageState createState() => _LinkSliverDemoPageState();
}

class _LinkSliverDemoPageState extends State<LinkSliverDemoPage> {
  renderBottomItem() {
    return Expanded(
      child: Container(
        alignment: Alignment.centerLeft,
        child: const Center(
          child: Text(
            "FFFF",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              leading: Container(),
              expandedHeight: 260.0,
              flexibleSpace: LinkFlexibleSpaceBar(
                centerTitle: false,
                title: Container(
                  margin: const EdgeInsets.only(left: 20, top: 30, bottom: 20),
                  child: const Text("GSY"),
                ),
                image: "static/gsy_cat.png",
                bottom: List.generate(4, (index) {
                  return renderBottomItem();
                }),
                titlePadding: const EdgeInsets.all(0),
              ),
              pinned: true,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.settings_overscan),
                  tooltip: 'Add new entry',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Add new entry',
                  onPressed: () {},
                ),
              ],
            ),
          ];
        },
        body: MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: CustomScrollView(
            ///回弹效果
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              const LinkSliverHeader(
                initLayoutExtent: 60,
                containerExtent: 120,
                triggerPullDistance: 120,
                pinned: false,
              ),

              ///列表区域
              SliverSafeArea(
                sliver: SliverList(
                  ///代理显示
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Card(
                        child: Container(
                          height: 60,
                          alignment: Alignment.centerLeft,
                          child: Text("Item  $index"),
                        ),
                      );
                    },
                    childCount: 100,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
