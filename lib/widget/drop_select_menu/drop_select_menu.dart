import 'dart:async';
import 'dart:ui' as ui show ImageFilter;
import 'package:flutter/material.dart';

import 'drop_rect_tween.dart';
import 'drop_select_controller.dart';
import 'drop_select_widget.dart';

enum DropSelectMenuSwitchStyle {
  directHideAnimationShow,
  directHideDirectShow,
  animationHideAnimationShow,
  animationShowUntilAnimationHideComplete,
}

class DropSelectMenu extends DropSelectWidget {

  final List<DropSelectMenuBuilder> menus;

  final Duration hideDuration;
  final Duration showDuration;
  final Curve showCurve;
  final Curve hideCurve;

  final double? blur;

  final VoidCallback? onHide;

  final DropSelectMenuSwitchStyle switchStyle;

  final double? maxMenuHeight;

  DropSelectMenu(
      {required this.menus,
        DropSelectController? controller,
      Duration? hideDuration,
      Duration? showDuration,
      this.onHide,
      this.blur,
      Key? key,
      this.maxMenuHeight,
      Curve? hideCurve,
      this.switchStyle: DropSelectMenuSwitchStyle
          .animationShowUntilAnimationHideComplete,
      Curve? showCurve})
      : hideDuration = hideDuration ?? new Duration(milliseconds: 150),
        showDuration = showDuration ?? new Duration(milliseconds: 300),
        showCurve = showCurve ?? Curves.fastOutSlowIn,
        hideCurve = hideCurve ?? Curves.fastOutSlowIn,
        super(key: key, controller: controller);

  @override
  DropSelectState<DropSelectMenu> createState() {
    return new _DropSelectMenuState();
  }
}

class _DropSelectAnimation {
  late Animation<Rect> rect;
  late AnimationController animationController;
  late DropRectTween position;

  _DropSelectAnimation(TickerProvider provider) {
    animationController = new AnimationController(vsync: provider);
  }

  set height(double value) {
    position = new DropRectTween(
      begin: new Rect.fromLTRB(0.0, -value, 0.0, 0.0),
      end: new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    );

    rect = position.animate(animationController);
  }

  set value(double value) {
    animationController.value = value;
  }

  void dispose() {
    animationController.dispose();
  }

  TickerFuture animateTo(double value, {Duration? duration, required Curve curve}) {
    return animationController.animateTo(value,
        duration: duration, curve: curve);
  }
}

class SizeClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return new Rect.fromLTWH(0.0, 0.0, size.width, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return false;
  }
}

