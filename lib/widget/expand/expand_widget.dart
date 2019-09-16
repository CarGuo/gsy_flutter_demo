import 'package:flutter/material.dart';


class ExpandableNotifier extends StatefulWidget {
  final ExpandableController controller;
  final bool initialExpanded;
  final Duration animationDuration;
  final Widget child;

  ExpandableNotifier(
      {Key key,
        this.controller,
        this.initialExpanded,
        this.animationDuration,
        @required this.child})
      : assert(!(controller != null && animationDuration != null)),
        assert(!(controller != null && initialExpanded != null)),
        super(key: key);

  @override
  _ExpandableNotifierState createState() => _ExpandableNotifierState();
}

class _ExpandableNotifierState extends State<ExpandableNotifier> {
  ExpandableController controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      controller = ExpandableController(
          initialExpanded: widget.initialExpanded ?? false,
          animationDuration: widget.animationDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ExpandableInheritedNotifier(
        controller: controller ?? widget.controller, child: widget.child);
  }
}

class _ExpandableInheritedNotifier
    extends InheritedNotifier<ExpandableController> {
  _ExpandableInheritedNotifier(
      {@required ExpandableController controller, @required Widget child})
      : super(notifier: controller, child: child);
}

class ExpandableController extends ValueNotifier<bool> {
  bool get expanded => value;
  final Duration animationDuration;

  ExpandableController({bool initialExpanded, Duration animationDuration})
      : this.animationDuration =
      animationDuration ?? const Duration(milliseconds: 300),
        super(initialExpanded ?? false);

  set expanded(bool exp) {
    value = exp;
  }

  void toggle() {
    expanded = !expanded;
  }

  static ExpandableController of(BuildContext context,
      {bool rebuildOnChange = true}) {
    final notifier = rebuildOnChange
        ? context.inheritFromWidgetOfExactType(_ExpandableInheritedNotifier)
        : context.ancestorWidgetOfExactType(_ExpandableInheritedNotifier);
    return (notifier as _ExpandableInheritedNotifier)?.notifier;
  }
}

/// Shows either the expanded or the collapsed child depending on the state.
/// The state is determined by an instance of [ExpandableController] provided by [ScopedModel]
class Expandable extends StatelessWidget {
  // Whe widget to show when collapsed
  final Widget collapsed;

  // The widget to show when expanded
  final Widget expanded;
  final Duration animationDuration;
  final double collapsedFadeStart;
  final double collapsedFadeEnd;
  final double expandedFadeStart;
  final double expandedFadeEnd;
  final Curve fadeCurve;
  final Curve sizeCurve;

  Expandable(
      {this.collapsed,
      this.expanded,
      this.collapsedFadeStart = 0,
      this.collapsedFadeEnd = 1,
      this.expandedFadeStart = 0,
      this.expandedFadeEnd = 1,
      this.fadeCurve = Curves.linear,
      this.sizeCurve = Curves.fastOutSlowIn,
      this.animationDuration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) {
    var controller = ExpandableController.of(context);

    return AnimatedCrossFade(
      firstChild: collapsed ?? Container(),
      secondChild: expanded ?? Container(),
      firstCurve:
          Interval(collapsedFadeStart, collapsedFadeEnd, curve: fadeCurve),
      secondCurve:
          Interval(expandedFadeStart, expandedFadeEnd, curve: fadeCurve),
      sizeCurve: sizeCurve,
      crossFadeState: controller.expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: animationDuration,
    );
  }
}

typedef Widget ExpandableBuilder(
    BuildContext context, Widget collapsed, Widget expanded);

/// Determines the placement of the expand/collapse icon in [ExpandablePanel]
enum ExpandablePanelIconPlacement {
  /// The icon is on the left of the header
  left,

  /// The icon is on the right of the header
  right,
}

/// A configurable widget for showing user-expandable content with an optional expand button.
class ExpandablePanel extends StatelessWidget {
  /// If specified, the header is always shown, and the expandable part is shown under the header
  final Widget header;

  /// The widget shown in the collspaed state
  final Widget collapsed;

  /// The widget shown in the expanded state
  final Widget expanded;
  final Widget expandableIcon;

  /// If true then the panel is expanded initially
  final bool initialExpanded;

  /// If true, the header can be clicked by the user to expand
  final bool tapHeaderToExpand;

  /// If true, an expand icon is shown on the right
  final bool hasIcon;

  /// Builds an Expandable object
  final ExpandableBuilder builder;

  final double height;

  /// Expand/collspse icon placement
  final ExpandablePanelIconPlacement iconPlacement;
  final ExpandableController controller;

