import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///聊天列表，添加旧数据和新数据的时候不会导致列表跳动，首尾添加数据不会抖动
class ChatListScrollDemoPage extends StatefulWidget {
  const ChatListScrollDemoPage({Key? key}) : super(key: key);

  @override
  _ChatListScrollDemoPageState createState() => _ChatListScrollDemoPageState();
}

class _ChatListScrollDemoPageState extends State<ChatListScrollDemoPage> {
  var loadMoreData = ["ddd1", "ddd2", "ddd3"];
  var newData = [];

  var centerKey = GlobalKey();
  var scroller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          newData.add("#### new Send");
          setState(() {});
          Future.delayed(Duration(milliseconds: 1000), () {
            scroller.jumpTo(scroller.position.minScrollExtent);
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
                for (int i = 0; i < 20; i++) {
                  loadMoreData.add("#### old ${loadMoreData.length}$i");
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
                for (int i = 0; i < 20; i++) {
                  newData.insert(0, "#### new ${newData.length - i}");
                }
                setState(() {});
              },
              icon: Icon(
                Icons.add,
                color: Colors.yellow,
              ),
              label: Text(
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
                return Container(
                  height: 50,
                  margin: EdgeInsets.all(5),
                  color: Colors.yellow,
                  child: new Text(newData[index]),
                );
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
                return Container(
                  height: 50,
                  margin: EdgeInsets.all(5),
                  color: Colors.red,
                  child: new Text(loadMoreData[index]),
                );
              },
              childCount: loadMoreData.length,
            ),
          ),
        ],
      ),
    );
  }
}
