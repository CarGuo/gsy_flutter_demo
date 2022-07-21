import 'package:flutter/material.dart';

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
  void initState() {
    super.initState();
  }

  double getCardAngleX(double samplingTouchY) {
    return startTransform ? (1.2 * (samplingTouchY / 50) + -1.2) : 0;
  }

  double getCardAngleY(double samplingTouchX) {
    return startTransform ? (-0.3 * (samplingTouchX / 50) + 0.3) : 0;
  }

  double getMemberTranslate(double samplingTouch, keyValue) {
    return startTransform ? (keyValue * (samplingTouch / 50) - keyValue) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    double samplingAngleX = touchX / cardWidth * 80;
    double samplingAngleY = touchY / cardHeight / 2 * 100;

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
            ///调整视角，第3行第2列，也就是调整 z 轴的视角，产生透视偏差效果
            ..setEntry(3, 2, 0.001)
            ..rotateX(getCardAngleX(samplingAngleY))
            ..rotateY(getCardAngleY(samplingAngleX)),
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

              ///x轴限制范围
              if (details.localPosition.dx < cardWidth &&
                  details.localPosition.dx > cardWidth * 0.3) {
                touchX = details.localPosition.dx;
              }

              ///y轴限制范围
              if (details.localPosition.dy > cardHeight * 0.5 &&
                  details.localPosition.dy < cardHeight * 1.4) {
                touchY = details.localPosition.dy;
              }
            },
            child: Container(
              width: cardWidth,
              height: cardHeight,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                      colors: [Colors.white, Colors.blueGrey],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x70000000),
                      blurRadius: 30,
                      spreadRadius: -30,
                      offset: Offset(0, 60),
                    )
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform(
                    transform: Matrix4.identity()
                      ..translate(getMemberTranslate(samplingAngleX, 20),
                          getMemberTranslate(samplingAngleY, 20), 0.0),
                    alignment: FractionalOffset.center,
                    child: Container(
                      child: Text(
                        '13',
                        style: TextStyle(
                          fontSize: 80,
                          fontFamily: 'Canterbury',
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(
                                    startTransform
                                        ? samplingAngleY / 10 - 5
                                        : 0,
                                    startTransform
                                        ? samplingAngleX / 10 - 5
                                        : 0)),
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
                      ..translate(getMemberTranslate(samplingAngleX, 15),
                          getMemberTranslate(samplingAngleY, 15), 0.0),
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
