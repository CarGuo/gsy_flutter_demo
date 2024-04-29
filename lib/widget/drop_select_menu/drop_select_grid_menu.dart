import 'dart:collection';

import 'package:flutter/material.dart';

import 'drop_select_controller.dart';
import 'drop_select_object.dart';
import 'drop_select_widget.dart';

const double kDropExpendedSelectMenuItemHeight = 45.0;

typedef MenuItemGridBuilder<T extends DropSelectObject> = Widget Function(
    BuildContext context, T data);

class DropSelectGridListMenu<T extends DropSelectObject>
    extends DropSelectWidget {
  final List<T>? data;
  final double itemExtent;
  final bool singleSelected;
  final MenuItemGridBuilder? itemBuilder;

  const DropSelectGridListMenu(
      {super.key, this.data,
      this.itemBuilder,
      this.singleSelected = false,
      this.itemExtent = kDropExpendedSelectMenuItemHeight});

  @override
  DropSelectState<DropSelectWidget> createState() {
    return _MenuListGridState<T>();
  }
}

class _MenuListGridState<T extends DropSelectObject>
    extends DropSelectState<DropSelectGridListMenu<T>> {
  Map<String, int> cleanOtherList = HashMap();

  ///clone列表，深度拷贝，仅在确定选择后才复制到 widget.data
  final List<T> _cloneList = [];

  @override
  void initState() {
    super.initState();

    ///初始化 _cloneList
    cloneDataList(widget.data!, _cloneList);
  }

  ///绘制 grid 列表嵌套
  renderGrid(count, data, index) {
    return SizedBox(
      height: widget.itemExtent * count,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: List.generate(count, (i) {
          var child = data.children[i];

          ///记录冲突选择的Map，用户后续重置
          if (child.selectedCleanOther) {
            cleanOtherList["$i"] = i;
          }

          return InkWell(
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
              if (!child.selectedCleanOther && cleanOtherList.isNotEmpty) {
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
            child: widget.itemBuilder!(context, child),
          );
        }),
      ),
    );
  }

  ///绘制底部按键
  Widget renderButton() {
    return SizedBox(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      resetList(widget.data!);
                    });
                    controller!.hide();
                  },
                  child: const Text("重置"))),
          Expanded(
              child: TextButton(
                  onPressed: () {
                    controller!.select(_cloneList);
                  },
                  child: const Text("确定"))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            // ignore: avoid_unnecessary_containers
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(_cloneList[index].title!),
                  ),
                  renderGrid(_cloneList[index].children!.length,
                      _cloneList[index], index)
                ],
              ),
            );
          },
          itemCount: _cloneList.length,
        ),
      ),
      renderButton(),
    ]);
  }

  @override
  void onEvent(DropSelectEvent? event) {
    switch (event) {
      case DropSelectEvent.SELECT:
        {
          ///选择时才使用目标
          cloneDataList(_cloneList, widget.data!);
          break;
        }
      case DropSelectEvent.HIDE:
        {}
        break;
      case DropSelectEvent.ACTIVE:
      default:
        {
          ///激活时备份列表
          cloneDataList(widget.data!, _cloneList);
        }
        break;
    }
  }
}
