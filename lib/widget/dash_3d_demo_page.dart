import 'package:flutter/material.dart';
import 'package:zflutter/zflutter.dart';

class Dash3dDemoPage extends StatefulWidget {
  const Dash3dDemoPage({super.key});

  @override
  State<Dash3dDemoPage> createState() => _Dash3dDemoPageState();
}

class _Dash3dDemoPageState extends State<Dash3dDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  AnimationController? dashController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    update();
  }

  update() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        animationController.forward(from: 0).whenComplete(() => update());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Animation> dashAnimations = List.generate(
        20,
        (index) => Tween<double>(
              begin: 0,
              end: index.isEven ? 1 : -1,
            ).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval(
                  index * 0.05,
                  (index + 1) * 0.05,
                  curve: Curves.ease,
                ),
              ),
            ));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dash3dDemoPage"),
      ),
      body: Center(
        child: ZDragDetector(builder: (context, controller) {
          return AnimatedBuilder(
              animation: animationController,
              builder: (context, _) {
                final dash = dashAnimations.fold<double>(
                    0, (previousValue, element) => previousValue + element.value);
                return ZIllustration(
                  zoom: 5,
                  children: [
                    ZPositioned(
                      rotate: controller.rotate,
                      child: Dash(flight: dash),
                    )
                  ],
                );
              });
        }),
      ),
    );
  }
}

const Color darkBlue = Color(0xff5CC0EF);

const Color bodyColor = Color(0xffa0e6fe);

const Color brown = Color(0xff967C40);

const Color green = Color(0xff71d3c7);

const Color black = Color(0xff000000);

class Dash extends StatelessWidget {
  final double flight;

  const Dash({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return ZPositioned(
      translate: ZVector.only(y: flight),
      child: ZGroup(
        children: [
          ZShape(
            stroke: 40,
            fill: true,
            color: bodyColor,
          ),
          ZPositioned(translate: const ZVector.only(y: -20), child: hair()),
          ZPositioned(
            translate: const ZVector.only(x: 0, y: 12, z: -17),
            child: ZShape(
              stroke: 2,
              fill: true,
              path: [
                const ZMove.vector(
                  ZVector.only(x: 0, y: 0, z: 0),
                ),
                ZArc.list([
                  const ZVector.only(x: 5, y: -10, z: -8),
                  const ZVector.only(x: 8, y: -15, z: -10),
                ], null),
                ZArc.list([
                  const ZVector.only(x: 0, y: -25, z: -12),
                  const ZVector.only(x: -8, y: -15, z: -10),
                ], null),
                ZArc.list([
                  const ZVector.only(x: -5, y: -10, z: -8),
                  const ZVector.only(x: 0, y: -0, z: 0),
                ], null)
              ],
              color: darkBlue,
            ),
          ),
          ZPositioned(
            translate: const ZVector.only(x: -23, z: -2),
            rotate:
                ZVector.only(y: tau / 4 - tau / 40 - flight / 12, x: -tau / 12),
            child: wing(),
          ),
          ZPositioned(
            translate: const ZVector.only(x: 23, z: -2),
            rotate:
                ZVector.only(y: tau / 4 + tau / 40 + flight / 12, x: -tau / 12),
            child: wing(),
          ),
          ZGroup(
            sortMode: SortMode.stack,
            children: [
              ZPositioned(
                translate: const ZVector.only(x: 0, y: 0, z: 2),
                child: ZShape(
                  stroke: 2,
                  fill: true,
                  path: [
                    const ZMove.vector(
                      ZVector.only(x: 0, y: 0, z: 20),
                    ),
                    ZArc.list([
                      const ZVector.only(x: -30, y: 7, z: 15),
                      const ZVector.only(x: 0, y: 15, z: 15),
                    ], null),
                    ZArc.list([
                      const ZVector.only(x: 30, y: 7, z: 15),
                      const ZVector.only(x: 0, y: 0, z: 20),
                    ], null)
                  ],
                  color: Colors.white,
                ),
              ),
              ZPositioned(
                translate: const ZVector.only(z: 20),
                child: ZGroup(sortMode: SortMode.update, children: [
                  eye(translate: const ZVector.only(x: -7)),
                  eye(translate: const ZVector.only(x: 7)),
                  ZPositioned(
                      rotate: const ZVector.only(x: -tau / 20),
                      translate: const ZVector.only(y: 7),
                      child: ZCone(
                        color: brown,
                        length: 10,
                        stroke: 2,
                        diameter: 3,
                      )),
                ]),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// Todo: Migrate to widget system and use StatelessWidgets instead of functions
ZGroup hair() => ZGroup(
      children: [
        ZPositioned(
          translate: const ZVector.only(y: -1, z: 0),
          child: ZEllipse(
            height: 6,
            width: 3,
            stroke: 4,
            color: bodyColor,
          ),
        ),
        ZPositioned(
          translate: const ZVector.only(y: 1, x: -2),
          rotate: const ZVector.only(z: -tau / 8),
          child: ZEllipse(
            height: 6,
            width: 3,
            stroke: 4,
            color: bodyColor,
          ),
        ),
        ZPositioned(
          translate: const ZVector.only(y: 1, x: 2),
          rotate: const ZVector.only(z: tau / 8),
          child: ZEllipse(
            height: 6,
            width: 3,
            stroke: 4,
            color: bodyColor,
          ),
        ),
      ],
    );

ZGroup eye({ZVector translate = ZVector.zero}) {
  return ZGroup(sortMode: SortMode.stack, children: [
    ZPositioned(
      translate: translate,
      child: ZCircle(
        stroke: 2,
        fill: true,
        diameter: 15,
        color: darkBlue,
      ),
    ),
    ZPositioned(
      translate: translate,
      scale: const ZVector.all(1.2),
      child: ZEllipse(
        stroke: 2,
        fill: true,
        width: 6,
        height: 8,
        color: green,
      ),
    ),
    ZPositioned(
      translate: translate + const ZVector.only(x: 0, y: 0, z: 0.1),
      child: ZEllipse(
        stroke: 2,
        fill: true,
        width: 6,
        height: 8,
        color: black,
      ),
    ),
    ZPositioned(
      translate: translate + const ZVector.only(x: 2, y: -2, z: 1),
      child: ZCircle(
        stroke: 1,
        fill: true,
        diameter: 1,
        color: Colors.white,
      ),
    )
  ]);
}

ZGroup wing() => ZGroup(
      children: [
        ZPositioned(
            scale: const ZVector.all(1.2),
            child: ZEllipse(
              stroke: 4,
              fill: true,
              width: 20,
              height: 15,
              color: darkBlue,
            )),
      ],
    );
