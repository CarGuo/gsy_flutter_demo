import 'dart:async';
import 'dart:io';
import 'dart:math' as Math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const radius = 6.0;

class AnimProgressImgDemoPage extends StatefulWidget {
  @override
  _AnimProgressImgDemoPageState createState() =>
      _AnimProgressImgDemoPageState();
}

class _AnimProgressImgDemoPageState extends State<AnimProgressImgDemoPage>
    with TickerProviderStateMixin {
  late AnimationController animController;
  late Animation animAnimation;
  Timer? progressTimer;
  int progress = 0;
  AnimProgressStatus progressType = AnimProgressStatus.READY;

  @override
  void initState() {
    super.initState();

    animController = new AnimationController(vsync: this)
      ..duration = Duration(milliseconds: 1000);
    this.animAnimation = CurvedAnimation(
      parent: animController,
      curve: Curves.linear,
    )..addListener(updateState);
  }

  @override
  void dispose() {
    animAnimation.removeListener(updateState);
    animController.stop();
    progressTimer?.cancel();
    super.dispose();
  }

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("AnimProgressImgDemoPage"),
      ),
      body: Container(
        child: Center(
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: new Image.asset(
                  "static/gsy_cat.png",
                  fit: BoxFit.cover,
                  width: 300,
                  height: 200,
                ),
              ),
              SizedBox(
                width: 300,
                height: 200,
                child: CustomPaint(
                  painter: AnimProgressPainter(
                      status: progressType,
                      animatorValue: animAnimation.value,
                      finishAnimValue: animAnimation.value,
                      progress: progress),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          progress = 0;
          progressTimer?.cancel();
          progressTimer = Timer.periodic(Duration(milliseconds: 30), (_) {
            if (progress == 100) {
              progress = 0;
              progressTimer?.cancel();
              progressType = AnimProgressStatus.FINISH;
              animController.reset();
              animController.forward();
            } else {
              setState(() {
                progress += 1;
              });
            }
          });
          progressType = AnimProgressStatus.PROGRESS;
          animController.reset();
          animController.repeat(reverse: true);
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}

enum AnimProgressStatus {
  READY,
  PROGRESS,
  FINISH,
}

class AnimProgressPainter extends CustomPainter {
  final AnimProgressStatus status;
  final int? progress;

  final double finishAnimValue;

  final double animatorValue;

  final Path path = Path();

  AnimProgressPainter(
      {this.status = AnimProgressStatus.PROGRESS,
      this.progress,
      this.finishAnimValue = 0,
      this.animatorValue = 0});

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    var width = size.width;
    var height = size.height;

    var outRadius = 50.0;
    var innRadius = 44.0;

    canvas.save();
    path.addRRect(
        new RRect.fromLTRBR(0, 0, width, height, Radius.circular(radius)));
    canvas.clipPath(path);
    Paint paint = Paint();
    paint.color = Color(0x99000000);
    canvas.save();
    canvas.translate(width / 2, height / 2);

    if (status == AnimProgressStatus.PROGRESS) {
      canvas.drawPaint(paint);
      canvas.saveLayer(
          Rect.fromLTRB(-outRadius, -outRadius, outRadius, outRadius), paint);
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white.withAlpha((animatorValue * 255).toInt());
      final Rect arcRect =
          Rect.fromCircle(center: Offset.zero, radius: outRadius - 10);

      try {
        if (Platform.isAndroid == true || Platform.isIOS == true)
          paint.shader =
              RadialGradient(tileMode: TileMode.mirror, radius: 0.1, colors: [
            Colors.transparent,
            Colors.white.withAlpha((100 * animatorValue).toInt()),
            Colors.white.withAlpha((255 * animatorValue).toInt()),
            Colors.transparent
          ]).createShader(arcRect);
      } catch (e) {}

      canvas.drawCircle(Offset(0, 0),
          innRadius + (outRadius - innRadius - 3) * animatorValue, paint);

      paint.blendMode = BlendMode.dstOut;
      paint.shader = null;
      paint.color = Colors.white;
      canvas.drawCircle(Offset(0, 0), innRadius, paint);

      paint.blendMode = BlendMode.srcOver;

      canvas.restore();

      canvas.translate(-width / 2, 0);
      var text = "$progress%";
      _drawText(canvas, text, Colors.white.withAlpha((100).toInt()), width,
          Offset.zero);
    } else if (status == AnimProgressStatus.FINISH) {
      canvas.saveLayer(
          Rect.fromLTRB(-width / 2, -height / 2, width / 2, height / 2), paint);
      canvas.drawPaint(paint);
      var maxRadius = Math.sqrt(
          Math.pow(width.toDouble(), 2.0) + Math.pow(height.toDouble(), 2.0));
      paint.blendMode = BlendMode.dstOut;
      paint.color = Colors.white;
      canvas.drawCircle(Offset(0, 0),
          (outRadius + (maxRadius / 2 - outRadius) * finishAnimValue), paint);
      paint.blendMode = BlendMode.srcOver;
      canvas.restore();
    }
    canvas.restore();
    canvas.restore();
  }

  ///利用 Paragraph 实现 _drawText
  _drawText(
      Canvas canvas, String text, Color color, double width, Offset offset,
      {TextAlign textAlign = TextAlign.center, double fontSize = 14}) {
    ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: textAlign,
      fontSize: fontSize,
    ));
    pb.pushStyle(ui.TextStyle(color: color));
    pb.addText(text);
    ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: width);

    ///这里需要先layout, 后面才能获取到文字高度
    ui.Paragraph paragraph = pb.build()..layout(pc);
    canvas.drawParagraph(paragraph, offset + Offset(0, -paragraph.height / 2));
  }
}