class _DropSelectMenuState extends DropSelectState<DropSelectMenu>
    with TickerProviderStateMixin {
  late List<_DropSelectAnimation> _dropSelectAnimations;
  late bool _show;
  late List<int> _showing;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _showing = [];
    _dropSelectAnimations = [];
    for (int i = 0, c = widget.menus.length; i < c; ++i) {
      _dropSelectAnimations.add(new _DropSelectAnimation(this));
    }

    _updateHeights();

    _show = false;

    _fadeController = new AnimationController(vsync: this);
    _fadeAnimation = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    super.initState();
  }

  @override
  void dispose() {
    for (int i = 0, c = _dropSelectAnimations.length; i < c; ++i) {
      _dropSelectAnimations[i].dispose();
    }

    super.dispose();
  }

  void _updateHeights() {
    for (int i = 0, c = widget.menus.length; i < c; ++i) {
      _dropSelectAnimations[i].height =
          _ensureHeight(_getHeight(widget.menus[i]))!;
    }
  }

  @override
  void didUpdateWidget(DropSelectMenu oldWidget) {
    //update state
    _updateHeights();
    super.didUpdateWidget(oldWidget);
  }

  Widget createMenu(BuildContext context, DropSelectMenuBuilder menu, int i) {
    DropSelectMenuBuilder builder = menu;

    return new ClipRect(
      clipper: new SizeClipper(),
      child: new SizedBox(
          height: _ensureHeight(builder.height),
          child: _showing.contains(i) ? builder.builder(context) : null),
    );
  }

  Widget _buildBackground(BuildContext context) {
    Widget container = new Container(
      color: Colors.black26,
    );

    container = new BackdropFilter(
        filter: new ui.ImageFilter.blur(
          sigmaY: widget.blur ?? 0,
          sigmaX: widget.blur ?? 0,
        ),
        child: container);

    return container;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    print("build ${new DateTime.now()}");

    if (_show) {
      list.add(
        new FadeTransition(
          opacity: _fadeAnimation,
          child: new GestureDetector(
              onTap: onHide, child: _buildBackground(context)),
        ),
      );
    }

    for (int i = 0, c = widget.menus.length; i < c; ++i) {
      list.add(new RelativePositionedTransition(
          rect: _dropSelectAnimations[i].rect,
          size: new Size(0.0, 0.0),
          child: new Align(
              alignment: Alignment.topCenter,
              child: new Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: createMenu(context, widget.menus[i], i),
              ))));
    }

    //WidgetsBinding;
    //context.findRenderObject();
    return new Stack(
      fit: StackFit.expand,
      children: list,
    );
  }

  TickerFuture onHide({bool dispatch: true}) {
    if (_activeIndex != null) {
      int index = _activeIndex!;
      _activeIndex = null;
      TickerFuture future = _hide(index);
      if (dispatch) {
        if (controller != null) {
          controller!.hide();
        }

        //if (widget.onHide != null) widget.onHide();
      }

      _fadeController.animateTo(0.0,
          duration: widget.hideDuration, curve: widget.hideCurve);

      future.whenComplete(() {
        setState(() {
          _show = false;
        });
      });
      return future;
    }

    return new TickerFuture.complete();
  }

  TickerFuture _hide(int index) {
    TickerFuture future = _dropSelectAnimations[index]
        .animateTo(0.0, duration: widget.hideDuration, curve: widget.hideCurve);
    return future;
  }

  int? _activeIndex;

  Future<void> onShow(int index) {
    //哪一个是要展示的

    assert(index >= 0 && index < _dropSelectAnimations.length);
    if (!_showing.contains(index)) {
      _showing.add(index);
    }

    if (_activeIndex != null) {
      if (_activeIndex == index) {
        return onHide();
      }

      switch (widget.switchStyle) {
        case DropSelectMenuSwitchStyle.directHideAnimationShow:
          {
            _dropSelectAnimations[_activeIndex!].value = 0.0;
            _dropSelectAnimations[index].value = 1.0;
            _activeIndex = index;

            setState(() {
              _show = true;
            });

            return new Future.value(null);
          }
        case DropSelectMenuSwitchStyle.animationHideAnimationShow:
          {
            _hide(_activeIndex!);
          }
          break;
        case DropSelectMenuSwitchStyle.directHideDirectShow:
          {
            _dropSelectAnimations[_activeIndex!].value = 0.0;
          }
          break;
        case DropSelectMenuSwitchStyle
            .animationShowUntilAnimationHideComplete:
          {
            return _hide(_activeIndex!).whenComplete(() {
              return _handleShow(index, true);
            });
          }
      }
    }

    return _handleShow(index, true);
  }

  TickerFuture _handleShow(int index, bool animation) {
    _activeIndex = index;

    setState(() {
      _show = true;
    });

    _fadeController.animateTo(1.0,
        duration: widget.showDuration, curve: widget.showCurve);

    return _dropSelectAnimations[index]
        .animateTo(1.0, duration: widget.showDuration, curve: widget.showCurve);
  }

  double? _getHeight(dynamic menu) {
    DropSelectMenuBuilder builder = menu as DropSelectMenuBuilder;

    return builder.height;
  }

  double? _ensureHeight(double? height) {
    final double? maxMenuHeight = widget.maxMenuHeight;
    assert(height != null || maxMenuHeight != null,
        "DropSelectMenu.maxMenuHeight and DropSelectMenuBuilder.height must not both null");
    if (maxMenuHeight != null) {
      if (height == null) return maxMenuHeight;
      return height > maxMenuHeight ? maxMenuHeight : height;
    }
    return height;
  }

  @override
  void onEvent(DropSelectEvent? event) {
    switch (event) {
      case DropSelectEvent.SELECT:
      case DropSelectEvent.HIDE:
        {
          onHide(dispatch: false);
        }
        break;
      case DropSelectEvent.ACTIVE:
      default:
        {
          onShow(controller!.menuIndex!);
        }
        break;
    }
  }
}
