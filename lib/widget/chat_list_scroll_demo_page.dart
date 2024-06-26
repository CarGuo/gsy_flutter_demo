import 'package:flutter/material.dart';

///聊天列表，添加旧数据和新数据的时候不会导致列表跳动，首尾添加数据不会抖动
class ChatListScrollDemoPage extends StatefulWidget {
  const ChatListScrollDemoPage({super.key});

  @override
  _ChatListScrollDemoPageState createState() => _ChatListScrollDemoPageState();
}

class _ChatListScrollDemoPageState extends State<ChatListScrollDemoPage> {
  List<ItemData> loadMoreData = [
    ItemData(txt: "aaa11", type: "Right"),
    ItemData(txt: "aaa22", type: "Right"),
    ItemData(txt: "aaa33", type: "Right")
  ];
  List<ItemData> newData = [];

  var centerKey = GlobalKey();
  var scroller = ScrollController();

  renderRightItem(ItemData data) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.red,
      ),
      margin: const EdgeInsets.only(left: 50, right: 10, top: 5, bottom: 5),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerRight,
      child: Text(
        data.txt,
        maxLines: 10,
      ),
    );
  }

  renderLeftItem(ItemData data) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.green,
      ),
      margin: const EdgeInsets.only(right: 50, left: 10, top: 5, bottom: 5),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      child: Text(
        data.txt,
        maxLines: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          newData.add(
              ItemData(txt: "#### new Send ${newData.length}", type: "Right"));
          setState(() {});
          Future.delayed(const Duration(milliseconds: 1000), () {
            scroller.jumpTo(scroller.position.minScrollExtent);
          });
        },
        child: const Text(
          "Send",
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      appBar: AppBar(
        title: const Text("ControllerDemoPage"),
        actions: [
          TextButton.icon(
              onPressed: () {
                for (int i = 0; i < 20; i++) {
                  loadMoreData.add(ItemData(
                      txt: "Old ${loadMoreData.length}$i", type: "Right"));
                }
                setState(() {});
              },
              icon: const Icon(
                Icons.add,
                color: Colors.red,
              ),
              label: const Text(
                "add old",
                style: TextStyle(color: Colors.red),
              )),
          TextButton.icon(
              onPressed: () {
                for (int i = 0; i < 20; i++) {
                  newData.add(
                      ItemData(txt: "New ${newData.length}$i", type: "Left"));
                }
                setState(() {});
              },
              icon: const Icon(
                Icons.add,
                color: Colors.yellow,
              ),
              label: const Text(
                "add new",
                style: TextStyle(color: Colors.yellow),
              )),
        ],
      ),
      extendBody: true,
      body: CustomScrollView(
        controller: scroller,
        reverse: true,
        center: centerKey,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var item = newData[index];
                if (item.type == "Right") {
                  return renderRightItem(item);
                } else {
                  return renderLeftItem(item);
                }
              },
              childCount: newData.length,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.zero,
            key: centerKey,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var item = loadMoreData[index];
                if (item.type == "Right") {
                  return renderRightItem(item);
                } else {
                  return renderLeftItem(item);
                }
              },
              childCount: loadMoreData.length,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemData {
  String txt = "";
  String type = "";

  ItemData({
    required this.txt,
    required this.type,
  });
}
