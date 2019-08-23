import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'drop_select_controller.dart';
import 'drop_select_widget.dart';


typedef Widget MenuItemBuilder<T>(BuildContext context, T data, bool selected);
typedef void MenuItemOnTap<T>(T data, int index);
typedef List<E> GetSubData<T, E>(T data);

const double kDropSelectMenuItemHeight = 45.0;

class DropSelectListMenu<T> extends DropSelectWidget {
  final List<T> data;
  final int selectedIndex;
  final MenuItemBuilder itemBuilder;
  final double itemExtent;

  DropSelectListMenu(
      {this.data,
      this.selectedIndex,
      this.itemBuilder,
      this.itemExtent: kDropSelectMenuItemHeight});

  @override
  DropSelectState<DropSelectWidget> createState() {
    return new _MenuListState<T>();
  }
}

class _MenuListState<T> extends DropSelectState<DropSelectListMenu<T>> {
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

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemExtent: widget.itemExtent,
      itemBuilder: buildItem,
      itemCount: widget.data.length,
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

