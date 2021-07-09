import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'cal_point.dart';
import 'dart:math' as Math;

///触摸类型
enum PositionStyle {
  STYLE_TOP_RIGHT,
  STYLE_LOWER_RIGHT,
  STYLE_LEFT,
  STYLE_RIGHT,
  STYLE_MIDDLE,
}

///页面画笔
class BookPainter extends CustomPainter {
  late CalPoint a, f, g, e, h, c, j, b, k, d, i;

  double? viewWidth;
  double? viewHeight;

  ///顶部区域
  Path? pathA;

  ///折叠出来的区域
  Path? pathC;

  ///背部区域
  Path? pathB;

  ///背景画笔
  late Paint bgPaint;

  ///绘制区域画笔
  late Paint pathAPaint, pathCPaint, pathBPaint;

  ///触摸点的区域
  PositionStyle style;

  ///回调数据外放
  ValueChanged changedPoint;

  ///背景色
  Color bgColor;

  ///前景色
  Color frontColor;

  ///文本一
  String text;

  ///文本二
  String text2;

  ///A区域左阴影矩形短边长度参考值
  double lPathAShadowDis = 0;

  /// A区域右阴影矩形短边长度参考值
  double rPathAShadowDis = 0;

  BookPainter({
    required this.text,
    required this.text2,
    required this.viewWidth,
    required this.viewHeight,
    required this.frontColor,
    required this.bgColor,
    required CalPoint cur,
    required CalPoint pre,
    required this.changedPoint,
    required this.style,
    bool? limitAngle,
  }) {
    init(cur, pre, limitAngle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    onDraw(canvas, size);
  }

  init(CalPoint cur, CalPoint pre, bool? limitAngle) {
    ///初始化点
    _initPoint();

    ///选择工作模型
    _selectCalPoint(cur, pre, limitAngle: limitAngle);

    ///计算
    _calcPointsXY(a, f);

    ///初始化
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

    pathB = new Path();
    pathA = new Path();
    pathC = new Path();
  }

  _selectCalPoint(CalPoint cur, CalPoint pre, {bool? limitAngle = true}) {
    a.x = cur.x;
    a.y = cur.y;
    doCalAngle() {
      CalPoint touchPoint = CalPoint.data(cur.x, cur.y);
      if (f.x != null &&
          touchPoint.x != null &&
          (limitAngle != null && limitAngle)) {
        ///如果大于0则设置a点坐标重新计算各标识点位置，否则a点坐标不变
        if (_calcPointCX(touchPoint, f) > 0) {
          changedPoint.call(cur);
          _calcPointsXY(a, f);
        } else {
          a.x = pre.x;
          a.y = pre.y;
          _calcPointsXY(a, f);
        }
      } else if (_calcPointCX(touchPoint, f) < 0) {
        ///如果c点x坐标小于0则重新测量a点坐标
        _calcPointAByTouchPoint();
        _calcPointsXY(a, f);
      } else {
        a.x = pre.x;
        a.y = pre.y;
      }
    }

    switch (style) {
      case PositionStyle.STYLE_TOP_RIGHT:
        f.x = viewWidth;
        f.y = 0;
        doCalAngle();
        break;
      case PositionStyle.STYLE_LOWER_RIGHT:
        f.x = viewWidth;
        f.y = viewHeight;
        doCalAngle();
        break;
      case PositionStyle.STYLE_LEFT:
      case PositionStyle.STYLE_RIGHT:
      case PositionStyle.STYLE_MIDDLE:
        a.y = viewHeight! - 1;
        f.x = viewWidth;
        f.y = viewHeight;
        _calcPointsXY(a, f);
        break;
      default:
        break;
    }
  }

  _initPaintAndPath() {
    bgPaint = new Paint();
    bgPaint.color = Colors.white;

    pathAPaint = new Paint();
    pathAPaint.color = bgColor;
    pathAPaint.isAntiAlias = true;

    pathCPaint = new Paint();
    pathCPaint.color = frontColor;
    pathCPaint.blendMode = BlendMode.dstATop;
    pathCPaint.isAntiAlias = true;

    pathBPaint = new Paint();
    pathBPaint.color = Colors.tealAccent;
    pathBPaint.blendMode = BlendMode.dstATop;
    pathBPaint.isAntiAlias = true;

    pathB = new Path();
  }

  void onDraw(Canvas canvas, Size size) async {
    canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), bgPaint);

