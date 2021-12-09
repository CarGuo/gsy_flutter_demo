import 'package:flutter/material.dart';

///一个有趣的底部跟随例子
class ScrollInnerContentDemoPage extends StatefulWidget {
  @override
  _ScrollInnerContentDemoPageState createState() =>
      _ScrollInnerContentDemoPageState();
}

class _ScrollInnerContentDemoPageState
    extends State<ScrollInnerContentDemoPage> {
  GlobalKey globalKey = new GlobalKey();

  final double buttonHeight = 40;
  bool outSize = false;
  String content = "这是可滑动文本区域";

  Future<double> getButtonPosition() {
    return Future.delayed(Duration(seconds: 0), () {
      var renderBox = globalKey.currentContext!.findRenderObject() as RenderBox;
      double dy = renderBox.localToGlobal(Offset.zero).dy;
      double height = renderBox.size.height;
      var outSize = false;
      var topPadding = kToolbarHeight + MediaQuery.of(context).padding.top;

      var maxHeight =
          MediaQuery.of(context).size.height - buttonHeight - topPadding;

      var buttonPosition = dy + height - topPadding;

      if (buttonPosition >= maxHeight) {
        buttonPosition = maxHeight;
        outSize = true;
      }
      if (this.outSize != outSize) {
        setState(() {
          this.outSize = outSize;
        });
      }
      print("##### $buttonPosition $outSize");

      return buttonPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("ScrollDemoPage"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                content += "=｜-动态文本-｜=";
              });
            },
            icon: Icon(Icons.add_circle_outline),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (content.length > 8) {
                  content = content.replaceFirst("=｜-动态文本-｜=", "");
                }
              });
            },
            icon: Icon(Icons.remove_circle_outline),
          )
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Container(
            child: Column(
              children: <Widget>[
                new Container(
                  color: Colors.redAccent,
                  child: Column(
                    children: <Widget>[
                      new Container(
                        height: 60,
                        alignment: Alignment.centerLeft,
                        child: new Text(
                          "点击右上角加减查看效果",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      new Container(
                        height: 60,
                        alignment: Alignment.centerLeft,
                        child: new Text("我是文本2"),
                      ),
                    ],
                  ),
                ),
                new Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.only(bottom: outSize ? (buttonHeight) : 0),
                      physics: ClampingScrollPhysics(),
                      child: new Container(
                        width: MediaQuery.of(context).size.width,
                        key: globalKey,
                        color: Colors.red,
                        child: new Text(
                          content,
                          style: TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder<double?>(
            future: getButtonPosition(),
            builder: (context, snap) {
              if (snap.data == null || snap.data == 0) {
                return Container();
              }
              return new Positioned(
                top: snap.data,
                child: new Container(
                  width: MediaQuery.of(context).size.width,
                  height: buttonHeight,
                  child: new InkWell(
                    onTap: () {},
                    child: new Container(
                      height: buttonHeight,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      color: Colors.blue,
                      child: new Text("#########"),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
