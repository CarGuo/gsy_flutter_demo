import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

///对应文章解析  https://juejin.cn/post/7124064789763981326
class Card3DDemoPage extends StatefulWidget {
  const Card3DDemoPage({Key? key}) : super(key: key);

  @override
  State<Card3DDemoPage> createState() => _Card3DDemoPageState();
}

class _Card3DDemoPageState extends State<Card3DDemoPage> {
  double touchX = 0;
  double touchY = 0;
  bool startTransform = false;

  double cardWidth = 592;
  double cardHeight = 402;

  var showIndex = 1;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    autoShow();
  }

  @override
  void dispose() {
    super.dispose();
    cancelShow();
  }

  cancelShow() {
    if (timer?.isActive == true) {
      timer?.cancel();
    }
  }

  autoShow() {
    cancelShow();
    timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      touchX = touchX + 0.05;
      touchX = touchX % (2 * pi);
      touchY = 0;
      startTransform = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (touchX.abs() % (pi * 3 / 2) >= pi / 2 ||
        touchY.abs() % (pi * 3 / 2) >= pi / 2) {
      showIndex = 0;
    } else {
      showIndex = 1;
    }
    return Scaffold(
      appBar: AppBar(title: Text("Card3DDemoPage")),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.yellowAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(startTransform ? touchY : 0.0)
            ..rotateY(startTransform ? touchX : 0.0),
          alignment: FractionalOffset.center,
          child: GestureDetector(
            onTapUp: (_) => setState(() {
              startTransform = false;
              showIndex = 1;
              touchX = 0;
              touchY = 0;
              autoShow();
            }),
            onPanCancel: () => setState(() {
              startTransform = false;
              showIndex = 1;
              touchX = 0;
              touchY = 0;
              autoShow();
            }),
            onPanDown: (_) {
              cancelShow();
              touchX = 0;
              touchY = 0;
            },
            onPanEnd: (_) => setState(() {
              startTransform = false;
              showIndex = 1;
              touchX = 0;
              touchY = 0;
              autoShow();
            }),
            onPanUpdate: (details) {
              cancelShow();
              setState(() => startTransform = true);

              touchX = (cardWidth / 2 - details.localPosition.dx) / 100;
              touchY = (details.localPosition.dy - cardHeight / 2) / 100;

              /// 取余
              touchX = touchX % (2 * pi);
              touchY = touchY % (2 * pi);
            },
            child: IndexedStack(
              index: showIndex,
              children: [
                AspectRatio(
                  aspectRatio: cardWidth / cardHeight,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("static/card_down.png")),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 25,
                          spreadRadius: -25,
                          offset: Offset(0, 30),
                        )
                      ],
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: cardWidth / cardHeight,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("static/card_up.png")),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 25,
                          spreadRadius: -25,
                          offset: Offset(0, 30),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        new Spacer(),
                        new Spacer(),
                        new Expanded(
                          child: Text(
                            "8888 8888 8888 8888",
                            style: TextStyle(
                              fontSize: 25,
                              fontFamily: 'bglbt',
                              shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 2,
                                    offset: Offset(1, 1)),
                              ],
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 0.3
                                ..shader = LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Colors.white, Colors.blueAccent, Colors.black54])
                                    .createShader(
                                  Rect.fromLTWH(0, 0, 1000, 100),
                                ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
