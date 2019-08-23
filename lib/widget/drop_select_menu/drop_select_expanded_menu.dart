import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gsy_flutter_demo/widget/expand/expand_widget.dart';

import 'drop_select_const.dart';
import 'drop_select_controller.dart';
import 'drop_select_widget.dart';

const double kDropExpendedSelectMenuItemHeight = 45.0;

typedef Widget MenuItemExpandedBuilder<T>(
    BuildContext context, T data, bool selected);

class DropSelectExpandedListMenu<T> extends DropSelectWidget {
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

class _MenuListExpandedState<T>
    extends DropSelectState<DropSelectExpandedListMenu<T>> {
  int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.selectedIndex;
    super.initState();
  }

  Widget buildItem(BuildContext context, int index) {
    final List<T> list = widget.data;

    final T data = list[index];
    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.itemBuilder(context, data, index == _selectedIndex),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        assert(controller != null);
        controller.select(data, index: index);
      },
    );
  }

  renderGrid(count, data, index) {
    return new Container(
      height: widget.itemExtent * count,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: List.generate(count, (index) {
          return widget.itemBuilder(
              context, data[SUB_LIST_KEY][index], index == _selectedIndex);
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
                  (widget.data[index] as Map)["title"],
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
            expanded: renderGrid(
                (widget.data[index] as Map)[SUB_LIST_KEY].length,
                widget.data[index],
                index),
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
