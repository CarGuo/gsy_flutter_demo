import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CustomViewport extends Viewport {
  /// 需要最后渲染的widget的RenderObject类列表
  final List<Type> highestChildInPaintOrderClassList;

  CustomViewport({
    Key? key,
    AxisDirection axisDirection = AxisDirection.down,
    AxisDirection? crossAxisDirection,
    double anchor = 0.0,
    required ViewportOffset offset,
    Key? center,
    double? cacheExtent,
    List<Widget> slivers = const <Widget>[],
    this.highestChildInPaintOrderClassList = const <Type>[],
  }) : super(
            key: key,
            slivers: slivers,
            axisDirection: axisDirection,
            crossAxisDirection: crossAxisDirection,
            anchor: anchor,
            offset: offset,
            center: center,
            cacheExtent: cacheExtent);

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
    AxisDirection axisDirection = AxisDirection.down,
    required AxisDirection crossAxisDirection,
    required ViewportOffset offset,
    double anchor = 0.0,
    List<RenderSliver>? children,
    RenderSliver? center,
    double? cacheExtent,
    this.highestChildInPaintOrderClassList = const <Type>[],
  }) : super(
          axisDirection: axisDirection,
          crossAxisDirection: crossAxisDirection,
          offset: offset,
          anchor: anchor,
          children: children,
          center: center,
          cacheExtent: cacheExtent,
        );

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
      highestChildInPaintOrderClassList.forEach((clazz) {
        try {
          final renderSliver =
              children.firstWhere((child) => child.runtimeType == clazz);
          children.remove(renderSliver);
          children.add(renderSliver);
        } catch (e) {
          print(e);
        }
      });
      return children;
    } else {
      return children.reversed.toList();
    }
  }
}