  static Widget defaultExpandableBuilder(
      BuildContext context, Widget collapsed, Widget expanded) {
    return Expandable(
      collapsed: collapsed,
      expanded: expanded,
    );
  }

  ExpandablePanel(
      {this.collapsed,
      this.height = 56.5,
      this.header,
      this.expanded,
      this.initialExpanded = false,
      this.tapHeaderToExpand = true,
      this.expandableIcon,
      this.hasIcon = true,
      this.controller,
      this.iconPlacement = ExpandablePanelIconPlacement.right,
      this.builder = defaultExpandableBuilder});

  @override
  Widget build(BuildContext context) {
    Widget buildHeaderRow(Widget child) {
      if (!hasIcon) {
        return child;
      } else {
        final rowChildren = <Widget>[
          Expanded(
            child: child,
          ),
          new Center(
            child: new Container(
              height: height,
              child: expandableIcon ?? ExpandableIcon(),
            ),
          )
        ];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: iconPlacement == ExpandablePanelIconPlacement.right
              ? rowChildren
              : rowChildren.reversed.toList(),
        );
      }
    }

    Widget buildHeader(Widget child) {
      return tapHeaderToExpand
          ? ExpandableButton(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 45.0), child: child))
          : child;
    }

    Widget buildWithHeader() {
      return Column(
        children: <Widget>[
          buildHeaderRow(buildHeader(header)),
          builder(context, collapsed, expanded)
        ],
      );
    }

    Widget buildWithoutHeader() {
      return buildHeaderRow(builder(context, buildHeader(collapsed), expanded));
    }

    return ExpandableNotifier(
      controller: controller ?? ExpandableController(initialExpanded: initialExpanded),
      child: this.header != null ? buildWithHeader() : buildWithoutHeader(),
    );
  }
}

/// An down/up arrow icon that toggles the state of [ExpandableController] when the user clicks on it.
/// The model is accessed via [ScopedModelDescendant].
class ExpandableIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = ExpandableController.of(context);
    return ExpandIcon(
      isExpanded: controller.expanded,
      onPressed: (exp) {
        controller.toggle();
      },
    );
  }
}

/// Toggles the state of [ExpandableController] when the user clicks on it.
class ExpandableButton extends StatelessWidget {
  final Widget child;

  ExpandableButton({this.child});

  @override
  Widget build(BuildContext context) {
    final controller = ExpandableController.of(context);
    return InkWell(
        onTap: () {
          controller.toggle();
        },
        child: child);
  }
}



/// Ensures that the child is visible on the screen by scrolling the outer viewport
/// when the outer [ExpandableNotifier] delivers a change event.
///
/// See also:
///
/// * [RenderObject.showOnScreen]
class ScrollOnExpand extends StatefulWidget {

  final Widget child;
  final Duration scrollAnimationDuration;
  /// If true then the widget will be scrolled to become visible when expanded
  final bool scrollOnExpand;
  /// If true then the widget will be scrolled to become visible when collapsed
  final bool scrollOnCollapse;

  ScrollOnExpand({
    Key key,
    @required
    this.child,
    this.scrollAnimationDuration = const Duration(milliseconds: 300),
    this.scrollOnExpand = true,
    this.scrollOnCollapse = true,
  }): super(key: key);

  @override
  _ScrollOnExpandState createState() => _ScrollOnExpandState();

}

class _ScrollOnExpandState extends State<ScrollOnExpand> {

  ExpandableController _controller;
  int _isAnimating = 0;
  BuildContext _lastContext;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController.of(context, rebuildOnChange: false);
    _controller.addListener(_expandedStateChanged);
  }

  @override
  void didUpdateWidget(ScrollOnExpand oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newController = ExpandableController.of(context, rebuildOnChange: false);
    if(newController != _controller) {
      _controller.removeListener(_expandedStateChanged);
      _controller = newController;
      _controller.addListener(_expandedStateChanged);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.removeListener(_expandedStateChanged);
  }

  _animationComplete() {
    _isAnimating--;
    if(_isAnimating == 0 && _lastContext != null && mounted) {
      if( (_controller.expanded && widget.scrollOnExpand) ||
          (!_controller.expanded && widget.scrollOnCollapse)) {
        _lastContext?.findRenderObject()?.showOnScreen(duration: widget.scrollAnimationDuration);
      }
    }
  }

  _expandedStateChanged() {
    _isAnimating++;
    Future.delayed(_controller.animationDuration + Duration(milliseconds: 10), _animationComplete);
  }

  @override
  Widget build(BuildContext context) {
    _lastContext = context;
    return widget.child;
  }


}