    if (a.x == -1 && a.y == -1) {
      _drawPathAWithPic(canvas, _getPathDefault()!);
      _drawPathCWithPic(canvas, _getPathDefault()!, pathCPaint);
      _drawPathBWithPic(canvas, _getPathDefault()!);
    } else {
      if (f.x == viewWidth && f.y == 0) {
        _drawPathAWithPic(canvas, _getPathAFromTopRight()!);
        _drawPathCWithPic(canvas, _getPathAFromTopRight()!, pathCPaint);
        _drawPathBWithPic(canvas, _getPathAFromTopRight()!);
      } else if (f.x == viewWidth && f.y == viewHeight) {
        _drawPathAWithPic(canvas, _getPathAFromLowerRight()!);
        _drawPathCWithPic(canvas, _getPathAFromLowerRight()!, pathCPaint);
        _drawPathBWithPic(canvas, _getPathAFromLowerRight()!);
      }
    }

    canvas.restore();
  }

  void _drawPathAWithPic(Canvas canvas, Path pp) {
    canvas.save();
    var pictureRecorder = ui.PictureRecorder();
    var canvasBitmap = Canvas(pictureRecorder);
    var paint = Paint();
    paint.isAntiAlias = true;
    canvasBitmap.drawPath(pp, pathAPaint);
    _drawText(canvasBitmap, text, Colors.black, viewWidth!, Offset.zero);
    var pic = pictureRecorder.endRecording();
    canvas.clipPath(pp);
    canvas.drawPicture(pic);

    if (style == PositionStyle.STYLE_LEFT ||
        style == PositionStyle.STYLE_RIGHT) {
      _drawPathAHorizontalShadow(canvas, pathA!);
    } else if (a.x != -1 && a.y != -1) {
      _drawPathALeftShadow(canvas, pp);
      _drawPathARightShadow(canvas, pp);
    }

    canvas.restore();
  }

  void _drawPathALeftShadow(Canvas canvas, Path pathA) {
    canvas.restore();
    canvas.save();

    var gradientColors = [Color(0x01333333), Color(0x33333333)];

    double? left;
    double? right;
    double top = e.y!;
    double bottom = (e.y! + viewHeight!);

    ui.Gradient gradient;
    if (style == PositionStyle.STYLE_TOP_RIGHT) {
      left = (e.x! - lPathAShadowDis / 2);
      right = (e.x);
      gradient = ui.Gradient.linear(
          Offset(left, top), Offset(right!, top), gradientColors);
    } else {
      left = (e.x);
      right = (e.x! + lPathAShadowDis / 2);

      gradient = ui.Gradient.linear(
          Offset(right, top), Offset(left!, top), gradientColors);
    }
    Paint paint = new Paint()..shader = gradient;

    //裁剪出我们需要的区域
    Path mPath = new Path();
    mPath.moveTo(a.x! - Math.max(rPathAShadowDis, lPathAShadowDis) / 2, a.y!);
    mPath.lineTo(d.x!, d.y!);
    mPath.lineTo(e.x!, e.y!);
    mPath.lineTo(a.x!, a.y!);
    mPath.close();
    //canvas.clipPath(pathA);
    var pn = Path.combine(PathOperation.intersect, pathA, mPath);
    canvas.clipPath(pn);

    canvas.translate(e.x!, e.y!);
    canvas.rotate(Math.atan2(e.x! - a.x!, a.y! - e.y!));
    canvas.translate(-e.x!, -e.y!);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

  void _drawPathARightShadow(Canvas canvas, Path pathA) {
    canvas.restore();
    canvas.save();

    var gradientColors = [
      Color(0x33333333),
      Color(0x01333333),
    ];

    double viewDiagonalLength = _hypot(viewWidth!, viewHeight!) as double; //view对角线长度
    double left = h.x!;
    double right = (h.x! + viewDiagonalLength * 10); //需要足够长的长度
    double? top;
    double? bottom;

    ui.Gradient gradient;
    if (style == PositionStyle.STYLE_TOP_RIGHT) {
      top = (h.y! - rPathAShadowDis / 2);
      bottom = h.y;
      gradient = ui.Gradient.linear(
          Offset(left, bottom!), Offset(left, top), gradientColors);
    } else {
      top = h.y;
      bottom = (h.y! + rPathAShadowDis / 2);

      gradient = ui.Gradient.linear(
          Offset(left, top!), Offset(left, bottom), gradientColors);
    }
    Paint paint = new Paint()..shader = gradient;

    Path mPath = new Path();
    mPath.moveTo(a.x! - Math.max(rPathAShadowDis, lPathAShadowDis) / 2, a.y!);
//        mPath.lineTo(i.x,i.y);
    mPath.lineTo(h.x!, h.y!);
    mPath.lineTo(a.x!, a.y!);
    mPath.close();
    var pn = Path.combine(PathOperation.intersect, pathA, mPath);
    canvas.clipPath(pn);

    canvas.translate(h.x!, h.y!);
    canvas.rotate(Math.atan2(a.y! - h.y!, a.x! - h.x!));
    canvas.translate(-h.x!, -h.y!);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

  void _drawPathAHorizontalShadow(Canvas canvas, Path pathA) {
    canvas.restore();
    canvas.save();

    var radientColors = [Color(0x01333333), Color(0x44333333)]; //渐变颜色数组

    double maxShadowWidth = 30; //阴影矩形最大的宽度
    double left = (a.x! - Math.min(maxShadowWidth, (rPathAShadowDis / 2)));
    double right = a.x!;
    double top = 0;
    double bottom = viewHeight!;

    ui.Gradient gradient = ui.Gradient.linear(
        Offset(left, top), Offset(right, top), radientColors);
    Paint paint = new Paint()..shader = gradient;

    canvas.clipPath(pathA);

    canvas.translate(a.x!, a.y!);
    canvas.rotate(Math.atan2(f.x! - a.x!, f.y! - h.y!));
    canvas.translate(-a.x!, -a.y!);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

  void _drawPathBWithPic(Canvas canvas, Path pa) {
    canvas.save();
    var pictureRecorder = ui.PictureRecorder();
    var canvasBitmap = Canvas(pictureRecorder);
    var paint = Paint();
    paint.isAntiAlias = true;
    canvasBitmap.drawPath(_getPathB()!, pathBPaint);
    _drawText(canvasBitmap, text2, Colors.black, viewWidth!, Offset.zero);

    var pic = pictureRecorder.endRecording();
    var pn = Path.combine(PathOperation.reverseDifference, pa, _getPathB()!);
    pn = Path.combine(PathOperation.reverseDifference, _getPathC()!, pn);
    canvas.clipPath(pn);
    canvas.drawPicture(pic);
    _drawPathBShadow(canvas); //调用阴影绘制方法
    canvas.restore();
  }

  void _drawPathBShadow(Canvas canvas) {
    var gradientColors = [Color(0xf0111111), Color(0x00000000)]; //渐变颜色数组
    int elevation = 6;
    int deepOffset = 0; //深色端的偏移值
    int lightOffset = 0; //浅色端的偏移值
    double aTof = _hypot((a.x! - f.x!), (a.y! - f.y!)) as double; //a到f的距离
    double viewDiagonalLength = _hypot(viewWidth!, viewHeight!) as double; //对角线长度

    double left;
    double right;
    double top = c.y!;
    double bottom = (viewDiagonalLength + c.y!);
    ui.Gradient gradient;
    if (style == PositionStyle.STYLE_TOP_RIGHT) {
      //f点在右上角
      //从左向右线性渐变
      left = (c.x! - deepOffset); //c点位于左上角
      right = (c.x! + aTof / elevation + lightOffset);

      gradient = ui.Gradient.linear(
          Offset(left, top), Offset(right, top), gradientColors);
    } else {
      left = (c.x! - aTof / elevation - lightOffset); //c点位于左下角
      right = (c.x! + deepOffset);
      gradient = ui.Gradient.linear(
          Offset(right, top), Offset(left, top), gradientColors);
    }

    Paint paint = new Paint()
      //..color = Colors.black.withAlpha(80);
      //..blendMode = BlendMode.srcOver
      ..shader = gradient;

    canvas.translate(c.x!, c.y!);
    canvas.rotate(Math.atan2(e.x! - f.x!, h.y! - f.y!));
    canvas.translate(-c.x!, -c.y!);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

  void _drawPathCWithPic(Canvas canvas, Path pathA, Paint pathPaint) {
    canvas.drawPath(_getPathC()!, pathPaint);

    canvas.save();
    var pictureRecorder = ui.PictureRecorder();
    var canvasBitmap = Canvas(pictureRecorder);
    canvasBitmap.drawPath(_getPathB()!, pathPaint);
    var pic = pictureRecorder.endRecording();

    var pn = Path.combine(PathOperation.reverseDifference, pathA, _getPathC()!);
    canvas.clipPath(pn);

    double eh = _hypot(f.x! - e.x!, h.y! - f.y!) as double;
    double sin0 = (f.x! - e.x!) / eh;
    double cos0 = (h.y! - f.y!) / eh;
    //设置翻转和旋转矩阵
    var mMatrixArray = [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.1,
      0.0,
      0.0,
      0.0,
      0.0,
      0.1
    ];
    mMatrixArray[0] = -(1 - 2 * sin0 * sin0);
    mMatrixArray[1] = 2 * sin0 * cos0;
    mMatrixArray[4] = 2 * sin0 * cos0;
    mMatrixArray[5] = 1 - 2 * sin0 * sin0;

    Matrix4 mMatrix = Matrix4.fromList(mMatrixArray);

    mMatrix.leftTranslate(e.x, e.y!);
    mMatrix.translate(-e.x!, -e.y!);
    canvas.transform(mMatrix.storage);
    canvas.drawPicture(pic);
    _drawPathCShadow(canvas); //调用阴影绘制方法
    canvas.restore();
  }

  void _drawPathCShadow(Canvas canvas) {
    var gradientColors = [Color(0x00333333), Color(0xff111111)]; //渐变颜色数组

    int deepOffset = 1; //深色端的偏移值
    int lightOffset = -30; //浅色端的偏移值
    var viewDiagonalLength = _hypot(viewWidth!, viewHeight!); //view对角线长度
    double midpointCe = (c.x! + e.x!) / 2; //ce中点
    double midpointJh = (j.y! + h.y!) / 2; //jh中点
    double minDisToControlPoint = Math.min(
        (midpointCe - e.x!).abs(), (midpointJh - h.y!).abs()); //中点到控制点的最小值

    double left;
    double right;
    double top = c.y!;
    double bottom = (viewDiagonalLength + c.y!);
    ui.Gradient gradient;
    if (style == PositionStyle.STYLE_TOP_RIGHT) {
      left = (c.x! - lightOffset);
      right = (c.x! + minDisToControlPoint + deepOffset);

      gradient = ui.Gradient.linear(
          Offset(left, top), Offset(right, top), gradientColors);
    } else {
      left = (c.x! - minDisToControlPoint - deepOffset);
      right = (c.x! + lightOffset);
      gradient = ui.Gradient.linear(
          Offset(right, top), Offset(left, top), gradientColors);
    }
    Paint paint = new Paint()..shader = gradient;

    canvas.translate(c.x!, c.y!);
    canvas.rotate(Math.atan2(e.x! - f.x!, h.y! - f.y!));
    canvas.translate(-c.x!, -c.y!);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);
  }

  /// 计算各点坐标
  void _calcPointsXY(CalPoint a, CalPoint f) {
    g.x = (a.x! + f.x!) / 2;
    g.y = (a.y! + f.y!) / 2;

    e.x = g.x! - (f.y! - g.y!) * (f.y! - g.y!) / (f.x! - g.x!);
    e.y = f.y;

    h.x = f.x;
    h.y = g.y! - (f.x! - g.x!) * (f.x! - g.x!) / (f.y! - g.y!);

    c.x = e.x! - (f.x! - e.x!) / 2;
    c.y = f.y;

    j.x = f.x;
    j.y = h.y! - (f.y! - h.y!) / 2;

    b = _getInterPoint(a, e, c, j);
    k = _getInterPoint(a, h, c, j);

    d.x = (c.x! + 2 * e.x! + b.x!) / 4;
    d.y = (2 * e.y! + c.y! + b.y!) / 4;

    i.x = (j.x! + 2 * h.x! + k.x!) / 4;
    i.y = (2 * h.y! + j.y! + k.y!) / 4;

    double lA = a.y! - e.y!;
    double lB = e.x! - a.x!;
    double lC = a.x! * e.y! - e.x! * a.y!;
    lPathAShadowDis = ((lA * d.x! + lB * d.y! + lC) / (_hypot(lA, lB)).abs());

    double rA = a.y! - h.y!;
    double rB = h.x! - a.x!;
    double rC = a.x! * h.y! - h.x! * a.y!;
    rPathAShadowDis = ((rA * i.x! + rB * i.y! + rC) / _hypot(rA, rB)).abs();
  }

  /// 计算两线段相交点坐标
  CalPoint _getInterPoint(
      CalPoint lineOneToPointOne,
      CalPoint lineOneToPointTwo,
      CalPoint lineTwoToPointOne,
      CalPoint lineTwoToPointTwo) {
    double? x1, y1, x2, y2, x3, y3, x4, y4;
    x1 = lineOneToPointOne.x;
    y1 = lineOneToPointOne.y;
    x2 = lineOneToPointTwo.x;
    y2 = lineOneToPointTwo.y;
    x3 = lineTwoToPointOne.x;
    y3 = lineTwoToPointOne.y;
    x4 = lineTwoToPointTwo.x;
    y4 = lineTwoToPointTwo.y;

    double pointX =
        ((x1! - x2!) * (x3! * y4! - x4! * y3!) - (x3 - x4) * (x1 * y2! - x2 * y1!)) /
            ((x3 - x4) * (y1 - y2) - (x1 - x2) * (y3 - y4));
    double pointY =
        ((y1 - y2) * (x3 * y4 - x4 * y3) - (x1 * y2 - x2 * y1) * (y3 - y4)) /
            ((y1 - y2) * (x3 - x4) - (x1 - x2) * (y3 - y4));

    return CalPoint.data(pointX, pointY);
  }

  ///获取f点在右下角的pathA
  Path? _getPathAFromLowerRight() {
    pathA!.reset();
    pathA!.lineTo(0, viewHeight!); //移动到左下角
    pathA!.lineTo(c.x!, c.y!); //移动到c点
    pathA!.quadraticBezierTo(e.x!, e.y!, b.x!, b.y!); //从c到b画贝塞尔曲线，控制点为e
    pathA!.lineTo(a.x!, a.y!); //移动到a点
    pathA!.lineTo(k.x!, k.y!); //移动到k点
    pathA!.quadraticBezierTo(h.x!, h.y!, j.x!, j.y!); //从k到j画贝塞尔曲线，控制点为h
    pathA!.lineTo(viewWidth!, 0); //移动到右上角
    pathA!.close(); //闭合区域
    return pathA;
  }

  ///获取f点在右上角的pathA
  Path? _getPathAFromTopRight() {
    pathA!.reset();
    pathA!.lineTo(c.x!, c.y!); //移动到c点
    pathA!.quadraticBezierTo(e.x!, e.y!, b.x!, b.y!); //从c到b画贝塞尔曲线，控制点为e
    pathA!.lineTo(a.x!, a.y!); //移动到a点
    pathA!.lineTo(k.x!, k.y!); //移动到k点
    pathA!.quadraticBezierTo(h.x!, h.y!, j.x!, j.y!); //从k到j画贝塞尔曲线，控制点为h
    pathA!.lineTo(viewWidth!, viewHeight!); //移动到右下角
    pathA!.lineTo(0, viewHeight!); //移动到左下角
    pathA!.close();
    return pathA;
  }

  ///翻页折角区域
  Path? _getPathC() {
    pathC!.reset();
    pathC!.moveTo(i.x!, i.y!); //移动到i点
    pathC!.lineTo(d.x!, d.y!); //移动到d点
    pathC!.lineTo(b.x!, b.y!); //移动到b点
    pathC!.lineTo(a.x!, a.y!); //移动到a点
    pathC!.lineTo(k.x!, k.y!); //移动到k点
    pathC!.close(); //闭合区域
    return pathC;
  }

  ///翻页后剩余区域
  Path? _getPathB() {
    pathB!.reset();
    pathB!.lineTo(0, viewHeight!); //移动到左下角
    pathB!.lineTo(viewWidth!, viewHeight!); //移动到右下角
    pathB!.lineTo(viewWidth!, 0); //移动到右上角
    pathB!.close(); //闭合区域
    return pathB;
  }

  ///绘制默认的界面
  Path? _getPathDefault() {
    pathA!.reset();
    pathA!.lineTo(0, viewHeight!);
    pathA!.lineTo(viewWidth!, viewHeight!);
    pathA!.lineTo(viewWidth!, 0);
    pathA!.close();
    return pathA;
  }

  ///计算C点的X值
  _calcPointCX(CalPoint a, CalPoint f) {
    CalPoint g, e;
    g = new CalPoint();
    e = new CalPoint();
    g.x = (a.x! + f.x!) / 2;
    g.y = (a.y! + f.y!) / 2;

    e.x = g.x! - (f.y! - g.y!) * (f.y! - g.y!) / (f.x! - g.x!);
    e.y = f.y;

    return e.x! - (f.x! - e.x!) / 2;
  }

  ///如果c点x坐标小于0,根据触摸点重新测量a点坐标
  _calcPointAByTouchPoint() {
    double w0 = viewWidth! - c.x!;

    double w1 = (f.x! - a.x!).abs();
    double w2 = viewWidth! * w1 / w0;
    a.x = (f.x! - w2).abs();

    double h1 = (f.y! - a.y!).abs();
    double h2 = w2 * h1 / w1;
    a.y = (f.y! - h2).abs();
  }

  ///利用 Paragraph 实现 _drawText
  _drawText(
      Canvas canvas, String text, Color color, double width, Offset offset,
      {TextAlign textAlign = TextAlign.start, double? fontSize}) {
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

  //_drawTestPoint() {
//    _drawText(canvas, "a",  Colors.red, size.width, Offset(a.x, a.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "f",  Colors.red, size.width, Offset(f.x, f.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "g",  Colors.red, size.width, Offset(g.x, g.y),
//        textAlign: TextAlign.left, fontSize: 25);
//
//    _drawText(canvas, "e",  Colors.red, size.width, Offset(e.x, e.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "h",  Colors.red, size.width, Offset(h.x, h.y),
//        textAlign: TextAlign.left, fontSize: 25);
//
//    _drawText(canvas, "c",  Colors.red, size.width, Offset(c.x, c.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "j",  Colors.red, size.width, Offset(j.x, j.y),
//        textAlign: TextAlign.left, fontSize: 25);
//
//    _drawText(canvas, "b",  Colors.red, size.width, Offset(b.x, b.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "k",  Colors.red, size.width, Offset(k.x, k.y),
//        textAlign: TextAlign.left, fontSize: 25);
//
//    _drawText(canvas, "d",  Colors.red, size.width, Offset(d.x, d.y),
//        textAlign: TextAlign.left, fontSize: 25);
//    _drawText(canvas, "i",  Colors.red, size.width, Offset(i.x, i.y),
//        textAlign: TextAlign.left, fontSize: 25);
 // }

  num _hypot(num x, num y) {
    var first = x.abs();
    var second = y.abs();

    if (y > x) {
      first = y.abs();
      second = x.abs();
    }

    if (first == 0.0) {
      return second;
    }

    final t = second / first;
    return first * Math.sqrt(1 + t * t);
  }
}
