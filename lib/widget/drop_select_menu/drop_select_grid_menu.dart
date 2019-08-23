import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gsy_flutter_demo/widget/expand/expand_widget.dart';

import 'drop_select_const.dart';
import 'drop_select_controller.dart';
import 'drop_select_widget.dart';

const double kDropExpendedSelectMenuItemHeight = 45.0;

typedef Widget MenuItemGridBuilder<T>(
    BuildContext context, T data, bool selected);

class DropSelectGridListMenu<T> extends DropSelectWidget {
  final List<T> data;
  final int selectedIndex;
  final double itemExtent;
  final MenuItemGridBuilder itemBuilder;

  DropSelectGridListMenu(
      {this.data,
      this.selectedIndex,
      this.itemBuilder,
      this.itemExtent: kDropExpendedSelectMenuItemHeight});

  @override
  DropSelectState<DropSelectWidget> createState() {
    return new _MenuListGridState<T>();
  }
}

class _MenuListGridState<T> extends DropSelectState<DropSelectGridListMenu<T>> {
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
          return new Container(
            child: new Column(
              children: <Widget>[
                new Container(
                  child: new Text((widget.data[index] as Map)[LIST_TITLE_KEY]),
                  alignment: Alignment.centerLeft,
                ),
                renderGrid((widget.data[index] as Map)[SUB_LIST_KEY].length,
                    widget.data[index], index)
              ],
            ),
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
