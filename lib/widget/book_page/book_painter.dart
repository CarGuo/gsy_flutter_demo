import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'cal_point.dart';

enum PositionStyle { STYLE_TOP_RIGHT, STYLE_LOWER_RIGHT }

///页面画笔
class BookPainter extends CustomPainter {
  CalPoint a, f, g, e, h, c, j, b, k, d, i;

  double viewWidth;
  double viewHeight;

  Paint bgPaint; //背景画笔
  Paint pointPaint; //绘制各标识点的画笔
  Paint pathAPaint, pathCPaint, pathBPaint; //绘制A区域画笔
  Path pathA, pathC, pathB;

  PositionStyle style;

  BookPainter(
      {@required this.viewWidth,
      @required this.viewHeight,
      @required x,
      @required y,
      @required this.style}) {
    init(x, y);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    onDraw(canvas, size);
  }

  init(x, y) {
    _initPoint();

    _selectCalPoint(x, y);

    _calcPointsXY(a, f);

    _initPaintAndPath();
  }

  _initPoint() {
    ///计算起始触摸点
    a = CalPoint();

    ///计算的位置起点
    f = CalPoint();

    ///其他坐标
    g = new CalPoint();
    e = new CalPoint();
    h = new CalPoint();
    c = new CalPoint();
    j = new CalPoint();
    b = new CalPoint();
    k = new CalPoint();
    d = new CalPoint();
    i = new CalPoint();
  }

  _selectCalPoint(x, y) {
    switch (style) {
      case PositionStyle.STYLE_TOP_RIGHT:
        f.x = viewWidth;
        f.y = 0;
        break;
      case PositionStyle.STYLE_LOWER_RIGHT:
        f.x = viewWidth;
        f.y = viewHeight;
        break;
      default:
        break;
    }
    a.x = x;
    a.y = y;
  }

  _initPaintAndPath() {
    pointPaint = new Paint();
    pointPaint.color = Colors.red;

    bgPaint = new Paint();
    bgPaint.color = Colors.white;

    pathAPaint = new Paint();
    pathAPaint.color = Colors.purple;
    pathAPaint.isAntiAlias = true;

    pathCPaint = new Paint();
    pathCPaint.color = Colors.yellow;
    pathCPaint.blendMode = BlendMode.dstATop;
    pathCPaint.isAntiAlias = true;

    pathBPaint = new Paint();
    pathBPaint.color = Colors.lightBlue;
    pathBPaint.blendMode = BlendMode.dstATop;
    pathBPaint.isAntiAlias = true;

    pathC = new Path();
    pathA = new Path();
    pathB = new Path();
  }

