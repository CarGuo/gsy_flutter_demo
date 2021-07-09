import 'package:flutter/material.dart';

class DropRectTween extends Tween<Rect> {
  /// Creates a [Rect] tween.
  ///
  /// The [begin] and [end] properties may be null; the null value
  /// is treated as an empty rect at the top left corner.
  DropRectTween({required Rect begin, required Rect end})
      : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  Rect lerp(double t) => Rect.lerp(begin, end, t)!;
}
