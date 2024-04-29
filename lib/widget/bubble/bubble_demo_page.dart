import 'dart:io';

import 'package:flutter/material.dart';

import 'bubble_painter.dart';
import 'bubble_tip_widget.dart';

///演示提示弹框
class BubbleDemoPage extends StatelessWidget {
  final double bubbleHeight = 60;
  final double bubbleWidth = 120;
  final GlobalKey contentKey = GlobalKey();

  final GlobalKey button1Key = GlobalKey();
  final GlobalKey button2Key = GlobalKey();
  final GlobalKey button3Key = GlobalKey();
  final GlobalKey button4Key = GlobalKey();

  BubbleDemoPage({super.key});

  getX(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    double dx = renderBox.localToGlobal(Offset.zero).dx;
    return dx;
  }

  getY(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    double dy = renderBox.localToGlobal(Offset.zero).dy;
    return dy;
  }

  getWidth(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.width;
  }

  getHeight(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  bool isClient() {
    try {
      return Platform.isAndroid == true || Platform.isIOS == true;
    } catch (e) {
      return false;
    }
  }

  getY1() {
    if (isClient()) {
      return getY(button1Key) +
          getHeight(button1Key) -
          MediaQueryData.fromView(
                  WidgetsBinding.instance.platformDispatcher.views.first)
              .padding
              .top;
    } else {
      return getY(button1Key) + getHeight(button1Key);
    }
  }

  getY2() {
    if (isClient()) {
      return getY(button2Key) +
          getHeight(button2Key) / 2 -
          MediaQueryData.fromView(
                  WidgetsBinding.instance.platformDispatcher.views.first)
              .padding
              .top;
    } else {
      return getY(button2Key) + getHeight(button2Key) / 2;
    }
  }

  getY3() {
    if (isClient()) {
      return getY(button3Key) +
          getHeight(button3Key) / 2 -
          MediaQueryData.fromView(
                  WidgetsBinding.instance.platformDispatcher.views.first)
              .padding
              .top;
    } else {
      return getY(button3Key) + getHeight(button3Key) / 2;
    }
  }

  getY4() {
    if (isClient()) {
      return getY(button4Key) -
          bubbleHeight -
          MediaQueryData.fromView(
                  WidgetsBinding.instance.platformDispatcher.views.first)
              .padding
              .top;
    } else {
      return getY(button4Key) - bubbleHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BubbleDemoPage"),
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        margin: const EdgeInsets.all(15),
        child: Stack(
          key: contentKey,
          children: <Widget>[
            MaterialButton(
              key: button1Key,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return BubbleDialog(
                        "Test1",
                        height: bubbleHeight,
                        width: bubbleWidth,
                        arrowLocation: ArrowLocation.TOP,
                        x: getX(button1Key) + getWidth(button1Key) / 2,
                        y: getY1(),
                      );
                    });
              },
              color: Colors.blue,
            ),
            Positioned(
                left: MediaQuery.sizeOf(context).width / 2,
                child: MaterialButton(
                  key: button2Key,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return BubbleDialog(
                            "Test2",
                            height: bubbleHeight,
                            width: bubbleWidth,
                            arrowLocation: ArrowLocation.RIGHT,
                            x: getX(button2Key) - bubbleWidth,
                            y: getY2(),
                          );
                        });
                  },
                  color: Colors.greenAccent,
                )),
            Positioned(
              left: MediaQuery.sizeOf(context).width / 5,
              top: MediaQuery.sizeOf(context).height / 4 * 3,
              child: MaterialButton(
                key: button3Key,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BubbleDialog(
                          "Test4",
                          height: bubbleHeight,
                          width: bubbleWidth,
                          arrowLocation: ArrowLocation.LEFT,
                          x: getX(button3Key) + getWidth(button3Key),
                          y: getY3(),
                        );
                      });
                },
                color: Colors.yellow,
              ),
            ),
            Positioned(
              left: MediaQuery.sizeOf(context).width / 2 -
                  Theme.of(context).buttonTheme.minWidth / 2,
              top: MediaQuery.sizeOf(context).height / 2 -
                  MediaQuery.paddingOf(context).top -
                  kToolbarHeight,
              child: MaterialButton(
                key: button4Key,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BubbleDialog(
                          "Test4",
                          height: bubbleHeight,
                          width: bubbleWidth,
                          arrowLocation: ArrowLocation.BOTTOM,
                          x: getX(button4Key) + getWidth(button4Key) / 2,
                          y: getY4(),
                        );
                      });
                },
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BubbleDialog extends StatelessWidget {
  final String text;

  final ArrowLocation arrowLocation;

  ///控件高度
  final double? height;

  ///控件宽度
  final double? width;

  ///控件圆角
  final double radius;

  ///需要三角形指向的x坐标
  final double? x;

  ///需要三角形指向的y坐标
  final double? y;

  final VoidCallback? voidCallback;

  const BubbleDialog(this.text,
      {super.key, this.width,
      this.height,
      this.radius = 4,
      this.arrowLocation = ArrowLocation.BOTTOM,
      this.voidCallback,
      this.x = 0,
      this.y = 0});

  confirm(context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          confirm(context);
        },
        child: Container(
          alignment: Alignment.centerLeft,
          child: BubbleTipWidget(
              arrowLocation: arrowLocation,
              width: width,
              height: height,
              radius: radius,
              x: x,
              y: y,
              text: text,
              voidCallback: () {
                confirm(context);
              }),
        ),
      ),
    );
  }
}
