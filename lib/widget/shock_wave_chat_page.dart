import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Effect type definition
/// 效果类型定义
enum _EffectType {
  /// Original ripple diffusion effect
  /// 原有的水波纹扩散效果
  ripple,

  /// New elastic shock effect
  /// 新增的弹性冲击效果
  elastic,
}

class ShockwaveChatPage extends StatefulWidget {
  const ShockwaveChatPage({super.key});

  @override
  State<ShockwaveChatPage> createState() => _ShockwaveChatPageState();
}

class _ShockwaveChatPageState extends State<ShockwaveChatPage> {
  final GlobalKey _scaffoldKey = GlobalKey();

  /// Store two Shader Programs separately
  /// 分别存储两个 Shader Program
  ui.FragmentProgram? _rippleProgram;
  ui.FragmentProgram? _elasticProgram;

  /// Currently selected effect state, defaulting to the new elastic effect
  /// 当前选中的效果状态，默认使用新的弹性效果
  _EffectType _currentEffect = _EffectType.elastic;

  final List<String> _messages = [
    "Pressing play now",
    "Okay yeah, I'm into this already.",
    "It made me wonder if the artist is in town.",
    "Oh wait, that would be fun.",
    "Like, if they're playing nearby.",
    "If they are, we should go.",
    "Sounds like a plan!",
    "Let's grab some food first."
  ];

  @override
  void initState() {
    super.initState();
    _loadShaders();
  }

  /// Load both Shaders simultaneously
  /// 同时加载两个 Shader
  Future<void> _loadShaders() async {
    try {
      final ripple =
          await ui.FragmentProgram.fromAsset('shaders/shockwave.frag');
      final elastic =
          await ui.FragmentProgram.fromAsset('shaders/elastic.frag');
      setState(() {
        _rippleProgram = ripple;
        _elasticProgram = elastic;
      });
    } catch (e) {
      debugPrint("Shader load error: $e");
    }
  }

  /// Get the Program that should be currently used
  /// 获取当前应当使用的 Program
  ui.FragmentProgram? get _activeProgram =>
      _currentEffect == _EffectType.ripple ? _rippleProgram : _elasticProgram;

  Future<void> _handlePressStart(
      BuildContext itemContext, String text, bool isMe) async {
    final program = _activeProgram;
    if (program == null) return;

    final boundary = _scaffoldKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    /// Capture screenshot
    /// 截图
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    /// Slightly reducing screenshot resolution can improve performance with little impact on dynamic blur effects
    /// 稍微降低截图分辨率可以提高性能，对动态模糊效果影响不大
    final image = await boundary.toImage(pixelRatio: pixelRatio);

    final RenderBox renderBox = itemContext.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final itemRect = offset & size;
    final touchCenter = itemRect.center;

    if (!mounted) return;

    final releaseNotifier = ValueNotifier<bool>(false);
    OverlayEntry? entry;

    final double force = _currentEffect == _EffectType.elastic ? 0.08 : 0.05;
    final double paramSize = _currentEffect == _EffectType.elastic ? 0.1 : 0.2;

    entry = OverlayEntry(
      builder: (context) => _ShockwaveOverlay(
        program: program,
        screenImage: image,
        touchCenter: touchCenter,
        targetRect: itemRect,
        text: text,
        isMe: isMe,
        force: force,
        paramSize: paramSize,
        releaseNotifier: releaseNotifier,
        onAnimationEnd: () {
          entry?.remove();
          entry = null;
        },
      ),
    );

    Overlay.of(context).insert(entry!);
    _currentReleaseNotifier = releaseNotifier;
  }

  ValueNotifier<bool>? _currentReleaseNotifier;

  void _handlePressEnd() {
    if (_currentReleaseNotifier != null) {
      _currentReleaseNotifier!.value = true;
      _currentReleaseNotifier = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: Text(_currentEffect == _EffectType.elastic
              ? "Elastic Bounce"
              : "Ripple Wave"),
          elevation: 0,
        ),
        body: (kIsWeb)
            ? const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text("当前效果不支持 Web ，请在 App 查看"),
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),

                /// Total item count: messages + 1 for image header
                /// 总条目数：消息数 + 1 用于显示头部图片
                itemCount: _messages.length + 1,
                itemBuilder: (context, index) {
                  /// First item is the cat image
                  /// 第一项是猫咪图片
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: const Image(
                            image: AssetImage("static/gsy_cat.png"),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }

                  /// Adjust index for messages after the image
                  /// 调整图片后消息的索引
                  final messageIndex = index - 1;
                  final isMe = messageIndex % 2 == 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Builder(
                        builder: (ctx) => _InteractiveItem(
                          text: _messages[messageIndex],
                          isMe: isMe,
                          onDown: () async => await _handlePressStart(
                              ctx, _messages[messageIndex], isMe),
                          onUp: () => _handlePressEnd(),
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentEffect = _currentEffect == _EffectType.elastic
                  ? _EffectType.ripple
                  : _EffectType.elastic;
            });
          },
          child: Icon(_currentEffect == _EffectType.elastic
              ? Icons.waves
              : Icons.bubble_chart),
        ),
      ),
    );
  }
}

