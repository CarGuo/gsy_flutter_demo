import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

class TickClickDemoPage extends StatefulWidget {
  @override
  _TickClickPageState createState() => _TickClickPageState();
}

class _TickClickPageState extends State<TickClickDemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  Animation? animation;

  int? value = 0;

  @override
  void initState() {
    super.initState();
    controller =
        new AnimationController(vsync: this, duration: Duration(seconds: 59));
    animation = Tween(begin: 60.0, end: 1.0).animate(controller)
      ..addListener(() {
        if (animation!.value.toInt() != value) {
          value = animation!.value.toInt();
          setState(() {});
        }
      });

    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("TickClickDemoPage"),
      ),

      ///用封装好的 Transition 做动画
      body: new Container(
        child: Center(
          child: new Container(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            color: Colors.greenAccent,
            child: CustomPaint(
              ///直接使用值做动画
              foregroundPainter: _ClickAnimationPainter(animation),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClickAnimationPainter extends CustomPainter {
  ///宽度
  double paintWidth = 0;

  ///高度
  double paintHeight = 0;

  ///小时的半径
  double hourRadius = 0;

  ///分钟的半径
  double minRadius = 0;

  ///秒的半径
  double secondRadius = 0;

  ///当前时间
  DateTime dateTime = DateTime.now();

  ///小时的角度
  double? hourDegrees;

  ///分钟的角度
  double? minDegrees;

  ///秒的角度
  late double secondDegrees;

  double? fontSize;

  Animation? animation;

  _ClickAnimationPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    init(size);
    try {
      if (Platform.isAndroid == true || Platform.isIOS == true) {
        canvas.drawColor(Colors.black, BlendMode.clear);
      }
    } catch (e) {}
    canvas.save();
    canvas.translate(paintWidth / 2, paintHeight / 2);

    drawTextInfo(canvas, size);
    drawHourCircle(canvas, hourDegrees!, size);
    drawMinuteCircle(canvas, minDegrees!, size);
    drawSecondCircle(canvas, secondDegrees, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void init(Size size) {
    paintWidth = size.width;
    paintHeight = size.height;
    hourRadius = paintWidth * 0.233;
    minRadius = paintWidth * 0.34;
    secondRadius = paintWidth * 0.35;
    fontSize = hourRadius * 0.15;

    ///小时的角度
    hourDegrees = -2 * math.pi / 12 * (dateTime.hour - 1);

    ///分钟的角度
    minDegrees = -2 * math.pi / 60 * (dateTime.minute - 1);

    ///秒的角度
    secondDegrees = -2 * math.pi / 60 * (dateTime.second - 1);

    double? hourD = hourDegrees;
    double? minD = minDegrees;
    double secondD = secondDegrees;

    ///转 30 个角度
    if (dateTime.minute == 0 && dateTime.second == 0) {
      hourDegrees = (hourD! + 2 * math.pi / 360 * 30);
    }

    ///转6个角度
    if (dateTime.second == 0) {
      minDegrees = (minD! + 2 * math.pi / 360 * 6);
    }

    ///转6个调度
    secondDegrees = (secondD + 2 * math.pi / 360 * 6);
  }

  void drawTextInfo(Canvas canvas, Size size) {
    double textSize = 100;

    ///小时分钟
    int hour = dateTime.hour;
    String minute = ((dateTime.minute) < 10)
        ? "0${(dateTime.minute)}"
        : dateTime.minute.toString();
    drawText(canvas, "$hour:$minute", Color(0xFFFFFFFF), textSize,
        Offset(-textSize / 2, -textSize / 3),
        fontSize: hourRadius * 0.4);

    ///月份、星期
    String month = ((dateTime.month + 1) < 10)
        ? "0${(dateTime.month + 1)}"
        : (dateTime.month + 1).toString();
    String day = dateTime.day.toString();
    String dayOfWeek = dateTime.weekday.toString();
    drawText(canvas, "$month.$day 星期$dayOfWeek", Color(0xFFFFFFFF), textSize,
        Offset(-textSize / 2, 20),
        fontSize: hourRadius * 0.16);
  }

  void drawHourCircle(Canvas canvas, double degrees, Size size) {
    canvas.save();

    ///先转个大圈
    canvas.rotate(degrees);

    for (int i = 0; i < 12; i++) {
      canvas.save();
      double iDeg = 2 * math.pi / 12 * i;
      canvas.rotate(iDeg);
      bool colorTime = ((iDeg / (2 * math.pi) * 360).floor() +
                  (degrees / (2 * math.pi) * 360).floor())
              .abs()
              .toInt() ==
          360;
      Color color = colorTime ? Colors.blueGrey : Colors.white;
      drawText(canvas, "${(i + 1).toString()}点", color, hourRadius, Offset.zero,
          textAlign: TextAlign.right, fontSize: fontSize);
      canvas.restore();
    }

    canvas.restore();
  }

  void drawMinuteCircle(Canvas canvas, double degrees, Size size) {
    canvas.save();

    ///先转个大圈
    canvas.rotate(degrees);

    for (int i = 0; i < 60; i++) {
      canvas.save();
      double iDeg = 2 * math.pi / 60 * i;
      canvas.rotate(iDeg);
      Color color = colorTime(iDeg, degrees) ? Colors.blueAccent : Colors.white;
      if (i < 59) {
        drawText(
            canvas, "${(i + 1).toString()}分", color, minRadius, Offset.zero,
            textAlign: TextAlign.right, fontSize: fontSize);
      }
      canvas.restore();
    }

    canvas.restore();
  }

  ///绘制秒圈
  void drawSecondCircle(Canvas canvas, double degrees, Size size) {
    canvas.save();

    ///先转个大圈
    canvas.rotate(degrees);

    for (int i = 0; i < 60; i++) {
      canvas.save();
      double iDeg = 2 * math.pi / 60.0 * i;
      canvas.rotate(iDeg);
      Color color = colorTime(iDeg, degrees) ? Colors.blue : Colors.white;
      if (i < 59) {
        drawText(canvas, "${(i + 1).toString()}秒", color, secondRadius,
            Offset(secondRadius, 0),
            textAlign: TextAlign.left, fontSize: fontSize);
      }
      canvas.restore();
    }

    canvas.restore();
  }

  ///颜色改变的偏移幅度
  bool colorTime(double iDeg, double degrees) {
    return ((iDeg + degrees).abs() <= 0.0001);
  }

  ///利用 Paragraph 实现 drawText
  drawText(Canvas canvas, String text, Color color, double width, Offset offset,
      {TextAlign textAlign = TextAlign.center, double? fontSize}) {
    ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: textAlign,
      fontSize: fontSize,
    ));
    pb.pushStyle(ui.TextStyle(color: color));
    pb.addText(text);
    ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: width);

    ///这里需要先layout, 后面才能获取到文字高度
    ui.Paragraph paragraph = pb.build()..layout(pc);
    canvas.drawParagraph(paragraph, offset);
  }
}
