import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final random = math.Random();
final stickHeader = 50.0;

class StickSliverListDemoPage extends StatefulWidget {
  final List<ExpendedModel> dataList = List.generate(7, (index) {
    return ExpendedModel(false, List(random.nextInt(100)));
  });

  @override
  _StickSliverListDemoPageState createState() =>
      _StickSliverListDemoPageState();
}

class _StickSliverListDemoPageState extends State<StickSliverListDemoPage> {
  int _titleIndex = 0;
  bool _showTitleTopButton = false;

  ScrollController _scrollController = new ScrollController();

  final GlobalKey scrollKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(scrollChanged);
  }

  scrollChanged() {
    if (widget.dataList.length == 0) {
      return;
    }
    var item = widget.dataList.lastWhere((item) {
      if (item.globalKey.currentContext == null) {
        return false;
      }

      ///获取 renderBox
      RenderSliver renderSliver =
          item.globalKey.currentContext.findRenderObject();
      if (renderSliver == null) {
        return false;
      }
      return renderSliver.constraints.scrollOffset > 0;
    }, orElse: () {
      return null;
    });
    if (item == null) {
      return;
    }
    int currentIndex = widget.dataList.indexOf(item);
    if (currentIndex != _titleIndex) {
      setState(() {
        _titleIndex = currentIndex;
      });
    }
    var needTopButton = _scrollController.position.pixels > 0;
    if (needTopButton != _showTitleTopButton) {
      setState(() {
        _showTitleTopButton = needTopButton;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("StickSliverListDemoPage"),
        ),
        body: new Stack(
          children: <Widget>[
            new Container(
              child: CustomScrollView(
                key: scrollKey,
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                slivers: List.generate(widget.dataList.length, (index) {
                  return SliverExpandedList(
                    widget.dataList[index],
                    "header $index",
                    valueChanged: (_) {
                      setState(() {});
                    },
                  );
                }),
              ),
            ),
            StickHeader("header $_titleIndex",
                showTopButton: _showTitleTopButton, callback: () {
              var item = widget.dataList[_titleIndex];
              RenderSliver renderSliver =
                  item.globalKey.currentContext.findRenderObject();
              var position = _scrollController.position.pixels -
                  renderSliver.constraints.scrollOffset;
              _scrollController.position.jumpTo(position);
            })
          ],
        ));
  }
}

class SliverExpandedList extends StatefulWidget {
  final ExpendedModel expendedModel;
  final String title;
  final int visibleCount;
  final ValueChanged valueChanged;

  SliverExpandedList(this.expendedModel, this.title,
      {this.visibleCount = 3, this.valueChanged});

  @override
  _SliverExpandedListState createState() => _SliverExpandedListState();
}

class _SliverExpandedListState extends State<SliverExpandedList> {
  bool expanded = false;

  toTop() {
    ///获取 renderBox
    RenderSliver render = context.findRenderObject();
    if (render == null) {
      return;
    }
    var position = Scrollable.of(context).position.pixels -
        render.constraints.scrollOffset;
    if (position >= 0) {
      Scrollable.of(context).position.jumpTo(position);
    }
  }

  ///大于可见数量才使用 查看更多
  renderExpendedMore() {
    return new Container(
      height: 50.0,
      color: Colors.grey,
      padding: new EdgeInsets.only(left: 10.0),
      alignment: Alignment.center,
      child: new InkWell(
        onTap: () {
          if (expanded) {
            ///获取 renderBox
            toTop();
          }
          widget.valueChanged?.call(!expanded);
          setState(() {
            expanded = !expanded;
          });
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child: new Text(
            expanded ? "收起" : '查看更多',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  getListCount(bool needExpanded) {
    return (expanded)
        ? (needExpanded)
            ? widget.expendedModel.dataList.length + 2
            : widget.expendedModel.dataList.length + 1
        : (needExpanded) ? widget.visibleCount + 2 : widget.visibleCount + 1;
  }

  @override
  Widget build(BuildContext context) {
    bool needExpanded = (widget.expendedModel.dataList.length > 3);
    return SliverList(
      key: widget.expendedModel.globalKey,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          ///增加bottom
          if (!expanded && needExpanded && index == widget.visibleCount + 1) {
            return renderExpendedMore();
          }
          if (index == widget.expendedModel.dataList.length + 1) {
            return renderExpendedMore();
          }

          ///增加header
          if (index == 0) {
            return StickHeader(widget.title);
          }
          return Card(
            child: new Container(
              height: 60,
              alignment: Alignment.centerLeft,
              child: new Text("Item $index"),
            ),
          );
        },
        childCount: getListCount(needExpanded),
      ),
    );
  }
}

class StickHeader extends StatelessWidget {
  final String title;
  final bool showTopButton;
  final VoidCallback callback;

  StickHeader(this.title, {Key key, this.showTopButton = false, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: stickHeader,
      color: Colors.deepPurple,
      padding: new EdgeInsets.only(left: 10.0),
      alignment: Alignment.centerLeft,
      child: new Row(
        children: <Widget>[
          Expanded(
            child: new Text(
              '我的 $title 头啊',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Visibility(
            visible: showTopButton,
            child: InkWell(
              onTap: () {
                callback?.call();
              },
              child: Icon(Icons.vertical_align_top),
            ),
          )
        ],
      ),
    );
  }
}

class ExpendedModel {
  bool expended;

  List dataList;

  GlobalKey globalKey = new GlobalKey();

  ExpendedModel(this.expended, this.dataList);
}
