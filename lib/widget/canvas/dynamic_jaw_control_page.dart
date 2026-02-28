import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// --- 模式配置枚举 ---
enum JawMode {
  bite, // 咬紧模式 (一次性咬合 + 震动)
  chew, // 咀嚼模式 (连续张合 + 侧方研磨)
}

class DynamicJawControlPage extends StatefulWidget {
  const DynamicJawControlPage({super.key});

  @override
  State<DynamicJawControlPage> createState() => _DynamicJawControlPageState();
}

class _DynamicJawControlPageState extends State<DynamicJawControlPage> {
  // 可动态配置的参数
  JawMode _currentMode = JawMode.bite;
  double _uiSize = 350.0;
  double _durationSec = 3.0;

  // 触发动画的 Key
  final GlobalKey<_RealisticJawWidgetState> _jawKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120), // 沉浸式暗黑背景
      body: SafeArea(
        child: Column(
          children: [
            // 上半部分：3D 渲染区域
            Expanded(
              child: Center(
                // 用 Container 框出 UI 大小，便于直观感受尺寸缩放
                child: Container(
                  width: _uiSize,
                  height: _uiSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: RealisticJawWidget(
                    key: _jawKey,
                    mode: _currentMode,
                    uiSize: _uiSize,
                    durationSec: _durationSec,
                  ),
                ),
              ),
            ),

            // 下半部分：控制面板
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. 模式切换
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("运动模式",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                      SegmentedButton<JawMode>(
                        segments: const [
                          ButtonSegment(
                              value: JawMode.bite, label: Text('用力咬紧')),
                          ButtonSegment(
                              value: JawMode.chew, label: Text('连续咀嚼')),
                        ],
                        selected: {_currentMode},
                        onSelectionChanged: (Set<JawMode> newSelection) {
                          setState(() => _currentMode = newSelection.first);
                        },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          selectedForegroundColor: Colors.white,
                          selectedBackgroundColor: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. 尺寸配置
                  _buildSlider(
                    label: "UI 缩放尺寸 (${_uiSize.toInt()}px)",
                    value: _uiSize,
                    min: 150.0,
                    max: 500.0,
                    onChanged: (val) => setState(() => _uiSize = val),
                  ),

                  // 3. 时间配置
                  _buildSlider(
                    label: "持续时间 (${_durationSec.toStringAsFixed(1)}s)",
                    value: _durationSec,
                    min: 1.0,
                    max: 8.0,
                    onChanged: (val) => setState(() => _durationSec = val),
                  ),

                  const SizedBox(height: 20),

                  // 4. 触发按钮
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _jawKey.currentState?.triggerAnimation(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("触发动画",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
      {required String label,
      required double value,
      required double min,
      required double max,
      required Function(double) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF818CF8),
          inactiveColor: Colors.white12,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------
// 核心动画封装 Widget
class RealisticJawWidget extends StatefulWidget {
  final JawMode mode;
  final double uiSize;
  final double durationSec;

  const RealisticJawWidget({
    super.key,
    required this.mode,
    required this.uiSize,
    required this.durationSec,
  });

  @override
  State<RealisticJawWidget> createState() => _RealisticJawWidgetState();
}

class _RealisticJawWidgetState extends State<RealisticJawWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.durationSec * 1000).toInt()),
    );
  }

  @override
  void didUpdateWidget(RealisticJawWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durationSec != widget.durationSec) {
      _controller.duration =
          Duration(milliseconds: (widget.durationSec * 1000).toInt());
    }
  }

  void triggerAnimation() {
    if (!_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double v = _controller.value;
        final double totalMs = widget.durationSec * 1000.0;
        final double currentMs = v * totalMs;

        double hingeAngle = -0.35; // 初始为张开状态
        double clenchX = 0.0;
        double clenchY = 0.0;

        if (widget.mode == JawMode.bite) {
          // --- 咬紧模式 (Bite) ---
          double closeTime = 150.0; // 极速合拢时间
          double openTime = 400.0; // 恢复张开时间

          if (currentMs < closeTime) {
            double t = (currentMs / closeTime).clamp(0.0, 1.0);
            hingeAngle = -0.35 * (1.0 - Curves.easeInQuint.transform(t));
          } else if (currentMs < totalMs - openTime) {
            hingeAngle = 0.0; // 咬死
            clenchX = (Random().nextDouble() - 0.5) * 2.5; // 发抖
            clenchY = (Random().nextDouble() - 0.5) * 1.5;
          } else {
            double t =
                ((currentMs - (totalMs - openTime)) / openTime).clamp(0.0, 1.0);
            hingeAngle = -0.35 * Curves.easeOutCubic.transform(t);
          }
        } else {
          // --- 咀嚼模式 (Chew) ---
          double chewCycle = 600.0; // 每完成一次咀嚼需要 600ms
          double fadeOutTime = 400.0; // 最后预留 400ms 平滑张开

          if (currentMs < totalMs - fadeOutTime) {
            double progress = currentMs / chewCycle;
            // 使用 cos 函数创造连续的张合运动
            hingeAngle = -0.35 * (0.5 + 0.5 * cos(progress * 2 * pi));

            // 当牙齿接近闭合时，加入侧方研磨运动 (Lateral Grinding)
            if (hingeAngle > -0.08) {
              clenchX = sin(progress * 2 * pi) * 3.0; // 水平方向的研磨滑动
              clenchY = (Random().nextDouble() - 0.5) * 0.5;
            }
          } else {
            // 平滑恢复到初始张开状态
            double t = ((currentMs - (totalMs - fadeOutTime)) / fadeOutTime)
                .clamp(0.0, 1.0);
            double stopProgress = (totalMs - fadeOutTime) / chewCycle;
            double stopAngle = -0.35 * (0.5 + 0.5 * cos(stopProgress * 2 * pi));

            hingeAngle = stopAngle +
                (-0.35 - stopAngle) * Curves.easeOutCubic.transform(t);
          }
        }

        return CustomPaint(
          size: Size(widget.uiSize, widget.uiSize),
          painter: DepthTeethPainter(
            hingeAngle: hingeAngle,
            clenchOffset: Offset(clenchX, clenchY),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ----------------------------------------------------------------
// 核心渲染器 (保持 3D 数学完美的同时增加尺寸自适应)
class ToothNode {
  double x, y, z, w, h;
  bool isUpper;
  double worldZ = 0.0, projectedX = 0.0, projectedY = 0.0, scale = 1.0;

  ToothNode(this.x, this.y, this.z, this.w, this.h, this.isUpper);
}

class DepthTeethPainter extends CustomPainter {
  final double hingeAngle;
  final Offset clenchOffset;

  final double tmjY = -50.0;
  final double tmjZ = -160.0;
  final double focalLength = 600.0;

  DepthTeethPainter({required this.hingeAngle, required this.clenchOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // 核心逻辑：动态缩放引擎
    // 我们假定基础设计基准尺寸为 400x400
    // 无论用户怎么配，内部永远按 400 画，由画布进行等比缩放
    double scaleFactor = size.width / 400.0;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 + 30 * scaleFactor);
    canvas.scale(scaleFactor); // <--- 自适应任意大小的关键所在

    List<ToothNode> allTeeth = _buildAnatomicalArch();

    for (var tooth in allTeeth) {
      double wx = tooth.x, wy = tooth.y, wz = tooth.z;

      if (!tooth.isUpper) {
        double dy = wy - tmjY, dz = wz - tmjZ;
        wy = tmjY + dy * cos(hingeAngle) - dz * sin(hingeAngle);
        wz = tmjZ + dy * sin(hingeAngle) + dz * cos(hingeAngle);
        wx += clenchOffset.dx;
        wy += clenchOffset.dy;
      }

      tooth.worldZ = wz;
      tooth.scale = focalLength / (focalLength - wz);
      tooth.projectedX = wx * tooth.scale;
      tooth.projectedY = wy * tooth.scale;
    }

    allTeeth.sort((a, b) => a.worldZ.compareTo(b.worldZ));

    for (var tooth in allTeeth) {
      canvas.save();
      canvas.translate(tooth.projectedX, tooth.projectedY);
      canvas.scale(tooth.scale);
      _drawCleanTooth(canvas, tooth);
      canvas.restore();
    }

    canvas.restore();
  }

  List<ToothNode> _buildAnatomicalArch() {
    List<ToothNode> teeth = [];
    final archProfile = [
      {'w': 20.0, 'h': 36.0},
      {'w': 16.0, 'h': 30.0},
      {'w': 18.0, 'h': 34.0},
      {'w': 18.0, 'h': 28.0},
      {'w': 18.0, 'h': 28.0},
      {'w': 26.0, 'h': 26.0},
      {'w': 26.0, 'h': 24.0},
    ];

    void generateJaw(bool isUpper) {
      double currentX = 0.0;
      for (int i = 0; i < archProfile.length; i++) {
        double w = archProfile[i]['w']!, h = archProfile[i]['h']!;
        currentX += w / 2;
        double z = -(currentX * currentX) / 70.0;
        double curveY = -(currentX * currentX) / 350.0; // 司匹氏曲线

        teeth.add(ToothNode(currentX, curveY, z, w, h, isUpper));
        if (currentX > 0) {
          teeth.add(ToothNode(-currentX, curveY, z, w, h, isUpper));
        }
        currentX += w / 2 + 0.6;
      }
    }

    generateJaw(true);
    generateJaw(false);
    return teeth;
  }

  void _drawCleanTooth(Canvas canvas, ToothNode tooth) {
    Path path = Path();
    double rEdge = 3.0, rRoot = 6.0, rootW = tooth.w * 0.85;

    if (tooth.isUpper) {
      path.moveTo(-tooth.w / 2 + rEdge, 0);
      path.lineTo(tooth.w / 2 - rEdge, 0);
      path.quadraticBezierTo(tooth.w / 2, 0, tooth.w / 2, -rEdge);
      path.lineTo(rootW / 2, -tooth.h + rRoot);
      path.quadraticBezierTo(rootW / 2, -tooth.h, rootW / 2 - rRoot, -tooth.h);
      path.lineTo(-rootW / 2 + rRoot, -tooth.h);
      path.quadraticBezierTo(
          -rootW / 2, -tooth.h, -rootW / 2, -tooth.h + rRoot);
      path.lineTo(-tooth.w / 2, -rEdge);
      path.quadraticBezierTo(-tooth.w / 2, 0, -tooth.w / 2 + rEdge, 0);
    } else {
      path.moveTo(-tooth.w / 2 + rEdge, 0);
      path.lineTo(tooth.w / 2 - rEdge, 0);
      path.quadraticBezierTo(tooth.w / 2, 0, tooth.w / 2, rEdge);
      path.lineTo(rootW / 2, tooth.h - rRoot);
      path.quadraticBezierTo(rootW / 2, tooth.h, rootW / 2 - rRoot, tooth.h);
      path.lineTo(-rootW / 2 + rRoot, tooth.h);
      path.quadraticBezierTo(-rootW / 2, tooth.h, -rootW / 2, tooth.h + rRoot);
      path.lineTo(-tooth.w / 2, rEdge);
      path.quadraticBezierTo(-tooth.w / 2, 0, -tooth.w / 2 + rEdge, 0);
    }

    double depthRatio = (-tooth.worldZ / 180.0).clamp(0.0, 1.0);
    Color topColor = Color.lerp(
        const Color(0xFFFFFFFF), const Color(0xFF475569), depthRatio * 0.9)!;
    Color bottomColor = Color.lerp(
        const Color(0xFFE2E8F0), const Color(0xFF1E293B), depthRatio * 0.9)!;

    canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
              Offset(0, tooth.isUpper ? 0 : tooth.h),
              Offset(0, tooth.isUpper ? -tooth.h : 0),
              [topColor, bottomColor]));
    canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
              const Color(0xFF94A3B8), const Color(0xFF0F172A), depthRatio)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 * (1.0 - depthRatio * 0.3));

    if (depthRatio < 0.6) {
      canvas.drawLine(
          Offset(-tooth.w / 2 + 4, 0),
          Offset(tooth.w / 2 - 4, 0),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.15)
            ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant DepthTeethPainter oldDelegate) => true;
}
