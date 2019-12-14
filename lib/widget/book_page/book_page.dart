import 'package:flutter/material.dart';

import 'book_painter.dart';

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  double x = -1;
  double y = -1;
  PositionStyle style = PositionStyle.STYLE_LOWER_RIGHT;
  double width;
  double height;

  toNormal([_]) {
    setState(() {
      x = -1;
      y = -1;
    });
  }

  toDragUpdate(d) {
    setState(() {
      x = d.localPosition.dx;
      y = d.localPosition.dy;
    });
  }

  toDown(TapDownDetails details) {
    if (details.localPosition.dy < height / 2) {
      style = PositionStyle.STYLE_TOP_RIGHT;
    } else if (details.localPosition.dy >= height / 2) {
      style = PositionStyle.STYLE_LOWER_RIGHT;
    }
    setState(() {
      x = details.localPosition.dx;
      y = details.localPosition.dy;
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
                viewWidth: width, viewHeight: height, x: x, y: y, style: style),
          ),
        ),
      ),
    );
  }
}
