import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'drop_select_controller.dart';
import 'drop_select_object.dart';
import 'drop_select_widget.dart';

const double kDropExpendedSelectMenuItemHeight = 45.0;

typedef Widget MenuItemGridBuilder<T extends DropSelectObject>(
    BuildContext context, T data);

class DropSelectGridListMenu<T extends DropSelectObject>
    extends DropSelectWidget {
  final List<T> data;
  final double itemExtent;
  final bool singleSelected;
  final MenuItemGridBuilder itemBuilder;

  DropSelectGridListMenu(
      {this.data,
      this.itemBuilder,
      this.singleSelected = false,
      this.itemExtent: kDropExpendedSelectMenuItemHeight});

  @override
  DropSelectState<DropSelectWidget> createState() {
    return new _MenuListGridState<T>();
  }
}

class _MenuListGridState<T extends DropSelectObject>
    extends DropSelectState<DropSelectGridListMenu<T>> {
  Map<String, int> cleanOtherList = new HashMap();

  ///clone列表，深度拷贝，仅在确定选择后才复制到 widget.data
  final List<T> _cloneList = List();

  @override
  void initState() {
    super.initState();

    ///初始化 _cloneList
    cloneDataList(widget.data, _cloneList);
  }

  ///绘制 grid 列表嵌套
  renderGrid(count, data, index) {
    return new Container(
      height: widget.itemExtent * count,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: List.generate(count, (i) {
          var child = data.children[i];

          ///记录冲突选择的Map，用户后续重置
          if (child.selectedCleanOther) {
            cleanOtherList["$i"] = i;
          }

          return new InkWell(
            onTap: () {

              ///是否单选
              if (widget.singleSelected) {
                data.children.forEach((item) {
                  item.selected = false;
                });
              }
              ///是否为冲突选择item
              if (child.selectedCleanOther) {
                data.children.forEach((item) {
                  item.selected = false;
                });
              }

              ///如果存在冲突选择，需要处理
              if (!child.selectedCleanOther && cleanOtherList.length > 0) {
                cleanOtherList.forEach((key, value) {
                  if (value != i) {
                    data.children[value].selected = false;
                  }
                });
              }

              ///选中
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

  ///绘制底部按键
  Widget renderButton() {
    return new Container(
      height: 50,
      child: new Row(
        children: <Widget>[
          new Expanded(
              child: new FlatButton(
                  onPressed: () {
                    setState(() {
                      resetList(widget.data);
                    });
                    controller.hide();
                  },
                  child: new Text("重置"))),
          new Expanded(
              child: new FlatButton(
                  onPressed: () {
                    controller.select(_cloneList);
                  },
                  child: new Text("确定"))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(children: <Widget>[
        new Expanded(
          child: new ListView.builder(
            itemBuilder: (context, index) {
              return new Container(
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Text(_cloneList[index].title),
                      alignment: Alignment.centerLeft,
                    ),
                    renderGrid(_cloneList[index].children.length,
                        _cloneList[index], index)
                  ],
                ),
              );
            },
            itemCount: _cloneList.length,
          ),
        ),
        renderButton(),
      ]),
    );
  }

  @override
  void onEvent(DropSelectEvent event) {
    switch (event) {
      case DropSelectEvent.SELECT:
        {
          ///选择时才使用目标
          cloneDataList(_cloneList, widget.data);
          break;
        }
      case DropSelectEvent.HIDE:
        {}
        break;
      case DropSelectEvent.ACTIVE:
        {
          ///激活时备份列表
          cloneDataList(widget.data, _cloneList);
        }
        break;
    }
  }
}
