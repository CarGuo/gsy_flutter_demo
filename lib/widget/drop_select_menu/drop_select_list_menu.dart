import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_object.dart';

import 'drop_select_controller.dart';
import 'drop_select_widget.dart';

typedef MenuItemBuilder<T extends DropSelectObject> = Widget Function(
    BuildContext context, T data);

const double kDropSelectMenuItemHeight = 45.0;

class DropSelectListMenu<T extends DropSelectObject> extends DropSelectWidget {
  final List<T>? data;
  final MenuItemBuilder? itemBuilder;
  final bool singleSelected;
  final double itemExtent;

  const DropSelectListMenu(
      {super.key, this.data,
      this.singleSelected = false,
      this.itemBuilder,
      this.itemExtent = kDropSelectMenuItemHeight});

  @override
  DropSelectState<DropSelectWidget> createState() {
    return _MenuListState<T>();
  }
}

class _MenuListState<T extends DropSelectObject>
    extends DropSelectState<DropSelectListMenu<T>> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildItem(BuildContext context, int index) {
    final List<T> list = widget.data!;

    final T data = list[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.itemBuilder!(context, data),
      onTap: () {
        if (widget.singleSelected) {
          for (var item in widget.data!) {
            item.selected = false;
          }
        }
        if(data.selectedCleanOther) {
          for (var item in widget.data!) {
            item.selected = false;
          }
        }
        setState(() {
          data.selected = !data.selected;
        });
        controller?.select(data, index: index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemExtent: widget.itemExtent,
      itemBuilder: buildItem,
      itemCount: widget.data!.length,
    );
  }

  @override
  void onEvent(DropSelectEvent? event) {
    switch (event) {
      case DropSelectEvent.SELECT:
      case DropSelectEvent.HIDE:
        {}
        break;
      case DropSelectEvent.ACTIVE:
      default:
        {}
        break;
    }
  }
}
