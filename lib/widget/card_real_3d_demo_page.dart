import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zflutter/zflutter.dart';

class CardReal3DDemoPage extends StatefulWidget {
  const CardReal3DDemoPage({Key? key}) : super(key: key);

  @override
  State<CardReal3DDemoPage> createState() => _CardReal3DDemoPageState();
}

class _CardReal3DDemoPageState extends State<CardReal3DDemoPage> {
  List<ZPathCommand> numPosition(
      int index, double size, double width, double height, double z) {
    double lineHeight = size / 2;
    double initX = index * size - width / 2;
    double initY = height / 7;
    return [
      ZMove.vector(ZVector(initX, initY, z)),
      ZLine.vector(ZVector.only(x: initX - lineHeight, y: initY, z: z)),
      ZLine.vector(
          ZVector.only(x: initX - lineHeight, y: lineHeight + initY, z: z)),
      ZLine.vector(
          ZVector.only(x: initX - lineHeight, y: lineHeight + initY, z: z)),
      ZLine.vector(ZVector.only(x: initX, y: lineHeight + initY, z: z)),
      ZLine.vector(ZVector.only(x: initX, y: size + initY, z: z)),
      ZLine.vector(ZVector.only(x: initX - lineHeight, y: size + initY, z: z)),
    ];
  }

  listNum(width, height, double z) {
    List numbs = [];
    for (int i = 0; i < 16; i++) {
      numbs.addAll(numPosition(i + 1, 17, width, height, z));
    }
    return numbs;
  }

  @override
  Widget build(BuildContext context) {
    double width = 279;
    double height = 194;
    final double screenRadius = 15;
    final double border = 4;

    return Scaffold(
      appBar: AppBar(title: Text("CardReal3DDemoPage")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.yellowAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: ZDragDetector(builder: (context, controller) {
          return ZIllustration(
            zoom: 1.0,
            children: [
              ZPositioned(
                rotate: controller.rotate,
                child: ZGroup(
                  children: [
                    ZGroup(
                      sortMode: SortMode.stack,
                      children: [
                        ZPositioned(
                          translate: ZVector(0, 0, -border / 2),
                          child: ZRoundedRect(
                            width: width,
                            height: height,
                            borderRadius: screenRadius,
                            fill: true,
                            stroke: border,
                            color: Colors.black54,
                          ),
                        ),
                        ZToBoxAdapter(
                          width: width,
                          height: height,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(screenRadius),
                            child: Container(
                              child: Stack(
                                children: [
                                  SizedBox.fromSize(
                                      size: Size(width, height),
                                      child: Image.asset(
                                          "static/card_down_2.png")),
                                  Transform(
                                    transform: Matrix4.identity()..rotateY(pi),
                                    alignment: FractionalOffset.center,
                                    child: Align(
                                      alignment: Alignment(0.5, -0.07),
                                      child: new Text(
                                        "G S Y",
                                        style: TextStyle(
                                            fontSize: 23,
                                            fontFamily: "bglbt",
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ZGroup(
                      sortMode: SortMode.stack,
                      children: [
                        ZRoundedRect(
                          width: width,
                          height: height,
                          borderRadius: screenRadius,
                          fill: true,
                          color: Colors.blue.withAlpha(100),
                        ),
                        ZToBoxAdapter(
                          width: width,
                          height: height,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(screenRadius),
                            child: SizedBox.fromSize(
                                size: Size(width, height),
                                child: Image.asset("static/card_up_2.png")),
                          ),
                        ),
                        ZGroup(
                          sortMode: SortMode.update,
                          children: [
                            ZPositioned(
                              child: ZShape(
                                path: [...listNum(width, height, 2)],
                                fill: false,
                                stroke: 1,
                                closed: false,
                                backfaceColor: Colors.black54,
                                front: ZVector.only(z: 100),
                                color: Colors.grey.withAlpha(200),
                              ),
                            ),
                            ZPositioned(
                              child: ZShape(
                                path: [...listNum(width, height, 1)],
                                fill: false,
                                stroke: 2,
                                closed: false,
                                backfaceColor: Colors.black54,
                                front: ZVector.only(z: 100),
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                            ZPositioned(
                              rotate: ZVector(0, 0, tau / 2),
                              child: ZShape(
                                visible: false,
                                path: [...listNum(width, height, 2)],
                                fill: false,
                                stroke: 2,
                                closed: false,
                                color: Colors.blueGrey.withAlpha(200),
                              ),
                            ),
                            ZPositioned(
                              rotate: ZVector(0, 0, tau / 2),
                              child: ZShape(
                                visible: false,
                                path: [...listNum(width, height, 1)],
                                fill: false,
                                stroke: 2,
                                closed: false,
                                backfaceColor: Colors.black54,
                                front: ZVector.only(z: 100),
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
