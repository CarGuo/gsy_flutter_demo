import 'package:flutter/material.dart';

///滑动监听
class ScrollListenerDemoPage extends StatefulWidget {
  const ScrollListenerDemoPage({super.key});

  @override
  _ScrollListenerDemoPageState createState() => _ScrollListenerDemoPageState();
}

class _ScrollListenerDemoPageState extends State<ScrollListenerDemoPage> {
  final ScrollController _scrollController = ScrollController();

  bool isEnd = false;

  double offset = 0;

  String notify = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        offset = _scrollController.offset;
        isEnd = _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ScrollListenerDemoPage"),
      ),
      body: NotificationListener(
        onNotification: (dynamic notification) {
          String notify = "";
          if (notification is ScrollEndNotification) {
            notify = "ScrollEnd";
          } else if (notification is ScrollStartNotification) {
            notify = "ScrollStart";
          } else if (notification is UserScrollNotification) {
            notify = " UserScroll";
          } else if (notification is ScrollUpdateNotification) {
            notify = "ScrollUpdate";
          }
          setState(() {
            this.notify = notify;
          });
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          itemBuilder: (context, index) {
            return Card(
              child: Container(
                height: 60,
                alignment: Alignment.centerLeft,
                child: Text("Item $index"),
              ),
            );
          },
          itemCount: 100,
        ),
      ),
      persistentFooterButtons: <Widget>[
        TextButton(
          onPressed: () {
            _scrollController.animateTo(0,
                duration: const Duration(seconds: 1), curve: Curves.bounceInOut);
          },
          child: Text("position: ${offset.floor()}"),
        ),
        const SizedBox(width: 0.3, height: 30.0),
        TextButton(
          onPressed: () {},
          child: Text(notify),
        ),
        Visibility(
          visible: isEnd,
          child: TextButton(
            onPressed: () {},
            child: const Text("到达底部"),
          ),
        )
      ],
    );
  }
}
