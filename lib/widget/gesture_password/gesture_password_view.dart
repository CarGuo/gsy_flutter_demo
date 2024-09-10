import 'package:flutter/material.dart';

import 'src/gesture_view_controller.dart';
import 'src/gesture_view_path.dart';
import 'src/gesture_view_point.dart';

class GesturePasswordView extends StatefulWidget {

  /// 圆圈半径
  final double frameRadius;

  /// 圆圈中心点半径
  final double pointRadius;

  /// 圆圈普通状态下颜色
  final Color color;

  /// 圆圈选中颜色
  final Color highlightColor;

  /// 连线颜色
  final Color pathColor;

  /// 连线半径
  final double pathWidth;

  /// 手势结果
  final Function(List<int>)? onDone;

  const GesturePasswordView({
    super.key,
    this.pointRadius = 10,
    this.frameRadius = 40,
    this.color = Colors.grey,
    this.highlightColor = Colors.blue,
    this.pathColor = Colors.blue,
    this.onDone,
    this.pathWidth = 5,
  });

  @override
  State<StatefulWidget> createState() => _GesturePasswordState();
}

class _GesturePasswordState extends State<GesturePasswordView> {
  final GestureViewController controller = GestureViewController();

  @override
  void initState() {
    controller.initParameters(
      pointRadius: widget.pointRadius,
      frameRadius: widget.frameRadius,
      color: widget.color,
      highlightColor: widget.highlightColor,
      pathColor: widget.pathColor,
      onFinishGesture: widget.onDone,
      pathWidth: widget.pathWidth,
      updateView: (){
        setState(() {});
      }
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.setPointValues());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: controller.globalKey,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          GestureDotsPanelWidget(points: controller.point),
          GestureViewPathWidget(
            points: controller.pathPoint,
            pathWidth: controller.pathWidth,
            color: controller.pathColor,
            onPanDown: controller.onPanDown,
            onPanEnd: controller.onPanEnd,
            onPanUpdate: controller.onPanUpdate,
          ),
        ],
      ),
    );
  }
}
