import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LinkFlexibleSpaceBar extends StatefulWidget {
  const LinkFlexibleSpaceBar({
    Key? key,
    this.title,
    this.background,
    this.centerTitle,
    this.bottom,
    this.image,
    this.titlePadding,
    this.collapseMode = CollapseMode.parallax,
    this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
  })  : super(key: key);

  final Widget? title;

  final Widget? background;

  final List<Widget>? bottom;

  final bool? centerTitle;

  final String? image;

  final CollapseMode collapseMode;

  final List<StretchMode> stretchModes;

  final EdgeInsetsGeometry? titlePadding;

  @override
  _LinkFlexibleSpaceBarState createState() => _LinkFlexibleSpaceBarState();
}

class _LinkFlexibleSpaceBarState extends State<LinkFlexibleSpaceBar> {
  bool? _getEffectiveCenterTitle(ThemeData theme) {
    if (widget.centerTitle != null) return widget.centerTitle;
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return false;
      case TargetPlatform.iOS:
        return true;
      default:
        return null;
    }
  }

  Alignment? _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) return Alignment.bottomCenter;
    final TextDirection textDirection = Directionality.of(context);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }
  }

  double? _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    switch (widget.collapseMode) {
      case CollapseMode.pin:
        return -(settings.maxExtent - settings.currentExtent);
      case CollapseMode.none:
        return 0.0;
      case CollapseMode.parallax:
        final double deltaExtent = settings.maxExtent - settings.minExtent;
        return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final FlexibleSpaceBarSettings settings = context
          .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

      final List<Widget> children = <Widget>[];

      final double deltaExtent = settings.maxExtent - settings.minExtent;

      // 0.0 -> Expanded
      // 1.0 -> Collapsed to toolbar
      final double t =
          (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
              .clamp(0.0, 1.0);

      // background
      if (widget.background != null) {
        final double fadeStart =
            math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
        const double fadeEnd = 1.0;
        assert(fadeStart <= fadeEnd);
        final double opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
        if (opacity > 0.0) {
          double height = settings.maxExtent;

          // StretchMode.zoomBackground
          if (widget.stretchModes.contains(StretchMode.zoomBackground) &&
              constraints.maxHeight > height) {
            height = constraints.maxHeight;
          }

          children.add(Positioned(
            top: _getCollapsePadding(t, settings),
            left: 0.0,
            right: 0.0,
            height: height,
            child: Opacity(
              opacity: opacity,
              child: widget.background,
            ),
          ));

          // StretchMode.blurBackground
          if (widget.stretchModes.contains(StretchMode.blurBackground) &&
              constraints.maxHeight > settings.maxExtent) {
            final double blurAmount =
                (constraints.maxHeight - settings.maxExtent) / 10;
            children.add(Positioned.fill(
                child: BackdropFilter(
                    child: Container(
                      color: Colors.transparent,
                    ),
                    filter: ui.ImageFilter.blur(
                      sigmaX: blurAmount,
                      sigmaY: blurAmount,
                    ))));
          }
        }
      }

      // title
      if (widget.title != null) {
        final ThemeData theme = Theme.of(context);

        Widget? title;
        switch (theme.platform) {
          case TargetPlatform.iOS:
            title = widget.title;
            break;
          default:
            title = Semantics(
              namesRoute: true,
              child: widget.title,
            );
        }

        // StretchMode.fadeTitle
        if (widget.stretchModes.contains(StretchMode.fadeTitle) &&
            constraints.maxHeight > settings.maxExtent) {
          final double stretchOpacity = 1 -
              ((constraints.maxHeight - settings.maxExtent) / 100)
                  .clamp(0.0, 1.0);
          title = Opacity(
            opacity: stretchOpacity,
            child: title,
          );
        }

        final double opacity = settings.toolbarOpacity;
        if (opacity > 0.0) {
          TextStyle titleStyle = theme.primaryTextTheme.headline6!;
          titleStyle = titleStyle.copyWith(
              color: titleStyle.color!.withOpacity(opacity));
          final bool effectiveCenterTitle = _getEffectiveCenterTitle(theme)!;
          final EdgeInsetsGeometry padding = widget.titlePadding ??
              EdgeInsetsDirectional.only(
                start: effectiveCenterTitle ? 0.0 : 72.0,
                bottom: 16.0,
              );
          final double scaleValue =
              Tween<double>(begin: 1.5, end: 1.0).transform(t);

          final double scaleBottomValue =
              Tween<double>(begin: 1.0, end: 0).transform(t);

          final double opacityValue =
              Tween<double>(begin: 1, end: 0.0).transform(t);

          final Matrix4 scaleTransform = Matrix4.identity()
            ..scale(scaleValue, scaleValue, 1.0);

          final Alignment titleAlignment =
              _getTitleAlignment(effectiveCenterTitle)!;

          children.add(
            Container(
              padding: padding,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Transform(
                        alignment: titleAlignment,
                        transform: scaleTransform,
                        child: Align(
                          alignment: titleAlignment,
                          child: DefaultTextStyle(
                            style: titleStyle,
                            child: title!,
                          ),
                        ),
                      ),
                      Spacer(),
                      Opacity(
                        opacity: opacityValue,
                        child: new Container(
                          width: 60,
                          height: 60,
                          margin: EdgeInsets.only(right: 20, bottom: 20),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  widget.image!,
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                        ),
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: opacityValue,
                    child: Container(
                      height: 80 * scaleBottomValue,
                      child: Column(
                        children: <Widget>[
                          new Expanded(
                            child: new Row(
                              children:
                                  widget.bottom ?? Container() as List<Widget>,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      return ClipRect(child: Stack(children: children));
    });
  }

  renderItem() {
    return Expanded(
      child: new Container(
        alignment: Alignment.centerLeft,
        child: Center(
          child: new Text(
            "FFFF",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
