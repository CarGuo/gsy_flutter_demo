import 'package:flutter/material.dart';
import 'dart:math' as math;

///聊天列表，添加旧数据和新数据的时候不会导致列表跳动，首尾添加数据不会抖动
class ChatListScrollDemoPage2 extends StatefulWidget {
  const ChatListScrollDemoPage2({Key? key}) : super(key: key);

  @override
  _ChatListScrollDemoPageState2 createState() =>
      _ChatListScrollDemoPageState2();
}

class _ChatListScrollDemoPageState2 extends State<ChatListScrollDemoPage2> {
  final random = math.Random(10);

  List<ItemData> newData = [
    new ItemData(txt: "*********init 1*********", type: "Left", size: 60),
    new ItemData(txt: "*********init 2*********", type: "Left", size: 70),
    new ItemData(txt: "*********init 3*********", type: "Left", size: 100)
  ];
  List<ItemData> loadMoreData = [];

  var centerKey = GlobalKey();
  var scroller = ScrollController();
  double extentAfter = 0;

  renderRightItem(ItemData data, double height) {
    return Container(
      height: 50 + height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.red,
      ),
      margin: EdgeInsets.only(left: 50, right: 10, top: 5, bottom: 5),
      padding: EdgeInsets.all(10),
      alignment: Alignment.centerRight,
      child: new Text(
        data.txt,
        maxLines: 10,
      ),
    );
  }

  renderLeftItem(ItemData data, double height) {
    return Container(
      height: 50 + height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.green,
      ),
      margin: EdgeInsets.only(right: 50, left: 10, top: 5, bottom: 5),
      padding: EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      child: new Text(
        data.txt,
        maxLines: 10,
      ),
    );
  }

  ScrollPhysics _physics = BouncingScrollPhysics();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          newData.add(ItemData(
              txt: "#### new Send ${newData.length} #### #### #### #### ",
              type: "Right",
              size: random.nextInt(60)));
          setState(() {});
          Future.delayed(Duration(milliseconds: 1000), () {
            scroller.jumpTo(scroller.position.maxScrollExtent);
          });
        },
        child: Text(
          "Send",
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      appBar: AppBar(
        title: new Text("ControllerDemoPage"),
        actions: [
          new TextButton.icon(
              onPressed: () {
                final random = math.Random();
                int randomInt = random.nextInt(10);
                for (int i = 0; i < 20; i++) {
                  var type = randomInt + i;
                  if (type % 4 == 0) {
                    loadMoreData.add(ItemData(
                        txt: "--------Old ${loadMoreData.length}$i",
                        type: "Right",
                        size: random.nextInt(60)));
                  } else {
                    loadMoreData.add(ItemData(
                        txt: "---------Old ${loadMoreData.length}$i",
                        type: "Left",
                        size: random.nextInt(60)));
                  }
                }
                setState(() {});
              },
              icon: Icon(
                Icons.add,
                color: Colors.red,
              ),
              label: Text(
                "add old",
                style: TextStyle(color: Colors.red),
              )),
          new TextButton.icon(
              onPressed: () {
                final random = math.Random();
                int randomInt = random.nextInt(10);
                for (int i = 0; i < 20; i++) {
                  var type = randomInt + i * 3;
                  if (type % 4 == 0) {
                    newData.add(ItemData(
                        txt: "##########  New ${newData.length} $i",
                        type: "Left",
                        size: random.nextInt(60)));
                  } else {
                    newData.add(ItemData(
                        txt: "##########   New ${newData.length} $i",
                        type: "Right",
                        size: random.nextInt(60)));
                  }
                }
                setState(() {});
                if (extentAfter == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("你目前位于最底部，自动跳转新消息item"),
                    duration: Duration(milliseconds: 1000),
                  ));
                  Future.delayed(Duration(milliseconds: 200), () {
                    scroller.jumpTo(scroller.position.maxScrollExtent);
                    Future.delayed(Duration(milliseconds: 400), () {
                      scroller.jumpTo(scroller.position.maxScrollExtent);
                    });
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: InkWell(
                      onTap: () {
                        scroller
                            .jumpTo(scroller.position.maxScrollExtent * 0.7);
                        Future.delayed(Duration(milliseconds: 400), () {
                          scroller.animateTo(scroller.position.maxScrollExtent,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.linear);
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 200,
                        color: Colors.blueAccent,
                        alignment: Alignment.centerLeft,
                        child: Text("点击我自动跳转新消息item"),
                      ),
                    ),
                    duration: Duration(milliseconds: 1000),
                  ));
                }
              },
              icon: Icon(
                Icons.add,
                color: Colors.yellow,
              ),
              label: Text(
                "add new",
                style: TextStyle(color: Colors.yellow),
              )),

          ///先加载一页满的数据 然后再拉一页老数据
          ///相当于两个sliverlist都有数据
          ///然后对底下的sliverlist删除数据 就会出现底下空白
          ///这里测试删除时，用偏移来解决底部空白
          // new TextButton.icon(
          //     onPressed: () {
          //       newData.removeLast();
          //       newData.removeLast();
          //       newData.removeLast();
          //       newData.removeLast();
          //       newData.removeLast();
          //
          //       newData.insert(0, loadMoreData[0]);
          //       newData.insert(0,loadMoreData[1]);
          //       newData.insert(0,loadMoreData[2]);
          //       newData.insert(0,loadMoreData[4]);
          //       newData.insert(0,loadMoreData[5]);
          //
          //       loadMoreData.removeAt(0);
          //       loadMoreData.removeAt(1);
          //       loadMoreData.removeAt(2);
          //       loadMoreData.removeAt(3);
          //       loadMoreData.removeAt(4);
          //
          //       setState(() {
          //
          //       });
          //
          //
          //     },
          //     icon: Icon(
          //       Icons.delete,
          //       color: Colors.yellow,
          //     ),
          //     label: Text(
          //       "Delete",
          //       style: TextStyle(color: Colors.yellow),
          //     )),
        ],
      ),
      extendBody: true,
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollNotification) {
            if (notification.metrics is PageMetrics) {
              return false;
            }
            if (notification.metrics is FixedScrollMetrics) {
              if (notification.metrics.axisDirection == AxisDirection.left ||
                  notification.metrics.axisDirection == AxisDirection.right) {
                return false;
              }
            }
            extentAfter = notification.metrics.extentAfter;
          }
          return false;
        },
        child: CustomScrollView(
          controller: scroller,
          center: centerKey,
          physics: _physics,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  var item = loadMoreData[index];
                  if (item.type == "Right")
                    return renderRightItem(item, random.nextInt(60).toDouble());
                  else
                    return renderLeftItem(item, random.nextInt(60).toDouble());
                },
                childCount: loadMoreData.length,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.zero,
              key: centerKey,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  var item = newData[index];
                  if (item.type == "Right")
                    return renderRightItem(item, item.size.toDouble());
                  else
                    return renderLeftItem(item, item.size.toDouble());
                },
                childCount: newData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemData {
  String txt = "";
  String type = "";
  int size;

  ItemData({
    required this.txt,
    required this.type,
    required this.size,
  });
}
