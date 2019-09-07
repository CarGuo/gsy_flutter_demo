import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class _CustomSliver extends SingleChildRenderObjectWidget {
  const _CustomSliver({
    Key key,
    this.containerLayoutExtent = 0.0,
    this.initLayoutExtent = 0.0,
    this.hasLayoutExtent = false,
    this.pinned = false,
    Widget child,
  })  : assert(containerLayoutExtent != null),
        assert(containerLayoutExtent >= 0.0),
        assert(hasLayoutExtent != null),
        super(key: key, child: child);

  final double initLayoutExtent;
  final double containerLayoutExtent;
  final bool hasLayoutExtent;
  final bool pinned;

  @override
  _RenderCustomSliver createRenderObject(BuildContext context) {
    return _RenderCustomSliver(
      containerExtent: containerLayoutExtent,
      initLayoutExtent: initLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
      pinned: pinned,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderCustomSliver renderObject) {
    renderObject
      ..containerLayoutExtent = containerLayoutExtent
      ..initLayoutExtent = initLayoutExtent
      ..pinned = pinned
      ..hasLayoutExtent = hasLayoutExtent;
  }
}

class _RenderCustomSliver extends RenderSliver with RenderObjectWithChildMixin<RenderBox> {
  _RenderCustomSliver({
    @required double containerExtent,
    @required double initLayoutExtent,
    @required bool hasLayoutExtent,
    @required bool pinned,
    RenderBox child,
  })  : assert(containerExtent != null),
        assert(containerExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _containerExtent = containerExtent,
        _initLayoutExtent = initLayoutExtent,
        _pinned = pinned,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  double get containerLayoutExtent => _containerExtent;
  double _containerExtent;

  set containerLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _containerExtent) return;
    _containerExtent = value;
    markNeedsLayout();
  }

  bool _pinned;

  set pinned(bool value) {
    assert(value != null);
    if (value == _pinned) return;
    _pinned = value;
    markNeedsLayout();
  }

  double _initLayoutExtent;

  set initLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _containerExtent) return;
    _initLayoutExtent = value;
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
    double layoutExtent = (_hasLayoutExtent ? 1.0 : 0.0) * _containerExtent;
    if (_hasLayoutExtent == false && _initLayoutExtent != null && _initLayoutExtent > 0) {
      layoutExtent += _initLayoutExtent;
    }
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
      if (_pinned) {
        geometry = SliverGeometry(
          scrollExtent: containerLayoutExtent,
          paintOrigin: constraints.overlap,
          paintExtent: min(layoutExtent, constraints.remainingPaintExtent),
          layoutExtent: layoutExtent,
          maxPaintExtent: containerLayoutExtent,
          maxScrollObstructionExtent: 70,
          cacheExtent: layoutExtent > 0.0 ? -constraints.cacheOrigin + layoutExtent : layoutExtent,
          hasVisualOverflow: true, // Conservatively say we do have overflow to avoid complexity.
        );
      } else {
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
          maxScrollObstructionExtent: _initLayoutExtent,
          layoutExtent: max(layoutExtent - constraints.scrollOffset, 0.0),
          hasVisualOverflow: true, // Conservatively say we do have overflow to avoid complexity.
        );
      }
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

typedef ContainerBuilder = Widget Function(
  BuildContext context,
  double pulledExtent,
  double triggerPullDistance,
  double containerExtent,
);

class CustomSliver extends StatefulWidget {
  const CustomSliver({
    Key key,
    this.triggerPullDistance = _defaultTriggerPullDistance,
    this.containerExtent = _defaultcontainerExtent,
    this.initLayoutExtent = 0,
    this.pinned = false,
    this.builder = buildSimplecontainer,
  })  : assert(triggerPullDistance != null),
        assert(triggerPullDistance > 0.0),
        assert(containerExtent != null),
        assert(containerExtent >= 0.0),
        assert(
            triggerPullDistance >= containerExtent,
            'The  container cannot take more space in its final state '
            'than the amount initially created by overscrolling.'),
        super(key: key);

  final double triggerPullDistance;

  final double initLayoutExtent;

  final double containerExtent;

  final bool pinned;

  final ContainerBuilder builder;

  static const double _defaultTriggerPullDistance = 100.0;
  static const double _defaultcontainerExtent = 60.0;

  static Widget buildSimplecontainer(
    BuildContext context,
    double pulledExtent,
    double triggerPullDistance,
    double containerExtent,
  ) {
    const Curve opacityCurve = Interval(0.0, 1, curve: Curves.easeInOut);
    return Stack(
      children: <Widget>[
        new Opacity(
          opacity: 1,
          child: new Container(color: Colors.red),
        ),
        new Opacity(
          opacity: opacityCurve.transform(min(pulledExtent / containerExtent, 1.0)),
          child: new Container(color: Colors.amber),
        ),
      ],
    );
  }

  @override
  CustomSliverState createState() => CustomSliverState();
}

class CustomSliverState extends State<CustomSliver> {
  double latestcontainerBoxExtent = 0.0;
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
      containerLayoutExtent: widget.containerExtent,
      initLayoutExtent: widget.initLayoutExtent,
      hasLayoutExtent: hasSliverLayoutExtent,
      pinned: widget.pinned,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          latestcontainerBoxExtent = constraints.maxHeight;
          if (widget.builder != null && latestcontainerBoxExtent > 0) {
            return widget.builder(
              context,
              latestcontainerBoxExtent,
              widget.triggerPullDistance,
              widget.containerExtent,
            );
          }
          return Container();
        },
      ),
    );
  }
}
