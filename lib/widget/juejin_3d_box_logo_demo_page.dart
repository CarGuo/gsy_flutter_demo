import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zflutter/zflutter.dart';

class JueJin3DBoxLogoDemoPage extends StatefulWidget {
  const JueJin3DBoxLogoDemoPage({super.key});

  @override
  State<JueJin3DBoxLogoDemoPage> createState() => _JueJin3DBoxLogoDemoPageState();
}

class _JueJin3DBoxLogoDemoPageState extends State<JueJin3DBoxLogoDemoPage> {
  Color color = const Color(0xFF1E80FF);
  Color colorLight = const Color(0xFF1E8FFF);
  Color colorDeep = const Color(0xA11E38FF);

  renderBottom() {
    return [
      ZPositioned(
        rotate: const ZVector.only(z: pi * 0.28),
        child: ZPositioned(
          translate: const ZVector(100, 100, 0),
          child: ZBoxToBoxAdapter(
            height: 153,
            width: 30,
            depth: 30,
            color: color,
            front: Container(
              color: color,
            ),
            top: Container(
              color: colorLight,
            ),
            right: Container(
              color: colorDeep,
            ),
          ),
        ),
      ),
      ZPositioned(
        rotate: const ZVector.only(z: -pi * 0.28),
        child: ZPositioned(
          translate: const ZVector(-0, 100, 0),
          child: ZBoxToBoxAdapter(
            height: 153,
            width: 30,
            depth: 30,
            color: color,
            front: Container(
              color: color,
            ),
            top: Container(
              color: colorLight,
            ),
            left: Container(
              color: colorDeep,
            ),
          ),
        ),
      )
    ];
  }

  renderMiddle() {
    return [
      ZPositioned(
        rotate: const ZVector.only(z: pi * 0.28),
        child: ZPositioned(
          translate: const ZVector(80, 40, 0),
          child: ZBoxToBoxAdapter(
            height: 100,
            width: 30,
            depth: 30,
            color: color,
            front: Container(
              color: color,
            ),
            top: Container(
              color: colorLight,
            ),
            right: Container(
              color: colorDeep,
            ),
          ),
        ),
      ),
      ZPositioned(
        rotate: const ZVector.only(z: -pi * 0.28),
        child: ZPositioned(
          translate: const ZVector(20, 40, 0),
          child: ZBoxToBoxAdapter(
            height: 100,
            width: 30,
            depth: 25,
            color: color,
            front: Container(
              color: color,
            ),
            top: Container(
              height: 100,
              width: 30,
              color: colorLight,
            ),
            left: Container(
              color: colorDeep,
            ),
          ),
        ),
      )
    ];
  }

  renderTop() {
    return [
      ZPositioned(
        rotate: const ZVector.only(z: -pi / 4),
        child: ZPositioned(
          translate: const ZVector(50, -30, 0),
          child: ZBoxToBoxAdapter(
            height: 40,
            width: 40,
            depth: 30,
            color: color,
            front: Container(
              color: color,
            ),
            top: Container(
              color: colorLight,
            ),
            right: Container(
              color: colorLight,
            ),
            left: Container(
              color: colorDeep,
            ),
            bottom: Container(
              color: colorDeep,
            ),
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JueJin3DBoxLogoDemoPage"),
      ),
      body: Center(
        child: ZDragDetector(builder: (context, controller) {
          return ZIllustration(
            zoom: 1,
            children: [
              ZPositioned(
                rotate: controller.rotate,
                child: ZPositioned(
                  translate: const ZVector.only(x: -40),
                  child: ZGroup(
                    children: [
                      ...renderBottom(),
                      ...renderMiddle(),
                      ...renderTop(),
                    ],
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
