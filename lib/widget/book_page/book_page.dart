import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/book_page/cal_point.dart';

import 'book_painter.dart';

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  CalPoint curPoint = CalPoint.data(-1, -1);
  CalPoint prePoint = CalPoint.data(-1, -1);

  PositionStyle style = PositionStyle.STYLE_LOWER_RIGHT;
  double width;
  double height;

  toNormal([_]) {
    setState(() {
      curPoint = CalPoint.data(-1, -1);
      prePoint = CalPoint.data(-1, -1);
      style = PositionStyle.STYLE_LOWER_RIGHT;
    });
  }

  toDragUpdate(d) {
    var x = d.localPosition.dx;
    var y = d.localPosition.dy;
    setState(() {
      curPoint = CalPoint.data(x, y);
    });
  }

  toDown(TapDownDetails d) {
    prePoint = CalPoint.data(-1, -1);
    var dy = d.localPosition.dy;
    var dx = d.localPosition.dx;

    if (dx <= width / 3) {
      //左
      style = PositionStyle.STYLE_LEFT;
    } else if (dx > width / 3 && dy <= height / 3) {
      //上
      style = PositionStyle.STYLE_TOP_RIGHT;
    } else if (dx > width * 2 / 3 && dy > height / 3 && dy <= height * 2 / 3) {
      //右
      style = PositionStyle.STYLE_RIGHT;
    } else if (dx > width / 3 && dy > height * 2 / 3) {
      //下
      style = PositionStyle.STYLE_LOWER_RIGHT;
    } else if (dx > width / 3 &&
        dx < width * 2 / 3 &&
        dy > height / 3 &&
        dy < height * 2 / 3) {
      //中
      style = PositionStyle.STYLE_MIDDLE;
    }

    var x = d.localPosition.dx;
    var y = d.localPosition.dy;
    setState(() {
      curPoint = CalPoint.data(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: GestureDetector(
          onTapDown: toDown,
          onTapUp: toNormal,
//          onVerticalDragEnd: toNormal,
//          onVerticalDragCancel: toNormal,
//          onHorizontalDragEnd: toNormal,
//          onHorizontalDragCancel: toNormal,
          onPanEnd: toNormal,
          onPanCancel: toNormal,
          onPanUpdate: toDragUpdate,
          child: CustomPaint(
            painter: BookPainter(
              viewWidth: width,
              viewHeight: height,
              cur: curPoint,
              pre: prePoint,
              style: style,
              limitAngle: true,
              changedPoint: (pre) {
                prePoint = pre;
              },
            ),
          ),
        ),
      ),
    );
  }
}
