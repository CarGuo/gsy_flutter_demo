import 'package:flutter/material.dart';

import 'gesture_view_model.dart';

class GestureViewController {
  final List<GesturePasswordPointModel> _points = [];
  final List<Offset> _pathPoint = [];
  final GlobalKey globalKey = GlobalKey();
  double _frameRadius = 0.0;
  double _pointRadius = 0.0;
  Color _color = Colors.grey;
  Color _highlightColor = Colors.blue;
  Color _pathColor = Colors.blue;
  Function(List<int>)? _onFinishGesture;
  double _pathWidth = 5;
  Function()? _updateView;
  Offset? _firstPoint;
  Offset? _movePoint;
  List<int> _result = [];
}

extension Data on GestureViewController {
  List<GesturePasswordPointModel> get point => _points;

  List<Offset> get pathPoint {
    List<Offset> tempPathPoint = [];
    tempPathPoint.addAll(_pathPoint);
    if (_movePoint != null) {
      tempPathPoint.add(_movePoint!);
    }
    return tempPathPoint;
  }

  Color get pathColor => _pathColor;

  double get pathWidth => _pathWidth;

}

extension Private on GestureViewController {
  void _initPoint() {
    _points.addAll(List.generate(
      9,
      (index) => GesturePasswordPointModel(
        index: index,
        frameRadius: _frameRadius,
        pointRadius: _pointRadius,
        color: _color,
        highlightColor: _highlightColor,
        pathColor: _pathColor,
      ),
    ));
  }

  double _getPointWidth(double width) => width / 3;
}

extension Public on GestureViewController {
  void initParameters({
    double frameRadius = 0.0,
    double pointRadius = 0.0,
    Color color = Colors.grey,
    Color highlightColor = Colors.blue,
    Color pathColor = Colors.blue,
    Function(List<int>)? onFinishGesture,
    Function()? updateView,
    double pathWidth = 5,
  }) {
    _frameRadius = frameRadius;
    _pointRadius = pointRadius;
    _color = color;
    _highlightColor = highlightColor;
    _pathColor = pathColor;
    _onFinishGesture = onFinishGesture;
    _updateView = updateView;
    _pathWidth = pathWidth;
    _initPoint();
  }

  void setPointValues() {
    try {
      Size size = globalKey.currentContext?.size ?? Size.zero;
      double pointWidth = _getPointWidth(size.width);
      List<Offset> pointCenter = [];
      for (int x = 1; x <= 3; x++) {
        for (int y = 1; y <= 3; y++) {
          Offset center = Offset((y - 1) * pointWidth + pointWidth / 2,
              (x - 1) * pointWidth + pointWidth / 2);
          pointCenter.add(center);
        }
      }
      for (int index = 0; index < pointCenter.length; index++) {
        _points[index].centerPoint = pointCenter[index];
      }
    } catch (_) {}
  }
}

extension Tap on GestureViewController {
  void onPanDown(DragDownDetails e) {
    for (var item in _points) {
      if (item.containPoint(e.localPosition)) {
        item.selected = true;
        _firstPoint = e.localPosition;
        _pathPoint.add(item.centerPoint);
        _updateView?.call();
        _result.add(item.index);
        break;
      }
    }
  }

  void onPanUpdate(DragUpdateDetails e) {
    if (_firstPoint == null) return;
    _movePoint = e.localPosition;
    for (var item in _points) {
      if (item.containPoint(e.localPosition)) {
        if (!item.selected) {
          item.selected = true;
          _pathPoint.add(item.centerPoint);
          _result.add(item.index);
        }
        break;
      }
    }
    _updateView?.call();
  }

  void onPanEnd(DragEndDetails e) {
    _firstPoint = null;
    _movePoint = null;

    _onFinishGesture?.call(_result);
    _result.clear();
    for (var element in _points) {
      element.selected = false;
    }
    _pathPoint.clear();
    _updateView?.call();
  }
}