class _InteractiveItem extends StatefulWidget {
  final String text;
  final bool isMe;
  final Future<void> Function() onDown;
  final VoidCallback onUp;

  const _InteractiveItem({
    super.key,
    required this.text,
    required this.isMe,
    required this.onDown,
    required this.onUp,
  });

  @override
  State<_InteractiveItem> createState() => _InteractiveItemState();
}

class _InteractiveItemState extends State<_InteractiveItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHidden = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(_scaleController);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) async {
        setState(() => _isPressed = true);
        _scaleController.forward();
        await Future.delayed(const Duration(milliseconds: 80));

        /// Hide the original widget when pressed
        /// 按下时隐藏本体
        if (_isPressed && mounted) {
          await widget.onDown();
          if (mounted) {
            setState(() => _isHidden = true);
            _scaleController.reverse();
          }
        }
      },
      onPointerUp: (_) async {
        /// Changed to async
        /// 改为 async
        setState(() {
          _isPressed = false;

          /// Note: Do not set _isHidden to false immediately here
          /// Because Overlay is still playing Shader animation, showing the original immediately will cause ghosting with Overlay
          /// 注意：这里不要立刻把 _isHidden 设为 false
          /// 因为 Overlay 还在播放 Shader 动画，如果立刻显示本体，会和 Overlay 叠加产生重影
        });
        _scaleController.reverse();

        widget.onUp();

        /// Trigger release logic (start playing Shader) / 触发松手逻辑（开始播放 Shader）

        /// We show it slightly earlier to avoid flickering where both layers disappear, but avoid most of the fade-out time
        /// 我们稍微提前一点点显示，避免两层都消失的闪烁，但要避开大部分淡出时间
        if (_isHidden) {
          await Future.delayed(const Duration(milliseconds: 1));
          if (mounted) {
            setState(() => _isHidden = false);
          }
        }
      },
      onPointerCancel: (_) {
        setState(() {
          _isPressed = false;
          _isHidden = false;
        });
        _scaleController.reverse();
        widget.onUp();
      },
      child: Opacity(
        /// Completely hide when _isHidden is true to avoid ghosting
        /// 当 _isHidden 为 true 时完全隐藏，避免叠加重影
        opacity: _isHidden ? 0.0 : 1.0,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: _MessageBubble(text: widget.text, isMe: widget.isMe),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _MessageBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF0A84FF) : const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, color: Colors.white, height: 1.4),
      ),
    );
  }
}

class _ShockwaveOverlay extends StatefulWidget {
  final ui.FragmentProgram program;
  final ui.Image screenImage;
  final Offset touchCenter;
  final Rect targetRect;
  final String text;
  final bool isMe;

  final double force;
  final double paramSize;
  final ValueNotifier<bool> releaseNotifier;
  final VoidCallback onAnimationEnd;

  const _ShockwaveOverlay({
    super.key,
    required this.program,
    required this.screenImage,
    required this.touchCenter,
    required this.targetRect,
    required this.text,
    required this.isMe,
    required this.force,
    required this.paramSize,
    required this.releaseNotifier,
    required this.onAnimationEnd,
  });

  @override
  State<_ShockwaveOverlay> createState() => _ShockwaveOverlayState();
}

