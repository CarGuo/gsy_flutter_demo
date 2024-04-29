import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CustomViewport extends Viewport {
  /// 需要最后渲染的widget的RenderObject类列表
  final List<Type> highestChildInPaintOrderClassList;

  CustomViewport({
    super.key,
    super.axisDirection,
    super.crossAxisDirection,
    super.anchor,
    required super.offset,
    super.center,
    super.cacheExtent,
    super.slivers,
    this.highestChildInPaintOrderClassList = const <Type>[],
  });

  @override
  RenderViewport createRenderObject(BuildContext context) {
    return _RenderExpandedViewport(
      axisDirection: axisDirection,
      crossAxisDirection: crossAxisDirection ??
          Viewport.getDefaultCrossAxisDirection(context, axisDirection),
      anchor: anchor,
      offset: offset,
      cacheExtent: cacheExtent,
      highestChildInPaintOrderClassList: highestChildInPaintOrderClassList,
    );
  }
}

class _RenderExpandedViewport extends RenderViewport {
  final List<Type> highestChildInPaintOrderClassList;

  _RenderExpandedViewport({
    super.axisDirection,
    required super.crossAxisDirection,
    required super.offset,
    super.anchor,
    super.cacheExtent,
    this.highestChildInPaintOrderClassList = const <Type>[],
  });

  @override
  Iterable<RenderSliver> get childrenInPaintOrder {
    if (firstChild == null) return [];
    final children = _getChildrenPaintOrder();
    return children;
  }

  @override
  Iterable<RenderSliver> get childrenInHitTestOrder {
    if (firstChild == null) return [];
    final children = _getChildrenPaintOrder();
    return children.reversed.toList();
  }

  List<RenderSliver> _getChildrenPaintOrder() {
    final List<RenderSliver> children = [];
    var child = firstChild;
    while (child != null) {
      children.add(child);
      child = childAfter(child);
    }
    if (highestChildInPaintOrderClassList.isNotEmpty) {
      for (var clazz in highestChildInPaintOrderClassList) {
        try {
          final renderSliver =
              children.firstWhere((child) => child.runtimeType == clazz);
          children.remove(renderSliver);
          children.add(renderSliver);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
      return children;
    } else {
      return children.reversed.toList();
    }
  }
}
