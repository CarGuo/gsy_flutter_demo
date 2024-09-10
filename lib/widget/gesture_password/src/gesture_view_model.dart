
import 'dart:math';
import 'package:flutter/material.dart';

class GesturePasswordPointModel {
  Offset centerPoint = Offset.zero;
  bool selected = false;
  double frameRadius;
  double pointRadius;
  Color color = Colors.grey;
  Color highlightColor = Colors.blue;
  Color pathColor = Colors.blue;
  int index = 0;

  GesturePasswordPointModel({
    this.index = 0,
    this.centerPoint = Offset.zero,
    this.frameRadius = 0.0,
    this.pointRadius = 0.0,
    this.selected = false,
    this.color = Colors.grey,
    this.highlightColor = Colors.blue,
    this.pathColor = Colors.blue,
  });


  Color get pointColor{
    return selected ? highlightColor : color;
  }
  Color get frameColor => selected ?  highlightColor : color;

  bool containPoint(Offset offset){
    return distanceTo(offset, centerPoint) <= frameRadius;
  }


  double distanceTo(Offset f1, Offset f2){
    var dx= f1.dx - f2.dx;
    var dy= f1.dy - f2.dy;
    return sqrt(dx * dx + dy * dy);
  }

}
