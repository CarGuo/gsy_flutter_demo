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

  final List<ExpandableController> _controllers =
      new List<ExpandableController>();

  @override
  void initState() {
    super.initState();

    _controllers.clear();

    ///配置多个 ExpandableController 控制器
    List.generate(widget.data.length, (index) {
      _controllers.add(ExpandableController(false));
    });
  }

  Widget renderButton() {
    return new Container(
      height: 50,
      child: new Row(
        children: <Widget>[
          new Expanded(
              child: new FlatButton(
                  onPressed: () {
                    controller.hide();
                  },
                  child: new Text("重置"))),
          new Expanded(
              child: new FlatButton(
                  onPressed: () {
                    controller.select([]);
                  },
                  child: new Text("确定"))),
        ],
      ),
    );
  }

  renderGrid(count, data, index) {
    return new Container(
      height: widget.itemExtent * count,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: List.generate(count, (i) {
          var child = data.children[i];
          if (child.selectedCleanOther) {
            cleanOtherList["$i"] = i;
          }
          return new InkWell(
            onTap: () {
              if (widget.singleSelected) {
                data.forEach((item) {
                  item.selected = false;
                });
              }
              if (child.selectedCleanOther) {
                data.children.forEach((item) {
                  item.selected = false;
                });
              }
              if (!child.selectedCleanOther && cleanOtherList.length > 0) {
                cleanOtherList.forEach((key, value) {
                  if (value != i) {
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
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new ListView.builder(
              itemBuilder: (context, index) {
                return ExpandablePanel(
                  height: widget.itemExtent,
                  initialExpanded: _controllers[index].expanded,
                  controller: _controllers[index],
                  header: new Container(
                    height: widget.itemExtent,
                    padding: EdgeInsets.only(left: 10),
                    child: new Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.data[index].title,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                  expanded: renderGrid(widget.data[index].children.length,
                      widget.data[index], index),
                  tapHeaderToExpand: true,
                  hasIcon: true,
                );
              },
              itemCount: widget.data.length,
            ),
          ),
          renderButton(),
        ],
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
