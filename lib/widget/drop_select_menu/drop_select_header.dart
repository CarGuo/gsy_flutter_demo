import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_widget.dart';

import 'drop_select_controller.dart';

typedef DropdownMenuHeadTapCallback = void Function(int index);

typedef ShowTitle = String Function(dynamic data, int? index);

class DropSelectHeader extends DropSelectWidget {
  final List titles;
  final int? activeIndex;
  final DropdownMenuHeadTapCallback? onTap;

  final double height;

  final ShowTitle? showTitle;

  DropSelectHeader({
    required this.titles,
    this.activeIndex,
    super.controller,
    this.onTap,
    super.key,
    this.height = 46.0,
    this.showTitle,
  })  : assert(titles.isNotEmpty);

  @override
  DropSelectState<DropSelectWidget> createState() {
    return _DropSelectHeaderState();
  }
}

class _DropSelectHeaderState extends DropSelectState<DropSelectHeader> {
  Widget buildItem(
      BuildContext context, dynamic title, bool selected, int index) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color unselectedColor = Theme.of(context).unselectedWidgetColor;
    final ShowTitle showTitle = widget.showTitle!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          child: DecoratedBox(
              decoration: BoxDecoration(
                  border: Border(left: Divider.createBorderSide(context))),
              child: Center(
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                    Text(
                      showTitle(title, index),
                      style: TextStyle(
                        color: selected ? primaryColor : unselectedColor,
                      ),
                    ),
                    Icon(
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
      return Expanded(
        child: widget,
      );
    }).toList();

    final Decoration decoration = BoxDecoration(
      border: Border(
        bottom: Divider.createBorderSide(context),
      ),
    );

    return DecoratedBox(
      decoration: decoration,
      child: SizedBox(
          height: height,
          child: Row(
            children: list,
          )),
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
