import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/expand/expand_widget.dart';
import 'package:gsy_flutter_demo/widget/stick/stick_widget.dart';

final random = math.Random();
final stickHeader = 50.0;

///具备展开和收缩列表能力的Demo
class StickExpendDemoPage extends StatefulWidget {
  ///随机生成 tagList 的 data List 数据
  final List<ExpendedModel> tagList = List.generate(50, (index) {
    return ExpendedModel(false, List.filled(random.nextInt(20), null));
  });

  @override
  _StickExpendDemoPageState createState() => _StickExpendDemoPageState();
}

class _StickExpendDemoPageState extends State<StickExpendDemoPage> {
  @override
  Widget build(_) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StickExpendDemoPage"),
      ),
      body: Container(
        ///列表数据
        child: new ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: widget.tagList.length,
            itemBuilder: (context, index) {
              return new Container(
                color: Colors.white,

                ///头部停靠
                child: new StickWidget(
                  ///头部
                  stickHeader: new Container(
                    height: stickHeader,
                    color: Colors.deepPurple,
                    padding: new EdgeInsets.only(left: 10.0),
                    alignment: Alignment.centerLeft,
                    child: new InkWell(
                      onTap: () {
                        print("header");
                      },
                      child: new Text(
                        '我的 $index 头啊',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  ///可展开内容
                  stickContent: ExpandChildList(widget.tagList[index]),
                ),
              );
            }),
      ),
    );
  }
}

///可展开内容列表
class ExpandChildList extends StatefulWidget {
  final ExpendedModel expendedModel;

  ExpandChildList(this.expendedModel);

  @override
  _ExpandChildListState createState() => _ExpandChildListState();
}

class _ExpandChildListState extends State<ExpandChildList> {
  ///用户获取 ExpandableVisibleContainer 的相对位置
  ///因为需要在收缩时回滚到这个类目的top位置
  final GlobalKey globalKey = GlobalKey();

  final int animMilliseconds = 300;

  ///获取 globalKey 在 Scrollable 内的相对 y 滚动偏移量
  getY(GlobalKey key) {
    RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    double dy = renderBox
        .localToGlobal(Offset.zero,
            ancestor: Scrollable.of(context)!.context.findRenderObject())
        .dy;
    return dy;
  }

  ///在收起时因为动画会有 stick 显示冲突
  ///所以使用滚动和notifyListeners解决
  fixCloseState() {
    var y = getY(globalKey);
    Scrollable.of(context)!.position.jumpTo(
        math.max(0, Scrollable.of(context)!.position.pixels + y) - stickHeader);
    widget.expendedModel.expended = false;

    ///必须延时到收起动画结束后再更新UI
    Future.delayed(Duration(milliseconds: animMilliseconds + 50), () {
      Scrollable.of(context)!.position.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    double itemHeight = 150;
    double height = itemHeight * 3.0;

    return ExpandableNotifier(
      child: ScrollOnExpand(
        child: ExpandablePanel(
          height: height,
          initialExpanded: widget.expendedModel.expended,
          header: ExpandableVisibleContainer(
            widget.expendedModel.dataList,
            visibleCount: 3,
            key: globalKey,
            expandedStateChanged: (_) {
              widget.expendedModel.expended = true;
            },
          ),
          builder: (BuildContext context, Widget? collapsed, Widget? expanded) {
            return Expandable(
              animationDuration: Duration(milliseconds: animMilliseconds),
              collapsed: collapsed,
              expanded: expanded,
            );
          },
          expanded: ExpandableContainer(
            widget.expendedModel.dataList,
            visibleCount: 3,
            expandedStateChanged: (_) {
              fixCloseState();
            },
          ),
          tapHeaderToExpand: false,
          hasIcon: false,
        ),
      ),
    );
  }
}

///默认可视区域
class ExpandableVisibleContainer extends StatelessWidget {
  final double itemHeight;
  final int visibleCount;
  final List dataList;
  final ExpandedStateChanged? expandedStateChanged;

  ExpandableVisibleContainer(this.dataList,
      {required this.visibleCount,
      this.itemHeight = 150,
      this.expandedStateChanged,
      key})
      : super(key: key);

  ///大于可见数量才使用 查看更多
  renderExpendedMore(context) {
    return new Container(
      height: 50.0,
      color: Colors.grey,
      padding: new EdgeInsets.only(left: 10.0),
      alignment: Alignment.center,
      child: new InkWell(
        onTap: () {
          ///展开，回调
          ExpandableController.of(context)!.toggle();
          expandedStateChanged?.call(true);
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child: new Text(
            '查看更多',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ///大于可见数量才使用 查看更多
    bool needExpended = (dataList.length > visibleCount);

    ///未展开时显示展开更多
    int realVisibleCount = ExpandableController.of(context)!.expanded
        ? visibleCount
        : (needExpended)
            ? visibleCount + 1
            : visibleCount;

    return new Container(
      child: new Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: List.generate(realVisibleCount, (index) {
            ///绘制加载更多按键
            if (index == visibleCount) {
              return renderExpendedMore(context);
            }
            return new InkWell(
              onTap: () {
                print("content $index");
              },
              child: new Container(
                color: Colors.pinkAccent,
                height: itemHeight,
                child: new Center(
                  child: new Text(
                    '我的 $index 内容',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

///点击展开区域
class ExpandableContainer extends StatelessWidget {
  final double itemHeight;
  final ExpandedStateChanged? expandedStateChanged;
  final List dataList;
  final int visibleCount;

  ExpandableContainer(this.dataList,
      {required this.visibleCount,
      this.itemHeight = 150,
      this.expandedStateChanged});

  renderMoreItem(context) {
    return new Container(
      height: 50.0,
      color: Colors.grey,
      padding: new EdgeInsets.only(left: 10.0),
      alignment: Alignment.center,
      child: new InkWell(
        onTap: () {
          ///收起，回调
          ExpandableController.of(context)!.toggle();
          expandedStateChanged?.call(false);
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child: new Text(
            '收起',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ///去除可视部分后的个数
    int decCount = dataList.length - visibleCount;
    int expandedCount =
        !ExpandableController.of(context)!.expanded ? decCount : decCount + 1;

    if (!ExpandableController.of(context)!.expanded) {
      return Container();
    }

    return new Column(
      children: List.generate(expandedCount, (index) {
        ///只有展开后的才需要显示 收起按键
        if (index == decCount) {
          return renderMoreItem(context);
        }
        return new InkWell(
          onTap: () {
            print("content $index");
          },
          child: new Container(
            color: Colors.pinkAccent,
            height: itemHeight,
            child: new Center(
              child: new Text(
                '我的展开的 $index 内容 啊',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }
}

typedef ExpandedStateChanged(bool expanded);

class ExpendedModel {
  bool expended;
  List dataList;

  ExpendedModel(this.expended, this.dataList);
}
