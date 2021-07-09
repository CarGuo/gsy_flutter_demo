import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_widget.dart';

import 'drop_select_controller.dart';

typedef void DropdownMenuHeadTapCallback(int index);

typedef String ShowTitle(dynamic data, int? index);

class DropSelectHeader extends DropSelectWidget {
  final List titles;
  final int? activeIndex;
  final DropdownMenuHeadTapCallback? onTap;

  final double height;

  final ShowTitle? showTitle;

  DropSelectHeader({
    required this.titles,
    this.activeIndex,
    DropSelectController? controller,
    this.onTap,
    Key? key,
    this.height: 46.0,
    this.showTitle,
  })  : assert(titles.length > 0),
        super(key: key, controller: controller);

  @override
  DropSelectState<DropSelectWidget> createState() {
    return new _DropSelectHeaderState();
  }
}

class _DropSelectHeaderState extends DropSelectState<DropSelectHeader> {
  Widget buildItem(
      BuildContext context, dynamic title, bool selected, int index) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color unselectedColor = Theme.of(context).unselectedWidgetColor;
    final ShowTitle showTitle = widget.showTitle!;

    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          child: new DecoratedBox(
              decoration: new BoxDecoration(
                  border: new Border(left: Divider.createBorderSide(context))),
              child: new Center(
                  child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                    new Text(
                      showTitle(title, index),
                      style: new TextStyle(
                        color: selected ? primaryColor : unselectedColor,
                      ),
                    ),
                    new Icon(
                      selected ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: selected ? primaryColor : unselectedColor,
                    )
                  ])))),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap?.call(index);
          return;
        }
        if (_activeIndex == index) {
          controller?.hide();
          setState(() {
            _activeIndex = null;
          });
        } else {
          controller?.show(index);
        }
      },
    );
  }

  int? _activeIndex;
  List? _titles;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    final int? activeIndex = _activeIndex;
    final List? titles = _titles;
    final double height = widget.height;

    for (int i = 0, c = widget.titles.length; i < c; ++i) {
      list.add(buildItem(context, titles![i], i == activeIndex, i));
    }

    list = list.map((Widget widget) {
      return new Expanded(
        child: widget,
      );
    }).toList();

    final Decoration decoration = new BoxDecoration(
      border: new Border(
        bottom: Divider.createBorderSide(context),
      ),
    );

    return new DecoratedBox(
      decoration: decoration,
      child: new SizedBox(
          child: new Row(
            children: list,
          ),
          height: height),
    );
  }

  @override
  void initState() {
    _titles = widget.titles;
    super.initState();
  }

  @override
  void onEvent(DropSelectEvent? event) {
    switch (event) {
      case DropSelectEvent.SELECT:
        {
          if (_activeIndex == null) return;

          setState(() {
            _activeIndex = null;
            String label = widget.showTitle!(controller!.data, _activeIndex);
            _titles![controller!.menuIndex!] = label;
          });
        }
        break;
      case DropSelectEvent.HIDE:
        {
          if (_activeIndex == null) return;
          setState(() {
            _activeIndex = null;
          });
        }
        break;
      case DropSelectEvent.ACTIVE:
      default:
        {
          if (_activeIndex == controller!.menuIndex) return;
          setState(() {
            _activeIndex = controller!.menuIndex;
          });
        }
        break;
    }
  }
}
