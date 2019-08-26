import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gsy_flutter_demo/widget/drop_select_menu/drop_select_object.dart';
import 'package:gsy_flutter_demo/widget/expand/expand_widget.dart';

import 'drop_select_controller.dart';
import 'drop_select_widget.dart';

const double kDropExpendedSelectMenuItemHeight = 45.0;

typedef Widget MenuItemExpandedBuilder<T extends DropSelectObject>(
    BuildContext context, T data);

class DropSelectExpandedListMenu<T extends DropSelectObject>
    extends DropSelectWidget {
  final List<T> data;
  final double itemExtent;
  final bool singleSelected;
  final MenuItemExpandedBuilder itemBuilder;

  DropSelectExpandedListMenu(
      {this.data,
      this.itemBuilder,
      this.singleSelected = false,
      this.itemExtent: kDropExpendedSelectMenuItemHeight});

  @override
  DropSelectState<DropSelectWidget> createState() {
    return new _MenuListExpandedState<T>();
  }
}

class _MenuListExpandedState<T extends DropSelectObject>
    extends DropSelectState<DropSelectExpandedListMenu<T>> {

  Map<String, int> cleanOtherList = new HashMap();

  bool _expanded = false;

  final ExpandableController _controller = new ExpandableController();

  @override
  void initState() {
    super.initState();
    _controller.addListener((){
      _expanded = _controller.expanded;
    });
  }

  renderGrid(count, data, index) {
    return new Container(
      height: widget.itemExtent * count,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: List.generate(count, (i) {
          var child =  data.children[i];
          if(child.selectedCleanOther) {
            cleanOtherList["$i"] = i;
          }
          return new InkWell(
            onTap: () {
              if (widget.singleSelected) {
                data.forEach((item) {
                  item.selected = false;
                });
              }
              if(child.selectedCleanOther) {
                data.children.forEach((item) {
                  item.selected = false;
                });
              }
              if(!child.selectedCleanOther && cleanOtherList.length > 0) {
                cleanOtherList.forEach((key, value) {
                  if(value != i) {
                    data.children[value].selected = false;
                  }
                });
              }
              setState(() {
                child.selected = !child.selected;
              });
            },
            child: widget.itemBuilder(context, child),
          );
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
            initialExpanded: _expanded,
            controller: _controller,
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
