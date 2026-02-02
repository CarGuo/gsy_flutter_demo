import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


class KoiFishAnimationPage extends StatefulWidget {
  const KoiFishAnimationPage({super.key});

  @override
  State<KoiFishAnimationPage> createState() => _KoiFishAnimationPageState();
}

class _KoiFishAnimationPageState extends State<KoiFishAnimationPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _t = 0.0;

  @override
  void initState() {
    super.initState();
    // 使用 Ticker 来获得平滑的帧更新
    _ticker = createTicker((elapsed) {
      setState(() {
        // 对应源代码中的 t+=PI/90
        _t += pi / 90;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: const Color(0xFF090909), // background(9) 接近纯黑
      body: SizedBox.expand(
        child: CustomPaint(
          painter: KoiPainter(time: _t),
        ),
      ),
    );
  }
}

class KoiPainter extends CustomPainter {
  final double time;

  KoiPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // 对应 stroke(w, 116)。白色，透明度约为 0.45 (116/255)
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final List<Offset> points = [];

    // 原始逻辑为了居中是在 400x400 画布上的 200, 60。
    // 我们将其移动到屏幕中心。
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 循环 i = 10000 到 0
    for (int i = 10000; i > 0; i--) {
      // 1. y = i / 790
      double y = i / 790.0;

      // 2. 计算 k
      // JS: k=(y<8?9+sin(y^9)*6:4+cos(y))*cos(i+t/4)
      // 注意：JS中的 y^9 是位运算 XOR (Bitwise XOR)。Dart中需转为int操作。
      double baseK;
      if (y < 8) {
        // 这里的 ^ 是异或，产生了"鳞片"的噪点纹理
        baseK = 9 + sin((y.toInt() ^ 9).toDouble()) * 6;
      } else {
        baseK = 4 + cos(y);
      }
      double k = baseK * cos(i + time / 4.0);

      // 3. 计算 e
      // JS: e=y/3-13
      double e = y / 3.0 - 13.0;

      // 4. 计算 d (magnitude) 和 波动
      // JS: d=mag(k, e)+cos(e+t*2+i%2*4)
      // mag(k, e) = sqrt(k^2 + e^2)
      double mag = sqrt(k * k + e * e);
      double d = mag + cos(e + time * 2.0 + (i % 2) * 4.0);

      // 5. 计算半径 q
      // JS: q=y*k/5*(2+sin(d*2+y-t*4))+80
      double q = y * k / 5.0 * (2 + sin(d * 2.0 + y - time * 4.0)) + 80.0;

      // 6. 计算角度 c
      // JS: c=d/4-t/2+i%2*3
      double c = d / 4.0 - time / 2.0 + (i % 2) * 3.0;

      // 7. 生成坐标 point(...)
      // x = q * cos(c) + 200
      // y_out = q * sin(c) + d * 9 + 60

      // 我们用屏幕中心替换硬编码的偏移量
      double x = q * cos(c) + centerX;
      double yPos = q * sin(c) + d * 9.0 + centerY;

      points.add(Offset(x, yPos));
    }

    // 一次性绘制所有点，性能最高
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant KoiPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}