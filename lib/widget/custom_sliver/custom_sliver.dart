import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class _CustomSliver extends SingleChildRenderObjectWidget {
  const _CustomSliver({
    Key key,
    this.indicatorLayoutExtent = 0.0,
    this.hasLayoutExtent = false,
    Widget child,
  })  : assert(indicatorLayoutExtent != null),
        assert(indicatorLayoutExtent >= 0.0),
        assert(hasLayoutExtent != null),
        super(key: key, child: child);

  final double indicatorLayoutExtent;
  final bool hasLayoutExtent;

  @override
  _RenderCustomSliver createRenderObject(BuildContext context) {
    return _RenderCustomSliver(
      indicatorExtent: indicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderCustomSliver renderObject) {
    renderObject
      ..indicatorLayoutExtent = indicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent;
  }
}

class _RenderCustomSliver extends RenderSliver with RenderObjectWithChildMixin<RenderBox> {
  _RenderCustomSliver({
    @required double indicatorExtent,
    @required bool hasLayoutExtent,
    RenderBox child,
  })  : assert(indicatorExtent != null),
        assert(indicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _indicatorExtent = indicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  double get indicatorLayoutExtent => _indicatorExtent;
  double _indicatorExtent;

  set indicatorLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _indicatorExtent) return;
    _indicatorExtent = value;
    markNeedsLayout();
  }

  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;

  set hasLayoutExtent(bool value) {
    assert(value != null);
    if (value == _hasLayoutExtent) return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);
    final double layoutExtent = (_hasLayoutExtent ? 1.0 : 0.0) * _indicatorExtent;
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      return;
    }

    final bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent = constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;

    child.layout(
      constraints.asBoxConstraints(
        maxExtent: layoutExtent + overscrolledExtent,
      ),
      parentUsesSize: true,
    );
    if (active) {
      geometry = SliverGeometry(
        scrollExtent: layoutExtent,
        paintOrigin: -overscrolledExtent - constraints.scrollOffset,
        paintExtent: max(
          max(child.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        maxPaintExtent: max(
          max(child.size.height, layoutExtent) - constraints.scrollOffset,
          0.0,
        ),
        layoutExtent: max(layoutExtent - constraints.scrollOffset, 0.0),
      );
    } else {
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.overlap < 0.0 || constraints.scrollOffset + child.size.height > 0) {
      paintContext.paintChild(child, offset);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}

typedef ControlIndicatorBuilder = Widget Function(
  BuildContext context,
  double pulledExtent,
  double triggerPullDistance,
  double indicatorExtent,
);

class CustomSliver extends StatefulWidget {
  const CustomSliver({
    Key key,
    this.triggerPullDistance = _defaultTriggerPullDistance,
    this.indicatorExtent = _defaultIndicatorExtent,
    this.builder = buildSimpleIndicator,
  })  : assert(triggerPullDistance != null),
        assert(triggerPullDistance > 0.0),
        assert(indicatorExtent != null),
        assert(indicatorExtent >= 0.0),
        assert(
            triggerPullDistance >= indicatorExtent,
            'The  indicator cannot take more space in its final state '
            'than the amount initially created by overscrolling.'),
        super(key: key);

  final double triggerPullDistance;

  final double indicatorExtent;

  final ControlIndicatorBuilder builder;

  static const double _defaultTriggerPullDistance = 100.0;
  static const double _defaultIndicatorExtent = 60.0;

  static Widget buildSimpleIndicator(
    BuildContext context,
    double pulledExtent,
    double triggerPullDistance,
    double indicatorExtent,
  ) {
    const Curve opacityCurve = Interval(0.0, 1, curve: Curves.easeInOut);
    return Stack(
      children: <Widget>[
        new Opacity(
          opacity: 1 - opacityCurve.transform(min(pulledExtent / indicatorExtent, 1.0)),
          child: new Container(color: Colors.red),
        ),
        new Opacity(
          opacity: opacityCurve.transform(min(pulledExtent / indicatorExtent, 1.0)),
          child: new Container(color: Colors.amber),
        ),
      ],
    );
  }

  @override
  CustomSliverState createState() => CustomSliverState();
}

class CustomSliverState extends State<CustomSliver> {
  double latestIndicatorBoxExtent = 0.0;
  bool hasSliverLayoutExtent = false;
  bool need = false;
  bool draging = false;

  @override
  void initState() {
    super.initState();
  }

  handleShow() {
    if (hasSliverLayoutExtent != true) {
      setState(() => hasSliverLayoutExtent = true);
    }
  }

  handleHide() {
    if (hasSliverLayoutExtent != false) {
      setState(() => hasSliverLayoutExtent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CustomSliver(
      indicatorLayoutExtent: widget.indicatorExtent,
      hasLayoutExtent: hasSliverLayoutExtent,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          latestIndicatorBoxExtent = constraints.maxHeight;
          if (widget.builder != null && latestIndicatorBoxExtent > 0) {
            return widget.builder(
              context,
              latestIndicatorBoxExtent,
              widget.triggerPullDistance,
              widget.indicatorExtent,
            );
          }
          return Container();
        },
      ),
    );
  }
}
