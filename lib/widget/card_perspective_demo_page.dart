import 'package:flutter/material.dart';

///对应文章解析  https://juejin.cn/post/7124064789763981326
class CardPerspectiveDemoPage extends StatefulWidget {
  const CardPerspectiveDemoPage({Key? key}) : super(key: key);

  @override
  State<CardPerspectiveDemoPage> createState() =>
      _CardPerspectiveDemoPageState();
}

class _CardPerspectiveDemoPageState extends State<CardPerspectiveDemoPage> {
  double touchX = 0;
  double touchY = 0;
  bool startTransform = false;

  double cardWidth = 300;
  double cardHeight = 400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CardPerspectiveDemoPage")),
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
            }),
            onPanCancel: () => setState(() => startTransform = false),
            onPanEnd: (_) => setState(() {
              startTransform = false;
            }),
            onPanUpdate: (details) {
              setState(() => startTransform = true);

              ///y轴限制范围
              if (details.localPosition.dx < cardWidth * 0.55 &&
                  details.localPosition.dx > cardWidth * 0.3) {
                touchX = (cardWidth / 2 - details.localPosition.dx) / 100;
              }

              ///x轴限制范围
              if (details.localPosition.dy > cardHeight * 0.4 &&
                  details.localPosition.dy < cardHeight * 0.6) {
                touchY = (details.localPosition.dy - cardHeight / 2) / 100;
              }
            },
            child: Container(
              width: cardWidth,
              height: cardHeight,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                    colors: [Colors.white, Colors.blueGrey],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform(
                    transform: Matrix4.identity()
                      ..translate(startTransform ? touchX * 50 - 5 : 0.0,
                          startTransform ? touchY * 50 - 5 : 0.0, 0.0),
                    alignment: FractionalOffset.center,
                    child: Text(
                      '13',
                      style: TextStyle(
                        fontSize: 80,
                        fontFamily: 'Canterbury',
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                              offset: Offset(1, 1)),
                        ],
                        foreground: Paint()
                          ..style = PaintingStyle.fill
                          ..strokeWidth = 3
                          ..shader = LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [Colors.yellow, Colors.black])
                              .createShader(Rect.fromLTWH(0, 0, 200, 100)),
                      ),
                    ),
                  ),
                  new Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: new Text(
                      "MIUI 13",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Agne"),
                    ),
                  ),
                  new Spacer(),
                  new Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: new Text(
                      "新版本优化应用",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Transform(
                    transform: Matrix4.identity()
                      ..translate(startTransform ? touchX * 30 - 5 : 0.0,
                          startTransform ? touchY * 30 - 5 : 0.0, 0.0),
                    alignment: FractionalOffset.center,
                    child: Image.asset(
                      "static/gsy_cat.png",
                      width: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
