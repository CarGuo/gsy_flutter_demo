import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 来自  https://github.com/gskinnerTeam/flutter-wonderous-app 上的一个 UI 效果
/// 文章  https://juejin.cn/post/7212249660581249082
class PhotoGalleryDemoPage extends StatefulWidget {
  const PhotoGalleryDemoPage({super.key});

  @override
  State<PhotoGalleryDemoPage> createState() => _PhotoGalleryDemoPageState();
}

class _PhotoGalleryDemoPageState extends State<PhotoGalleryDemoPage> {
  @override
  Widget build(BuildContext context) {
    return const PhotoGallery();
  }
}

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  static const int _gridSize = 5;

  late List<Color> colorList;

  // Index starts in the middle of the grid (eg, 25 items, index will start at 13)
  int _index = ((_gridSize * _gridSize) / 2).round();

  Offset _lastSwipeDir = Offset.zero;

  bool _skipNextOffsetTween = false;

  ///根据屏幕尺寸，决定 Padding 的大小，通过 scale 缩放
  _getPadding(Size size) {
    double scale = 1;
    final shortestSide = size.shortestSide;
    const tabletXl = 1000;
    const tabletLg = 800;
    const tabletSm = 600;
    const phoneLg = 400;
    if (shortestSide > tabletXl) {
      scale = 1.25;
    } else if (shortestSide > tabletLg) {
      scale = 1.15;
    } else if (shortestSide > tabletSm) {
      scale = 1;
    } else if (shortestSide > phoneLg) {
      scale = .9; // phone
    } else {
      scale = .85; // small phone
    }
    return 24 * scale;
  }

  int get _imgCount => pow(_gridSize, 2).round();

  Widget _buildImage(int index, Size imgSize) {
    /// Bind to collectibles.statesById because we might need to rebuild if a collectible is found.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: imgSize.width,
        height: imgSize.height,
        color: colorList[index],
      ),
    );
  }

  /// Converts a swipe direction into a new index
  void _handleSwipe(Offset dir) {
    // Calculate new index, y swipes move by an entire row, x swipes move one index at a time
    int newIndex = _index;

    /// Offset(1.0, 0.0)  是手指右滑
    /// Offset(-1.0, 0.0) 是手指左滑
    /// Offset(0.0, 1.0)  是手指下滑
    /// Offset(0.0, -1.0) 是手指上滑

    /// dy > 0 ，就是手指下滑，也就是页面要往上，那么 index 就需要 -1，反过来就是 + 1
    if (dir.dy != 0) newIndex += _gridSize * (dir.dy > 0 ? -1 : 1);

    /// dx > 0 ，就是手指右滑，也就是页面要往左，那么 index 就需要 -1，反过来就是 + 1
    if (dir.dx != 0) newIndex += (dir.dx > 0 ? -1 : 1);

    ///这里判断下 index 是不是超出位置
    // After calculating new index, exit early if we don't like it...
    if (newIndex < 0 || newIndex > _imgCount - 1) {
      return; // keep the index in range
    }
    if (dir.dx < 0 && newIndex % _gridSize == 0) {
      return; // prevent right-swipe when at right side
    }
    if (dir.dx > 0 && newIndex % _gridSize == _gridSize - 1) {
      return; // prevent left-swipe when at left side
    }
    /// 响应
    _lastSwipeDir = dir;
    HapticFeedback.lightImpact();
    _setIndex(newIndex);
  }

  void _setIndex(int value, {bool skipAnimation = false}) {
    if (kDebugMode) {
      print("######## $value");
    }
    if (value < 0 || value >= _imgCount) return;
    _skipNextOffsetTween = skipAnimation;
    setState(() => _index = value);
  }

  /// Determine the required offset to show the current selected index.
  /// index=0 is top-left, and the index=max is bottom-right.
  Offset _calculateCurrentOffset(double padding, Size size) {
    /// 获取水平方向一半的大小，默认也就是 2.0，因为 floorToDouble
    double halfCount = (_gridSize / 2).floorToDouble();

    /// Item 大小加上 Padding，也就是每个 Item 的实际大小
    Size paddedImageSize = Size(size.width + padding, size.height + padding);

    /// 计算出开始位置的 top-left
    // Get the starting offset that would show the top-left image (index 0)
    final originOffset = Offset(
        halfCount * paddedImageSize.width, halfCount * paddedImageSize.height);

    /// 得到要移动的 index 所在的行和列位置
    // Add the offset for the row/col
    int col = _index % _gridSize;
    int row = (_index / _gridSize).floor();

    /// 负数计算出要移动的 index 的 top-left 位置，比如 index 比较小，那么这个 indexedOffset 就比中心点小，相减之后 Offset 就会是正数
    /// 是不是有点懵逼？为什么正数 translate 会往 index 小的 方向移动？？
    /// 因为你代入的不对，我们 translate 移动的是整个 GridView
    /// 正数是向左向下移动，自然就把左边或者上面的 Item 显示出来
    final indexedOffset =
        Offset(-paddedImageSize.width * col, -paddedImageSize.height * row);

    return originOffset + indexedOffset;
  }

  @override
  void initState() {
    colorList = List.generate(
        _imgCount,
        (index) => Color((Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var width = size.width;
    var height = size.height;
    bool isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    ///根据横竖屏状态决定 Item 大小
    Size imgSize = isLandscape
        ? Size(width * .5, height * .66)
        : Size(width * .66, height * .5);

    var padding = _getPadding(MediaQuery.sizeOf(context));

    final cutoutTweenDuration =
        _skipNextOffsetTween ? Duration.zero : const Duration(milliseconds: 600) * .5;

    final offsetTweenDuration =
        _skipNextOffsetTween ? Duration.zero : const Duration(milliseconds: 600) * .4;

    var gridOffset = _calculateCurrentOffset(padding, imgSize);
    gridOffset += Offset(0, -MediaQuery.paddingOf(context).top / 2);

    //动画效果
    return _AnimatedCutoutOverlay(
      animationKey: ValueKey(_index),
      cutoutSize: imgSize,
      swipeDir: _lastSwipeDir,
      duration: cutoutTweenDuration,
      opacity: .7,
      child: SafeArea(
        bottom: false,
        // Place content in overflow box, to allow it to flow outside the parent
        child: OverflowBox(
          maxWidth: _gridSize * imgSize.width + padding * (_gridSize - 1),
          maxHeight: _gridSize * imgSize.height + padding * (_gridSize - 1),
          alignment: Alignment.center,
          // 手势获取方向上下左右
          child: EightWaySwipeDetector(
            onSwipe: _handleSwipe,
            threshold: 30,
            // A tween animation builder moves from image to image based on current offset
            child: TweenAnimationBuilder<Offset>(
                tween: Tween(begin: gridOffset, end: gridOffset),
                duration: offsetTweenDuration,
                curve: Curves.easeOut,
                builder: (_, value, child) =>
                    Transform.translate(offset: value, child: child),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: _gridSize,
                  childAspectRatio: imgSize.aspectRatio,
                  mainAxisSpacing: padding,
                  crossAxisSpacing: padding,
                  children:
                      List.generate(_imgCount, (i) => _buildImage(i, imgSize)),
                )),
          ),
        ),
      ),
    );
  }
}

class EightWaySwipeDetector extends StatefulWidget {
  const EightWaySwipeDetector(
      {super.key,
      required this.child,
      this.threshold = 50,
      required this.onSwipe});
  final Widget child;
  final double threshold;
  final void Function(Offset dir)? onSwipe;

  @override
  State<EightWaySwipeDetector> createState() => _EightWaySwipeDetectorState();
}

class _EightWaySwipeDetectorState extends State<EightWaySwipeDetector> {
  Offset _startPos = Offset.zero;
  Offset _endPos = Offset.zero;
  bool _isSwiping = false;

  void _resetSwipe() {
    _startPos = _endPos = Offset.zero;
    _isSwiping = false;
  }

  ///这里主要是返回一个 -1 ～ 1 之间的数值，具体用于判断方向
  /// Offset(1.0, 0.0)  是手指右滑
  /// Offset(-1.0, 0.0) 是手指左滑
  /// Offset(0.0, 1.0)  是手指下滑
  /// Offset(0.0, -1.0) 是手指上滑
  void _maybeTriggerSwipe() {
    // Exit early if we're not currently swiping
    if (_isSwiping == false) return;

    /// 开始和结束位置计算出移动距离
    // Get the distance of the swipe
    Offset moveDelta = _endPos - _startPos;
    final distance = moveDelta.distance;

    /// 对比偏移量大小是否超过了 threshold ，不能小于 1
    // Trigger swipe if threshold has been exceeded, if threshold is < 1, use 1 as a minimum value.
    if (distance >= max(widget.threshold, 1)) {
      // Normalize the dx/dy values between -1 and 1
      moveDelta /= distance;
      // Round the dx/dy values to snap them to -1, 0 or 1, creating an 8-way directional vector.
      Offset dir = Offset(
        moveDelta.dx.roundToDouble(),
        moveDelta.dy.roundToDouble(),
      );
      widget.onSwipe?.call(dir);
      _resetSwipe();
    }
  }

  void _handleSwipeStart(d) {
    _isSwiping = true;
    _startPos = _endPos = d.localPosition;
  }

  void _handleSwipeUpdate(d) {
    _endPos = d.localPosition;
    _maybeTriggerSwipe();
  }

  void _handleSwipeEnd(d) {
    _maybeTriggerSwipe();
    _resetSwipe();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: _handleSwipeStart,
        onPanUpdate: _handleSwipeUpdate,
        onPanCancel: _resetSwipe,
        onPanEnd: _handleSwipeEnd,
        child: widget.child);
  }
}

