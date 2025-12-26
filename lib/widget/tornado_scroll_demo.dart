import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class TornadoScrollDemo extends StatefulWidget {
  const TornadoScrollDemo({super.key});

  @override
  State<TornadoScrollDemo> createState() => _TornadoScrollDemoState();
}

class _TornadoScrollDemoState extends State<TornadoScrollDemo>
    with SingleTickerProviderStateMixin {
  // 模拟滚动位置
  double _scrollOffset = 0.0;

  // 扭曲度 (对应用户的 "缩放/Zoom")
  // 0.0 = 垂直直线, 1.0 = 夸张螺旋
  double _twistIntensity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 手势层：处理拖动（滚动）
          GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                // 调整滚动灵敏度
                _scrollOffset -= details.delta.dy * 0.005;
              });
            },
            child: Container(color: Colors.transparent), // 充满屏幕接收事件
          ),

          // 2. 渲染层：完全自定义布局
          // 使用 Flow 或 Stack 都可以，这里用 Stack + Loop 演示原理最清晰
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                alignment: Alignment.center,
                children: _buildSpiralItems(),
              ),
            ),
          ),

          // 3. 控制层：模拟 "缩放调整扭曲度"
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const Text("Twist Intensity (Zoom)",
                    style: TextStyle(color: Colors.white)),
                Slider(
                  value: _twistIntensity,
                  min: 0.0,
                  max: 1.5,
                  onChanged: (v) => setState(() => _twistIntensity = v),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildSpiralItems() {
    List<Widget> items = [];
    const int totalItems = 30; // 假设列表长度

    // 螺旋的核心参数
    // 半径随 intensity 变化
    final double radius = 150.0 * _twistIntensity;
    // 垂直间距
    //const double itemSpacing = 60.0;

    for (int i = 0; i < totalItems; i++) {
      // t 是归一化的路径进度
      // (i * 0.1) 决定了 Item 在螺旋线上的初始间隔
      // _scrollOffset 是全局滚动量
      double t = i * 0.15 - _scrollOffset;

      // --- 数学核心 ---

      // 1. 计算 Y 轴位置 (线性部分)
      // 这里的 800 是螺旋的高度跨度
      double dy = t * 400;

      // 如果超出屏幕太远就不渲染 (简单的 Culling)
      if (dy < -500 || dy > 500) continue;

      // 2. 计算角度 (决定在螺旋上的位置)
      // twistIntensity 同时也影响旋转的快慢
      double angle = t * 2.0 * pi;

      // 3. 计算 3D 变换矩阵
      Matrix4 matrix = Matrix4.identity();
      matrix.setEntry(3, 2, 0.001); // 开启透视

      // 4. 应用螺旋位置 (Cylindrical Mapping)
      // X = R * sin(angle), Z = R * cos(angle)
      // 注意：当 _twistIntensity 为 0 时，radius 为 0，x/z 偏移为 0 -> 变成垂直列表
      double dx = radius * sin(angle);
      double dz = radius * cos(angle);

      matrix.translateByVector3(Vector3(dx, dy, dz));

      // 5. 切线旋转 (关键！让 Item 永远面朝螺旋中心或切线方向)
      // 负号是为了抵消螺旋造成的朝向偏移，保持卡片大致面向前方
      // 乘以 _twistIntensity 是为了让它在变直时回归 0 旋转
      matrix.rotateY(-angle * _twistIntensity);

      // 可选：Z轴轻微倾斜，模拟视频中的动态感
      matrix.rotateZ(angle * 0.1 * _twistIntensity);

      // 6. 计算层级 (Z-Index)
      // Flutter Stack 默认后画的在上面。
      // 在 3D 中，Z 值越小越远。但在 Stack 里，我们需要手动排序。
      // 这里简单处理：不做复杂排序，直接添加。
      // 完美方案是把 items 放入一个 list，根据 z 值 sort 之后再生成 Widgets。

      items.add(
        Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: _buildCard(i),
        ),
      );
    }

    // 简单的 Z-Sort 修正 (让前面的 Item 遮挡后面的)
    // 这里的 Z 是 matrix 计算后的逻辑 Z，很难直接取到。
    // 一个近似做法是：螺旋背面 (cos < 0) 的先画，正面的后画。
    // 但为了代码简洁，这里暂不包含复杂的 Z-sorting 算法。

    return items;
  }

  Widget _buildCard(int index) {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
          // 根据索引变色，方便观察
          color: Colors.primaries[index % Colors.primaries.length]
              .withValues(alpha:0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha:0.5), blurRadius: 10)
          ],
          border: Border.all(color: Colors.white.withValues(alpha:0.2))),
      child: Center(
        child: Text(
          "Item $index",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
