import 'dart:math' as Math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ViewPagerDemoPage extends StatelessWidget {
  final List<Color> colorList = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        title: new Text("ViewPagerDemoPage"),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Expanded(
              child: new TransformerPageView(
                  loop: false,
                  controller: IndexController(),
                  itemBuilder: (BuildContext context, int index) {
                    return new Container(
                      decoration: BoxDecoration(
                          color: colorList[index % colorList.length],
                          border: Border.all(color: Colors.white)),
                      child: new Center(
                        child: new Text(
                          "$index",
                          style: new TextStyle(
                              fontSize: 80.0, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  itemCount: 3),
            ),
            new Expanded(
              child: new TransformerPageView(
                  loop: true,
                  controller: IndexController(),
                  transformer: new AccordionTransformer(),
                  itemBuilder: (BuildContext context, int index) {
                    return new Container(
                      decoration: BoxDecoration(
                          color: colorList[index % colorList.length],
                          border: Border.all(color: Colors.white)),
                      child: new Center(
                        child: new Text(
                          "$index",
                          style: new TextStyle(
                              fontSize: 80.0, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  itemCount: 3),
            ),
            new Expanded(
              child: new TransformerPageView(
                  loop: true,
                  controller: IndexController(),
                  transformer: new ThreeDTransformer(),
                  itemBuilder: (BuildContext context, int index) {
                    return new Container(
                      decoration: BoxDecoration(
                          color: colorList[index % colorList.length],
                          border: Border.all(color: Colors.white)),
                      child: new Center(
                        child: new Text(
                          "$index",
                          style: new TextStyle(
                              fontSize: 80.0, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  itemCount: 3),
            ),
            new Expanded(
              child: new TransformerPageView(
                  loop: true,
                  controller: IndexController(),
                  transformer: new DeepthPageTransformer(),
                  itemBuilder: (BuildContext context, int index) {
                    return new Container(
                      decoration: BoxDecoration(
                          color: colorList[index % colorList.length],
                          border: Border.all(color: Colors.white)),
                      child: new Center(
                        child: new Text(
                          "$index",
                          style: new TextStyle(
                              fontSize: 80.0, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  itemCount: 3),
            ),
          ],
        ),
      ),
    );
  }
}

class AccordionTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position < 0.0) {
      return new Transform.scale(
        scale: 1 + position,
        alignment: Alignment.topRight,
        child: child,
      );
    } else {
      return new Transform.scale(
        scale: 1 - position,
        alignment: Alignment.bottomLeft,
        child: child,
      );
    }
  }
}

class ThreeDTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double height = info.height!;
    double? width = info.width;
    double? pivotX = 0.0;
    if (position < 0 && position >= -1) {
      // left scrolling
      pivotX = width;
    }
    return new Transform(
      transform: new Matrix4.identity()
        ..rotate(new vector.Vector3(0.0, 2.0, 0.0), position * 1.5),
      origin: new Offset(pivotX!, height / 2),
      child: child,
    );
  }
}

class ZoomInPageTransformer extends PageTransformer {
  static const double ZOOM_MAX = 0.5;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double? width = info.width;
    if (position > 0 && position <= 1) {
      return new Transform.translate(
        offset: new Offset(-width! * position, 0.0),
        child: new Transform.scale(
          scale: 1 - position,
          child: child,
        ),
      );
    }
    return child;
  }
}

class ZoomOutPageTransformer extends PageTransformer {
  static const double MIN_SCALE = 0.85;
  static const double MIN_ALPHA = 0.5;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double? pageWidth = info.width;
    double? pageHeight = info.height;

    if (position < -1) {
      // [-Infinity,-1)
      // This page is way off-screen to the left.
      //view.setAlpha(0);
    } else if (position <= 1) {
      // [-1,1]
      // Modify the default slide transition to
      // shrink the page as well
      double scaleFactor = Math.max(MIN_SCALE, 1 - position.abs());
      double vertMargin = pageHeight! * (1 - scaleFactor) / 2;
      double horzMargin = pageWidth! * (1 - scaleFactor) / 2;
      double dx;
      if (position < 0) {
        dx = (horzMargin - vertMargin / 2);
      } else {
        dx = (-horzMargin + vertMargin / 2);
      }
      // Scale the page down (between MIN_SCALE and 1)
      double opacity = MIN_ALPHA +
          (scaleFactor - MIN_SCALE) / (1 - MIN_SCALE) * (1 - MIN_ALPHA);

      return new Opacity(
        opacity: opacity,
        child: new Transform.translate(
          offset: new Offset(dx, 0.0),
          child: new Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    } else {
      // (1,+Infinity]
      // This page is way off-screen to the right.
      // view.setAlpha(0);
    }

    return child;
  }
}

class DeepthPageTransformer extends PageTransformer {
  DeepthPageTransformer() : super(reverse: true);

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position <= 0) {
      return new Opacity(
        opacity: 1.0,
        child: new Transform.translate(
          offset: new Offset(0.0, 0.0),
          child: new Transform.scale(
            scale: 1.0,
            child: child,
          ),
        ),
      );
    } else if (position <= 1) {
      const double MIN_SCALE = 0.75;
      // Scale the page down (between MIN_SCALE and 1)
      double scaleFactor = MIN_SCALE + (1 - MIN_SCALE) * (1 - position);

      return new Opacity(
        opacity: 1.0 - position,
        child: new Transform.translate(
          offset: new Offset(info.width! * -position, 0.0),
          child: new Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    }

    return child;
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  final double _scale;
  final double _fade;

  ScaleAndFadeTransformer({double fade: 0.3, double scale: 0.8})
      : _fade = fade,
        _scale = scale;

  @override
  Widget transform(Widget item, TransformInfo info) {
    double position = info.position!;
    double scaleFactor = (1 - position.abs()) * (1 - _scale);
    double fadeFactor = (1 - position.abs()) * (1 - _fade);
    double opacity = _fade + fadeFactor;
    double scale = _scale + scaleFactor;
    return new Opacity(
      opacity: opacity,
      child: new Transform.scale(
        scale: scale,
        child: item,
      ),
    );
  }
}
