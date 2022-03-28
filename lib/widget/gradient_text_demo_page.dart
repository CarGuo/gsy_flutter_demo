import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GradientTextDemoPage extends StatelessWidget {
  const GradientTextDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GradientTextDemoPage"),
      ),
      body: Container(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (kIsWeb)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text("当前效果不支持 Web ，请在 App 查看"),
                  ),
                ),
              Container(
                child: Text(
                  '8',
                  style: TextStyle(
                      fontSize: 100,

                      /// 2.10 下因为有 shader （Gradient） ， web 下会用 canvas
                      ///编译文本，此时会有  _applySpanStyleToCanvas 时 setUpPaint 的 Rect 为 nul 的问题
                      ///所以添加   fontFeatures 可以在底层渲染时切换回 p+span 标签
                      ///但是目前 p+span 不支持 foreground 的 Paint
                      fontFeatures:
                          kIsWeb ? [FontFeature.enable("tnum")] : null,
                      foreground: Paint()
                        ..style = PaintingStyle.fill
                        ..strokeWidth = 3
                        ..shader = LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [Colors.yellow, Colors.black])
                            .createShader(Rect.fromLTWH(0, 0, 200, 100))),
                ),
              ),
              Container(
                child: Text(
                  '8',
                  style: TextStyle(
                      fontSize: 100,

                      /// 2.10 下因为有 shader （Gradient） ， web 下会用 canvas
                      ///编译文本，此时会有  _applySpanStyleToCanvas 时 setUpPaint 的 Rect 为 nul 的问题
                      ///所以添加   fontFeatures 可以在底层渲染时切换回 p+span 标签
                      ///但是目前 p+span 不支持 foreground 的 Paint
                      fontFeatures:
                          kIsWeb ? [FontFeature.enable("tnum")] : null,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..shader = LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [Colors.limeAccent, Colors.cyanAccent])
                            .createShader(Rect.fromLTWH(0, 0, 200, 100))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
