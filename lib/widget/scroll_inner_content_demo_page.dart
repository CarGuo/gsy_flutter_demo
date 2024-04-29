import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///一个有趣的底部跟随例子
class ScrollInnerContentDemoPage extends StatefulWidget {
  const ScrollInnerContentDemoPage({super.key});

  @override
  _ScrollInnerContentDemoPageState createState() =>
      _ScrollInnerContentDemoPageState();
}

class _ScrollInnerContentDemoPageState
    extends State<ScrollInnerContentDemoPage> {
  GlobalKey globalKey = GlobalKey();

  final double buttonHeight = 40;
  bool outSize = false;
  String content = "这是可滑动文本区域";

  Future<double> getButtonPosition() {
    return Future.delayed(const Duration(seconds: 0), () {
      var renderBox = globalKey.currentContext!.findRenderObject() as RenderBox;
      double dy = renderBox.localToGlobal(Offset.zero).dy;
      double height = renderBox.size.height;
      var outSize = false;
      var topPadding = kToolbarHeight + MediaQuery.paddingOf(context).top;

      var maxHeight =
          MediaQuery.sizeOf(context).height - buttonHeight - topPadding;

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
      if (kDebugMode) {
        print("##### $buttonPosition $outSize");
      }

      return buttonPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ScrollDemoPage"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                content += "=｜-动态文本-｜=";
              });
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (content.length > 8) {
                  content = content.replaceFirst("=｜-动态文本-｜=", "");
                }
              });
            },
            icon: const Icon(Icons.remove_circle_outline),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                color: Colors.redAccent,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 60,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "点击右上角加减查看效果",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Container(
                      height: 60,
                      alignment: Alignment.centerLeft,
                      child: const Text("我是文本2"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.only(bottom: outSize ? (buttonHeight) : 0),
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    key: globalKey,
                    color: Colors.red,
                    child: Text(
                      content,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
              ),
            ],
          ),
          FutureBuilder<double?>(
            future: getButtonPosition(),
            builder: (context, snap) {
              if (snap.data == null || snap.data == 0) {
                return Container();
              }
              return Positioned(
                top: snap.data,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: buttonHeight,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      height: buttonHeight,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      color: Colors.blue,
                      child: const Text("#########"),
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
