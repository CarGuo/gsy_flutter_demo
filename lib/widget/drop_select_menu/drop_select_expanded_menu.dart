import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_object.dart';
import 'package:gsy_flutter_demo/widget/expand/expand_widget.dart';

import 'drop_select_controller.dart';
import 'drop_select_widget.dart';

const double kDropExpendedSelectMenuItemHeight = 45.0;

typedef Widget MenuItemExpandedBuilder<T extends DropSelectObject>(
    BuildContext context, T data, bool selected);

class DropSelectExpandedListMenu<T extends DropSelectObject>
    extends DropSelectWidget {
  final List<T> data;
  final int selectedIndex;
  final double itemExtent;
  final MenuItemExpandedBuilder itemBuilder;

  DropSelectExpandedListMenu(
      {this.data,
      this.selectedIndex,
      this.itemBuilder,
      this.itemExtent: kDropExpendedSelectMenuItemHeight});

  @override
  DropSelectState<DropSelectWidget> createState() {
    return new _MenuListExpandedState<T>();
  }
}

class _MenuListExpandedState<T extends DropSelectObject>
    extends DropSelectState<DropSelectExpandedListMenu<T>> {
  int _lastSelectedIndex;

  @override
  void initState() {
    _lastSelectedIndex = widget.selectedIndex;
    super.initState();
  }

  renderGrid(count, data, index) {
    return new Container(
      height: widget.itemExtent * count,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: List.generate(count, (i) {
          return widget.itemBuilder(
              context, data.children[i], i == _lastSelectedIndex);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new ListView.builder(
        itemBuilder: (context, index) {
          return ExpandablePanel(
            height: widget.itemExtent,
            initialExpanded: false,
            header: new Container(
              height: widget.itemExtent,
              child: new Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data[index].title,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            expanded: renderGrid(
                widget.data[index].children.length, widget.data[index], index),
            tapHeaderToExpand: true,
            hasIcon: true,
          );
        },
        itemCount: widget.data.length,
      ),
    );
  }

  @override
  void onEvent(DropSelectEvent event) {
    switch (event) {
      case DropSelectEvent.SELECT:
      case DropSelectEvent.HIDE:
        {}
        break;
      case DropSelectEvent.ACTIVE:
        {}
        break;
    }
  }
}
