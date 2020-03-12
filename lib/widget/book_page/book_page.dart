import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/book_page/cal_point.dart';

import 'book_painter.dart';

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage>
    with SingleTickerProviderStateMixin {
  CalPoint curPoint = CalPoint.data(-1, -1);
  CalPoint prePoint = CalPoint.data(-1, -1);

  PositionStyle style = PositionStyle.STYLE_LOWER_RIGHT;
  double width;
  double height;
  AnimationController animationController;
  Animation cancelAnim;
  Tween cancelValue;
  bool needCancelAnim = true;

  toNormal([_]) {
    if (needCancelAnim) {
      startCancelAnim();
    } else {
      setState(() {
        style = PositionStyle.STYLE_LOWER_RIGHT;
        prePoint = CalPoint.data(-1, -1);
        curPoint = CalPoint.data(-1, -1);
      });
    }
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

  startCancelAnim() {
    double dx, dy;
    if (style == PositionStyle.STYLE_TOP_RIGHT) {
      dx = (width - 1 - prePoint.x);
      dy = (1 - prePoint.y);
    } else if (style == PositionStyle.STYLE_LOWER_RIGHT) {
      dx = (width - 1 - prePoint.x);
      dy = (height - 1 - prePoint.y);
    } else {
      dx = prePoint.x - width;
      dy = -prePoint.y;
    }
    cancelValue =
        Tween(begin: Offset(prePoint.x, prePoint.y), end: Offset(dx, dy));
    animationController.forward();
  }

  _initCancelAnim() {
    animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
    cancelAnim = animationController.drive(CurveTween(curve: Curves.linear));
    cancelAnim
      ..addListener(() {
        if (animationController.isAnimating) {
          setState(() {
            var bdx = cancelValue.begin.dx;
            var bdy = cancelValue.begin.dy;

            var edx = cancelValue.end.dx;
            var edy = cancelValue.end.dy;

            curPoint = CalPoint.data(
                bdx + edx * cancelAnim.value, bdy + edy * cancelAnim.value);
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            style = PositionStyle.STYLE_LOWER_RIGHT;
            prePoint = CalPoint.data(-1, -1);
            curPoint = CalPoint.data(-1, -1);
            animationController.reset();
          });
        }
      });
  }

  @override
  void initState() {
    super.initState();
    _initCancelAnim();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height - kToolbarHeight;
    Color bgColor = Colors.tealAccent;
    return Scaffold(
      appBar: AppBar(
        title: new Text("BookPage"),
      ),
      body: Container(
        height: height,
        width: width,
        child: GestureDetector(
          onTapDown: toDown,
          onTapUp: toNormal,
          onPanEnd: toNormal,
          onPanCancel: toNormal,
          onPanUpdate: toDragUpdate,
          child: CustomPaint(
            painter: BookPainter(
              text: content,
              text2: content2,
              viewWidth: width,
              viewHeight: height,
              cur: curPoint,
              pre: prePoint,
              style: style,
              bgColor: bgColor,
              frontColor: Colors.yellow,
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

const content = """林语堂\n
一、腰有十文钱必振衣作响；\n

二、每与人言必谈及贵戚；\n

三、遇美人必急索登床；\n

四、见到问路之人必作傲睨之态；\n

五、与朋友相聚便喋喋高吟其酸腐诗文；\n

六、头已花白却喜唱艳曲；\n

七、施人一小惠便广布于众；\n

八、与人交谈便借刁言以逞才；\n

九、借人之债时其脸如丐，被人索偿时则其态如王；\n

十、见人常多蜜语而背地却常揭人短处。""";

const content2 = """林语堂\n
1.人本过客来无处，休说故里在何方。随遇而安无不可，人间到处有芳香。——林语堂\n
2.人生不过如此，且行且珍惜。自己永远是自己的主角，不要总在别人的戏剧里充当着配角。——林语堂《人生不过如此》\n
3.最明亮时总是最迷茫，最繁华时也是最悲凉。——林语堂《京华烟云》\n
4.理想的人并不是完美的人，通常只是受人喜爱，并且通情达理的人，而我只是努力去接近于此罢了。——林语堂""";