  void onDraw(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), bgPaint);

    if (a.x == -1 && a.y == -1) {
      canvas.drawPath(_getPathDefault(), pathAPaint);
    } else {
      if (f.x == viewWidth && f.y == 0) {
        canvas.drawPath(_getPathAFromTopRight(), pathAPaint);
      } else if (f.x == viewWidth && f.y == viewHeight) {
        canvas.drawPath(_getPathAFromLowerRight(), pathAPaint);
      }
      canvas.drawPath(_getPathC(), pathCPaint);
      canvas.drawPath(_getPathB(), pathBPaint);
    }

    canvas.restore();
  }

  /// 计算各点坐标
  void _calcPointsXY(CalPoint a, CalPoint f) {
    g.x = (a.x + f.x) / 2;
    g.y = (a.y + f.y) / 2;

    e.x = g.x - (f.y - g.y) * (f.y - g.y) / (f.x - g.x);
    e.y = f.y;

    h.x = f.x;
    h.y = g.y - (f.x - g.x) * (f.x - g.x) / (f.y - g.y);

    c.x = e.x - (f.x - e.x) / 2;
    c.y = f.y;

    j.x = f.x;
    j.y = h.y - (f.y - h.y) / 2;

    b = _getInterPoint(a, e, c, j);
    k = _getInterPoint(a, h, c, j);

    d.x = (c.x + 2 * e.x + b.x) / 4;
    d.y = (2 * e.y + c.y + b.y) / 4;

    i.x = (j.x + 2 * h.x + k.x) / 4;
    i.y = (2 * h.y + j.y + k.y) / 4;
  }

  /// 计算两线段相交点坐标
  CalPoint _getInterPoint(
      CalPoint lineOneToPointOne,
      CalPoint lineOneToPointTwo,
      CalPoint lineTwoToPointOne,
      CalPoint lineTwoToPointTwo) {
    double x1, y1, x2, y2, x3, y3, x4, y4;
    x1 = lineOneToPointOne.x;
    y1 = lineOneToPointOne.y;
    x2 = lineOneToPointTwo.x;
    y2 = lineOneToPointTwo.y;
    x3 = lineTwoToPointOne.x;
    y3 = lineTwoToPointOne.y;
    x4 = lineTwoToPointTwo.x;
    y4 = lineTwoToPointTwo.y;

    double pointX =
        ((x1 - x2) * (x3 * y4 - x4 * y3) - (x3 - x4) * (x1 * y2 - x2 * y1)) /
            ((x3 - x4) * (y1 - y2) - (x1 - x2) * (y3 - y4));
    double pointY =
        ((y1 - y2) * (x3 * y4 - x4 * y3) - (x1 * y2 - x2 * y1) * (y3 - y4)) /
            ((y1 - y2) * (x3 - x4) - (x1 - x2) * (y3 - y4));

    return CalPoint.data(pointX, pointY);
  }

  ///获取f点在右下角的pathA
  Path _getPathAFromLowerRight() {
    pathA.reset();
    pathA.lineTo(0, viewHeight); //移动到左下角
    pathA.lineTo(c.x, c.y); //移动到c点
    pathA.quadraticBezierTo(e.x, e.y, b.x, b.y); //从c到b画贝塞尔曲线，控制点为e
    pathA.lineTo(a.x, a.y); //移动到a点
    pathA.lineTo(k.x, k.y); //移动到k点
    pathA.quadraticBezierTo(h.x, h.y, j.x, j.y); //从k到j画贝塞尔曲线，控制点为h
    pathA.lineTo(viewWidth, 0); //移动到右上角
    pathA.close(); //闭合区域
    return pathA;
  }

  ///获取f点在右上角的pathA
  Path _getPathAFromTopRight() {
    pathA.reset();
    pathA.lineTo(c.x, c.y); //移动到c点
    pathA.quadraticBezierTo(e.x, e.y, b.x, b.y); //从c到b画贝塞尔曲线，控制点为e
    pathA.lineTo(a.x, a.y); //移动到a点
    pathA.lineTo(k.x, k.y); //移动到k点
    pathA.quadraticBezierTo(h.x, h.y, j.x, j.y); //从k到j画贝塞尔曲线，控制点为h
    pathA.lineTo(viewWidth, viewHeight); //移动到右下角
    pathA.lineTo(0, viewHeight); //移动到左下角
    pathA.close();
    return pathA;
  }

  ///翻页折角区域
  Path _getPathC() {
    pathC.reset();
    pathC.moveTo(i.x, i.y); //移动到i点
    pathC.lineTo(d.x, d.y); //移动到d点
    pathC.lineTo(b.x, b.y); //移动到b点
    pathC.lineTo(a.x, a.y); //移动到a点
    pathC.lineTo(k.x, k.y); //移动到k点
    pathC.close(); //闭合区域
    return pathC;
  }

  ///翻页后剩余区域
  Path _getPathB() {
    pathB.reset();
    pathB.lineTo(0, viewHeight); //移动到左下角
    pathB.lineTo(viewWidth, viewHeight); //移动到右下角
    pathB.lineTo(viewWidth, 0); //移动到右上角
    pathB.close(); //闭合区域
    return pathB;
  }

  ///绘制默认的界面
  Path _getPathDefault() {
    pathA.reset();
    pathA.lineTo(0, viewHeight);
    pathA.lineTo(viewWidth, viewHeight);
    pathA.lineTo(viewWidth, 0);
    pathA.close();
    return pathA;
  }

  ///利用 Paragraph 实现 _drawText
  _drawText(
      Canvas canvas, String text, Color color, double width, Offset offset,
      {TextAlign textAlign = TextAlign.start, double fontSize}) {
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

  _drawTestPoint() {
//    _drawText(canvas, "a", pointPaint.color, size.width, Offset(a.x, a.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "f", pointPaint.color, size.width, Offset(f.x, f.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "g", pointPaint.color, size.width, Offset(g.x, g.y),
//        textAlign: TextAlign.left, fontSize: 25);
//
//    _drawText(canvas, "e", pointPaint.color, size.width, Offset(e.x, e.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "h", pointPaint.color, size.width, Offset(h.x, h.y),
//        textAlign: TextAlign.left, fontSize: 25);
//
//    _drawText(canvas, "c", pointPaint.color, size.width, Offset(c.x, c.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "j", pointPaint.color, size.width, Offset(j.x, j.y),
//        textAlign: TextAlign.left, fontSize: 25);
//
//    _drawText(canvas, "b", pointPaint.color, size.width, Offset(b.x, b.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "k", pointPaint.color, size.width, Offset(k.x, k.y),
//        textAlign: TextAlign.left, fontSize: 25);
//
//    _drawText(canvas, "d", pointPaint.color, size.width, Offset(d.x, d.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "i", pointPaint.color, size.width, Offset(i.x, i.y),
//        textAlign: TextAlign.left, fontSize: 25);
  }
}
