import 'dart:async';
import 'dart:ui' as ui show ImageFilter;
import 'package:flutter/foundation.dart';
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

  const DropSelectMenu(
      {required this.menus,
        super.controller,
      Duration? hideDuration,
      Duration? showDuration,
      this.onHide,
      this.blur,
      super.key,
      this.maxMenuHeight,
      Curve? hideCurve,
      this.switchStyle = DropSelectMenuSwitchStyle
          .animationShowUntilAnimationHideComplete,
      Curve? showCurve})
      : hideDuration = hideDuration ?? const Duration(milliseconds: 150),
        showDuration = showDuration ?? const Duration(milliseconds: 300),
        showCurve = showCurve ?? Curves.fastOutSlowIn,
        hideCurve = hideCurve ?? Curves.fastOutSlowIn;

  @override
  DropSelectState<DropSelectMenu> createState() {
    return _DropSelectMenuState();
  }
}

class _DropSelectAnimation {
  late Animation<Rect> rect;
  late AnimationController animationController;
  late DropRectTween position;

  _DropSelectAnimation(TickerProvider provider) {
    animationController = AnimationController(vsync: provider);
  }

  set height(double value) {
    position = DropRectTween(
      begin: Rect.fromLTRB(0.0, -value, 0.0, 0.0),
      end: const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0),
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
    return Rect.fromLTWH(0.0, 0.0, size.width, size.height);
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
      _dropSelectAnimations.add(_DropSelectAnimation(this));
    }

    _updateHeights();

    _show = false;

    _fadeController = AnimationController(vsync: this);
    _fadeAnimation = Tween(
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

    return ClipRect(
      clipper: SizeClipper(),
      child: SizedBox(
          height: _ensureHeight(builder.height),
          child: _showing.contains(i) ? builder.builder(context) : null),
    );
  }

  Widget _buildBackground(BuildContext context) {
    Widget container = Container(
      color: Colors.black26,
    );

    container = BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaY: widget.blur ?? 0,
          sigmaX: widget.blur ?? 0,
        ),
        child: container);

    return container;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    if (kDebugMode) {
      print("build ${DateTime.now()}");
    }

    if (_show) {
      list.add(
        FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
              onTap: onHide, child: _buildBackground(context)),
        ),
      );
    }

    for (int i = 0, c = widget.menus.length; i < c; ++i) {
      list.add(RelativePositionedTransition(
          rect: _dropSelectAnimations[i].rect,
          size: const Size(0.0, 0.0),
          child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: createMenu(context, widget.menus[i], i),
              ))));
    }

    //WidgetsBinding;
    //context.findRenderObject();
    return Stack(
      fit: StackFit.expand,
      children: list,
    );
  }

  TickerFuture onHide({bool dispatch = true}) {
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

    return TickerFuture.complete();
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

            return Future.value(null);
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
