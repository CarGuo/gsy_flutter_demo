import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///CloudWidget RenderBox
///默认都会 mixins  ContainerRenderObjectMixin 和 RenderBoxContainerDefaultsMixin
class RenderCloudWidget extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RenderCloudParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RenderCloudParentData> {
  RenderCloudWidget({
    List<RenderBox> children,
    Overflow overflow = Overflow.visible,
    double ratio,
  })  : _ratio = ratio,
        _overflow = overflow {
    addAll(children);
  }

  ///圆周
  double _mathPi = math.pi * 2;

  ///是否需要裁剪
  bool _needClip = false;

  ///溢出
  Overflow get overflow => _overflow;
  Overflow _overflow;

  set overflow(Overflow value) {
    assert(value != null);
    if (_overflow != value) {
      _overflow = value;
      markNeedsPaint();
    }
  }

  ///比例
  double _ratio;

  double get ratio => _ratio;

  set ratio(double value) {
    assert(value != null);
    if (_ratio != value) {
      _ratio = value;
      markNeedsPaint();
    }
  }

  ///是否重复区域了
  bool overlaps(RenderCloudParentData data) {
    Rect rect = data.content;

    RenderBox child = data.previousSibling;

    if (child == null) {
      return false;
    }

    do {
      RenderCloudParentData childParentData = child.parentData;
      if (rect.overlaps(childParentData.content)) {
        return true;
      }
      child = childParentData.previousSibling;
    } while (child != null);
    return false;
  }

  ///设置为我们的数据
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderCloudParentData)
      child.parentData = RenderCloudParentData();
  }

  @override
  void performLayout() {
    ///默认不需要裁剪
    _needClip = false;

    ///没有 childCount 不玩
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    ///初始化区域
    var recordRect = Rect.zero;
    var previousChildRect = Rect.zero;

    RenderBox child = firstChild;

    while (child != null) {
      var curIndex = -1;

      ///提出数据
      final RenderCloudParentData childParentData = child.parentData;

      child.layout(constraints, parentUsesSize: true);

      var childSize = child.size;

      ///记录大小
      childParentData.width = childSize.width;
      childParentData.height = childSize.height;

      do {
        ///设置 xy 轴的比例
        var rX = ratio >= 1 ? ratio : 1.0;
        var rY = ratio <= 1 ? ratio : 1.0;

        ///调整位置
        var step = 0.02 * _mathPi;
        var rotation = 0.0;
        var angle = curIndex * step;
        var angleRadius = 5 + 5 * angle;
        var x = rX * angleRadius * math.cos(angle + rotation);
        var y = rY * angleRadius * math.sin(angle + rotation);
        var position = Offset(x, y);

        ///计算得到绝对偏移
        var childOffset = position - Alignment.center.alongSize(childSize);

        ++curIndex;

        ///设置为遏制
        childParentData.offset = childOffset;

        ///判处是否交叠
      } while (overlaps(childParentData));

      ///记录区域
      previousChildRect = childParentData.content;
      recordRect = recordRect.expandToInclude(previousChildRect);

      ///下一个
      child = childParentData.nextSibling;
    }

    ///调整布局大小
    size = constraints
        .tighten(
          height: recordRect.height,
          width: recordRect.width,
        )
        .smallest;

    ///居中
    var contentCenter = size.center(Offset.zero);
    var recordRectCenter = recordRect.center;
    var transCenter = contentCenter - recordRectCenter;
    child = firstChild;
    while (child != null) {
      final RenderCloudParentData childParentData = child.parentData;
      childParentData.offset += transCenter;
      child = childParentData.nextSibling;
    }

    ///超过了嘛？
    _needClip =
        size.width < recordRect.width || size.height < recordRect.height;
  }

  ///设置绘制默认
  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_needClip || _overflow != Overflow.clip) {
      defaultPaint(context, offset);
    } else {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
      );
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// CloudParentData
class RenderCloudParentData extends ContainerBoxParentData<RenderBox> {
  double width;
  double height;

  Rect get content => Rect.fromLTWH(
        offset.dx,
        offset.dy,
        width,
        height,
      );
}