class _ShockwaveOverlayState extends State<_ShockwaveOverlay>
    with TickerProviderStateMixin {
  late AnimationController _holdController;
  late Animation<double> _blurAnim;
  late Animation<double> _popScaleAnim;
  late Animation<double> _holeExpansionAnim;
  late Animation<double> _darknessAnim;

  late AnimationController _waveController;
  late Animation<double> _waveTimeAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    /// 1. Hold: Accumulation phase
    /// 1. Hold: 蓄力阶段
    _holdController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _blurAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _holdController, curve: Curves.easeOut));

    /// Bubble expansion
    /// 气泡放大
    _popScaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _holdController, curve: Curves.easeOutBack));

    /// Background hole expansion
    /// 背景挖孔扩散
    _holeExpansionAnim = Tween<double>(begin: 400.0, end: -2.0).animate(
        CurvedAnimation(parent: _holdController, curve: Curves.easeOutCubic));

    /// Background darkening
    /// 背景压暗
    _darknessAnim = Tween<double>(begin: 0.0, end: 0.7).animate(
        CurvedAnimation(parent: _holdController, curve: Curves.easeInQuad));

    _holdController.forward();

    /// 2. Wave: Release phase
    /// 2. Wave: 释放阶段
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _waveTimeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _waveController, curve: Curves.linear));
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _waveController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn)));

    widget.releaseNotifier.addListener(_onRelease);
  }

  void _onRelease() {
    if (widget.releaseNotifier.value) {
      /// 1. Start ripple (1500ms)
      /// 1. 启动波纹（1500ms）
      _waveController.forward().whenComplete(widget.onAnimationEnd);

      /// 2. [Core Modification] Rapid rebound (300ms)
      /// Use animateBack with duration to force it back to original state quickly
      /// The duration here (300ms) is much smaller than the ripple's 1500ms
      /// 2. 【核心修改】快速回弹（300ms）
      /// 使用 animateBack 配合 duration，强制它快速变回原样
      /// 这里的 duration (300ms) 远小于波纹的 1500ms
      _holdController.animateBack(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _holdController.dispose();
    _waveController.dispose();
    widget.releaseNotifier.removeListener(_onRelease);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_holdController, _waveController]),
      builder: (context, child) {
        bool isReleasing = _waveController.isAnimating;
        return Stack(
          children: [
            /// Layer 1: Background / Shader Layer (Unchanged)
            /// Layer 1: 背景 / Shader层 (保持不变)
            Positioned.fill(
              child: Opacity(
                opacity: _fadeAnim.value,
                child: isReleasing
                    ? CustomPaint(
                        painter: _ShockwavePainter(
                          program: widget.program,
                          image: widget.screenImage,
                          time: _waveTimeAnim.value,
                          center: widget.touchCenter,
                          force: widget.force,
                          paramSize: widget.paramSize,
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(
                                sigmaX: _blurAnim.value,
                                sigmaY: _blurAnim.value),
                            child: RawImage(
                                image: widget.screenImage, fit: BoxFit.cover),
                          ),
                          CustomPaint(
                            painter: _SpotlightHolePainter(
                              holeRect: widget.targetRect,
                              opacity: _darknessAnim.value,
                              expansion: _holeExpansionAnim.value,
                              borderRadius: 24.0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            /// Layer 2: Floating Bubble Layer (Added Glowing Shadow)
            /// Layer 2: 悬浮气泡层 (添加发光 Shadow)
            Positioned(
              top: widget.targetRect.top,
              left: widget.targetRect.left,
              width: widget.targetRect.width,
              height: widget.targetRect.height,
              child: Transform.scale(
                /// The scale here will smoothly return to 1.0 following _holdController.reverse()
                /// 这里的 scale 会跟随 _holdController.reverse() 平滑变回 1.0
                scale: _popScaleAnim.value,
                child: Material(
                  color: Colors.transparent,
                  type: MaterialType.transparency,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        /// Shadow opacity will also smoothly disappear following _holdController
                        /// 阴影透明度也会跟随 _holdController 平滑消失
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.5 * _holdController.value),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.white
                              .withOpacity(0.6 * _holdController.value),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _MessageBubble(text: widget.text, isMe: widget.isMe),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SpotlightHolePainter extends CustomPainter {
  final Rect holeRect;
  final double opacity;
  final double expansion;
  final double borderRadius;

  _SpotlightHolePainter(
      {required this.holeRect,
      required this.opacity,
      required this.expansion,
      required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(Colors.black.withOpacity(opacity), BlendMode.srcOver);
    final currentHole = holeRect.inflate(expansion);
    final paint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            currentHole, Radius.circular(borderRadius + expansion * 0.5)),
        paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightHolePainter old) =>
      old.opacity != opacity || old.expansion != expansion;
}

/// ShockwavePainter (Generalized Naming)
/// Since the uniform interfaces of both shaders are consistent, this Painter does not need logic modification
/// ShockwavePainter (通用化命名)
/// 由于两个 shader 的 uniform 接口一致，这个 Painter 不需要修改逻辑
class _ShockwavePainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image image;
  final double time;
  final Offset center;
  final double force;

  /// This parameter is waveWidth in ripple, and radius in elastic
  /// As long as the type and position match
  /// 这个参数在 ripple 中是 waveWidth，在 elastic 中是 radius
  /// 只要类型和位置对上就行
  final double paramSize;

  _ShockwavePainter(
      {required this.program,
      required this.image,
      required this.time,
      required this.center,
      required this.force,
      required this.paramSize});

  @override
  void paint(Canvas canvas, Size size) {
    /// Ensure the order of uniform settings matches the definition order in both shader files exactly
    /// 确保 uniform 的设置顺序与两个 shader 文件中的定义顺序完全一致
    final shader = program.fragmentShader();
    shader.setFloat(0, size.width); // uResolution.x
    shader.setFloat(1, size.height); // uResolution.y
    shader.setFloat(2, time); // uTime
    shader.setFloat(3, center.dx); // uCenter.x
    shader.setFloat(4, center.dy); // uCenter.y
    shader.setFloat(5, force); // uForce
    shader.setFloat(6, paramSize); // uSize / uRadius
    shader.setImageSampler(0, image); // uTexture
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter old) =>
      old.time != time ||
      old.center != center ||
      old.image != image ||
      old.program != program;
}
