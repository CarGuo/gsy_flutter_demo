import 'package:flutter/material.dart';
import 'package:zflutter/zflutter.dart';

class JueJin3DLogoDemoPage extends StatefulWidget {
  const JueJin3DLogoDemoPage({super.key});

  @override
  State<JueJin3DLogoDemoPage> createState() => _JueJin3DLogoDemoPageState();
}

class _JueJin3DLogoDemoPageState extends State<JueJin3DLogoDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JueJin3DLogoDemoPage"),
      ),
      body: Center(
        child: ZDragDetector(builder: (context, controller) {
          return ZIllustration(
            zoom: 10,
            children: [
              ZPositioned(
                  rotate: controller.rotate,
                  child: ZGroup(
                    children: [
                      ZPositioned(
                        translate: const ZVector(-17.5865, -23.2854 / 2, 0),
                        child: ZShape(
                          color: const Color(0xFF1E80FF),
                          stroke: 2,
                          fill: true,
                          path: [
                            const ZMove.vector(ZVector(17.5872, 6.77268, 0)),
                            ZLine.vector(const ZVector(21.823, 3.40505, 0)),
                            ZLine.vector(const ZVector(17.58723, 0.00748237, 0)),
                            ZLine.vector(const ZVector(17.5835, 0, 0)),
                            ZLine.vector(const ZVector(13.3552, 3.39757, 0)),
                            ZLine.vector(const ZVector(17.5835, 6.76894, 0)),
                            ZLine.vector(const ZVector(17.5872, 6.77268, 0)),
                          ],
                        ),
                      ),
                      ZPositioned(
                        translate: const ZVector(-17.5865, -23.2854 / 2, 0),
                        child: ZShape(
                          color: const Color(0xFF1E80FF),
                          stroke: 2,
                          fill: true,
                          path: [
                            const ZMove.vector(ZVector(17.5865, 17.3955, 0)),
                            ZLine.vector(const ZVector(28.5163, 8.77432, 0)),
                            ZLine.vector(const ZVector(25.5528, 6.39453, 0)),
                            ZLine.vector(const ZVector(17.5902, 12.6808, 0)),
                            ZLine.vector(const ZVector(17.5865, 12.6808, 0)),
                            ZLine.vector(const ZVector(9.62018, 6.40201, 0)),
                            ZLine.vector(const ZVector(6.6604, 8.78181, 0)),
                            ZLine.vector(const ZVector(17.5828, 17.39928, 0)),
                            ZLine.vector(const ZVector(17.5865, 17.3955, 0)),
                          ],
                        ),
                      ),
                      ZPositioned(
                        translate: const ZVector(-17.5865, -23.2854 / 2, 0),
                        child: ZShape(
                          color: const Color(0xFF1E80FF),
                          stroke: 2,
                          fill: true,
                          path: [
                            const ZMove.vector(ZVector(17.5865, 23.2854, 0)),
                            ZLine.vector(const ZVector(17.5828, 23.2891, 0)),
                            ZLine.vector(const ZVector(2.95977, 11.7531, 0)),
                            ZLine.vector(const ZVector(0, 14.1291, 0)),
                            ZLine.vector(const ZVector(0.284376, 14.3574, 0)),
                            ZLine.vector(const ZVector(17.5865, 28, 0)),
                            ZLine.vector(const ZVector(28.5238, 19.3752, 0)),
                            ZLine.vector(const ZVector(35.1768, 14.12542, 0)),
                            ZLine.vector(const ZVector(32.2133, 11.7456, 0)),
                            ZLine.vector(const ZVector(17.5865, 23.2854, 0)),
                          ],
                        ),
                      ),
                    ],
                  ))
            ],
          );
        }),
      ),
    );
  }
}
