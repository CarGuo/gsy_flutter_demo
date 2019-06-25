import 'package:flutter/material.dart';

class AnimaDemoPage extends StatefulWidget {
  @override
  _AnimaDemoPageState createState() => _AnimaDemoPageState();
}

class _AnimaDemoPageState extends State<AnimaDemoPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller1;

  Animation animation1;

  Animation animation2;

  @override
  void initState() {
    super.initState();
    controller1 =
        new AnimationController(vsync: this, duration: Duration(seconds: 3));

    animation1 = Tween(begin: 0.0, end: 200.0).animate(controller1)
      ..addListener(() {
        setState(() {});
      });

    animation2 = Tween(begin: 0.0, end: 1.0).animate(controller1);

    controller1.repeat();
  }

  @override
  void dispose() {
    controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("AnimaDemoPage"),
      ),

      ///用封装好的 Transition 做动画
      body: new RotationTransition(
        turns: animation2,
        child: new Container(
          child: Center(
            child: new Container(
              height: 200,
              width: 200,
              color: Colors.greenAccent,
              child: CustomPaint(
                ///直接使用值做动画
                foregroundPainter: _AnimationPainter(animation1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimationPainter extends CustomPainter {
  Paint _paint = new Paint();

  Animation animation;

  _AnimationPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    _paint
      ..color = Colors.redAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(100, 100), animation.value * 1.5, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
