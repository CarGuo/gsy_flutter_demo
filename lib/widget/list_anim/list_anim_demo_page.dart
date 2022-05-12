import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/list_anim/header_appbar.dart';

class ListAnimDemoPage extends StatefulWidget {
  @override
  _ListAnimDemoPageState createState() => _ListAnimDemoPageState();
}

class _ListAnimDemoPageState extends State<ListAnimDemoPage> {
  ///AppBar 的背景色透明度
  int appBarColorAlpha = 0;

  ///记录滚动距离
  double scrollPix = 0;

  ///是否需要显示停靠
  bool showStickItem = false;

  ///头部区域高度
  double headerHeight = 300;

  ///头部区域偏离图片高度
  double headerRectMargin = 40;

  ///头部信息框高度
  double headerRectHeight = 60;


  ///头部区域
  _buildHeader() {
    ///状态栏高度
    double statusBarHeight =
        MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;
    ///头部区域去除marin、appbar、状态栏之后的高度
    double dynamicValue =
        headerHeight - headerRectMargin - kToolbarHeight - statusBarHeight;

    ///计算 margin 的撑开动画效果，用于视觉偏差
    ///计算停靠 item 的显示标志 showStickItem
    double marginEdge = 0;
    if (scrollPix >= dynamicValue) {
      marginEdge = 10 - (scrollPix - dynamicValue);
      marginEdge = math.max(0, marginEdge);
      if (marginEdge == 0) {
        showStickItem = true;
      } else {
        showStickItem = false;
      }
    } else {
      marginEdge = 10;
      showStickItem = false;
    }

    return Container(
      alignment: Alignment.topCenter,
      height: headerHeight,
      child: new Stack(
        children: <Widget>[
          new Image.asset(
            "static/gsy_cat.png",
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: headerHeight - headerRectMargin,
          ),
          new Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: headerRectHeight,
              color: Colors.amber,
              margin: EdgeInsets.only(left: marginEdge, right: marginEdge),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Text(
                    "StickText",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  new Expanded(child: new Container()),
                  new Icon(
                    Icons.ac_unit,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ///处理滑动监听
  _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    scrollPix = notification.metrics.pixels;
    var curAlpha = 0;
    if (notification.metrics.pixels <= 0) {
      curAlpha = 0;
    } else {
      curAlpha = ((notification.metrics.pixels / 180) * 255).toInt();
      if (curAlpha > 255) {
        curAlpha = 255;
      }
    }
    setState(() {
      appBarColorAlpha = curAlpha;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Scaffold(
          ///去除 SafeArea 的 padding
          body: MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            removeTop: true,
            removeRight: true,
            removeBottom: true,
            child: Container(
              child: new NotificationListener(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollUpdateNotification) {
                    _handleScrollUpdateNotification(notification);
                  }
                  return false;
                },
                child: new ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader();
                    }
                    return Card(
                      child: new Container(
                        height: 60,
                        alignment: Alignment.centerLeft,
                        child: new Text("Item ${[index]} FFFFF"),
                      ),
                    );
                  },
                  itemCount: 100,
                ),
              ),
            ),
          ),
        ),
        HeaderAppBar(
          alphaBg: appBarColorAlpha,
          showStickItem: showStickItem,
        ),
      ],
    );
  }
}