class _AnimatedCutoutOverlay extends StatelessWidget {
  const _AnimatedCutoutOverlay(
      {required this.child,
      required this.cutoutSize,
      required this.animationKey,
      this.duration,
      required this.swipeDir,
      required this.opacity});
  final Widget child;
  final Size cutoutSize;
  final Key animationKey;
  final Offset swipeDir;
  final Duration? duration;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // 用 ClipPath 做一个动画抠图
        Animate(
          effects: [
            CustomEffect(
                builder: _buildAnimatedCutout,
                curve: Curves.easeOut,
                duration: duration)
          ],
          key: animationKey,
          onComplete: (c) => c.reverse(),
          // 用一个黑色的蒙层，这里的 child 会变成 effects 里 builder 里的 child
          // 也就是黑色 Container 会在 _buildAnimatedCutout 作为 ClipPath 的 child
          child: IgnorePointer(
              child: Container(color: Colors.black.withOpacity(opacity))),
        ),
      ],
    );
  }

  /// Scales from 1 --> (1 - scaleAmt) --> 1
  Widget _buildAnimatedCutout(BuildContext context, double anim, Widget child) {
    // controls how much the center cutout will shrink when changing images
    const scaleAmt = .25;
    final size = Size(
      cutoutSize.width * (1 - scaleAmt * anim * swipeDir.dx.abs()),
      cutoutSize.height * (1 - scaleAmt * anim * swipeDir.dy.abs()),
    );
    return ClipPath(clipper: _CutoutClipper(size), child: child);
  }
}

/// Creates an overlay with a hole in the middle of a certain size.
class _CutoutClipper extends CustomClipper<Path> {
  _CutoutClipper(this.cutoutSize);

  final Size cutoutSize;

  @override
  Path getClip(Size size) {
    double padX = (size.width - cutoutSize.width) / 2;
    double padY = (size.height - cutoutSize.height) / 2;

    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()
        ..addRRect(
          RRect.fromLTRBR(
            padX,
            padY,
            size.width - padX,
            size.height - padY,
            const Radius.circular(6),
          ),
        )
        ..close(),
    );
  }

  @override
  bool shouldReclip(_CutoutClipper oldClipper) =>
      oldClipper.cutoutSize != cutoutSize;
}

class ShowPathDifference extends StatelessWidget {
  const ShowPathDifference({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShowPathDifference'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("static/gsy_cat.png"),
                ),
              ),
            ),
          ),
          Center(
            child: CustomPaint(
              painter: ShowPathDifferencePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowPathDifferencePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.blue.withAlpha(160);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(
              RRect.fromLTRBR(-150, -150, 150, 150, const Radius.circular(10))),
        Path()
          ..addOval(Rect.fromCircle(center: const Offset(0, 0), radius: 100))
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
