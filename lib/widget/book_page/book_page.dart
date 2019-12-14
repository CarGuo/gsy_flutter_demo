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
    if (d.localPosition.dy < height / 2) {
      style = PositionStyle.STYLE_TOP_RIGHT;
    } else if (d.localPosition.dy >= height / 2) {
      style = PositionStyle.STYLE_LOWER_RIGHT;
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
          onVerticalDragEnd: toNormal,
          onVerticalDragCancel: toNormal,
          onHorizontalDragEnd: toNormal,
          onHorizontalDragCancel: toNormal,
          onVerticalDragUpdate: toDragUpdate,
          onHorizontalDragUpdate: toDragUpdate,
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
