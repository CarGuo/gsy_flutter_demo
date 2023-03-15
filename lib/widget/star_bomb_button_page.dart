import 'dart:math';
import 'package:flutter/material.dart';

///以下代码全部来自 ChatGPT 生成，具体详情可见：
/// https://juejin.cn/post/7210605626501595195
class StarBombButtonPage extends StatelessWidget {
  const StarBombButtonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YellowStarPage();
  }
}

class YellowStarPage extends StatefulWidget {
  @override
  _YellowStarPageState createState() => _YellowStarPageState();
}

class _YellowStarPageState extends State<YellowStarPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExploded = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleStarTap() {
    if (!_isExploded) {
      _isExploded = true;
      _animationController.forward(from: 0);
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _isExploded = false;
        });
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yellow Star')),
      body: Center(
        child: GestureDetector(
          onTap: _handleStarTap,
          child: Container(
            width: 300,
            height: 300,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: YellowStarPainter(_animationController.value,
                      isExploded: _isExploded),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class YellowStarPainter extends CustomPainter {
  final double starSizeRatio = 0.4;
  final double centerOffsetRatio = 0.2;
  final double rotationOffset = -pi / 2;

  final double animationValue;
  final bool isExploded;

  YellowStarPainter(this.animationValue, {this.isExploded = false});

  @override
  void paint(Canvas canvas, Size size) {
    double starSize = min(size.width, size.height) * starSizeRatio;
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double centerOffset = starSize * centerOffsetRatio;

    Path path = Path();
    Paint paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    if (isExploded) {
      double particleSize = starSize / 30;
      paint.strokeWidth = 1;
      paint.style = PaintingStyle.fill;
      paint.color = Colors.yellow;
      Random random = Random();

      for (int i = 0; i < 30; i++) {
        double dx = random.nextDouble() * starSize - starSize / 2;
        double dy = random.nextDouble() * starSize - starSize / 2;
        double x = centerX + dx * (1 + animationValue);
        double y = centerY + dy * (1 + animationValue);

        canvas.drawCircle(Offset(x, y), particleSize, paint);
      }
    } else {
      for (int i = 0; i < 5; i++) {
        double radians = 2 * pi / 5 * i + rotationOffset;
        double x = centerX + cos(radians) * starSize / 2;
        double y = centerY + sin(radians) * starSize / 2;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }

        radians += 2 * pi / 10;
        x = centerX + cos(radians) * centerOffset;
        y = centerY + sin(radians) * centerOffset;
        path.lineTo(x, y);
      }

      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
