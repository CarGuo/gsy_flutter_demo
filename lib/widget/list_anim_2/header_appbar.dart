import 'package:flutter/material.dart';

class HeaderAppBar2 extends StatelessWidget {
  final int alphaBg;
  final bool showStickItem;

  HeaderAppBar2({this.alphaBg = 0, this.showStickItem = false});

  @override
  Widget build(BuildContext context) {
    double statusBarHeight =
        MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;

    double reactHeight = 30;

    ///总高度 = appbar 高度 +  statusBar 高度 + 底部停靠区域高度
    double containerHeight = kToolbarHeight + statusBarHeight + reactHeight;

    var color = Theme.of(context).primaryColor.withAlpha(alphaBg);

    return new Material(
      color: Colors.transparent,
      child: new Container(
        alignment: Alignment.centerLeft,
        height: containerHeight,
        child: new Stack(
          children: <Widget>[
            new Container(
              margin: EdgeInsets.only(top: statusBarHeight + kToolbarHeight),
              child: AnimatedSwitcher(
                switchInCurve: Cubic(0.4, 0.0, 0.2, 1.0),
                switchOutCurve: Cubic(1.0, 0.1, 1.0, 0.1),
                transitionBuilder: (child, anim) {
                  ///不同状态显示不同动画
                  if (showStickItem)
                    return SlideTransition(
                        child: child,
                        position: Tween<Offset>(
                          begin: Offset(0.0, -0.5),
                          end: Offset(0.0, 0.0),
                        ).animate(anim));
                  return FadeTransition(
                    child: child,
                    opacity: anim,
                  );
                },
                duration: Duration(milliseconds: showStickItem ? 500 : 1),
                child: showStickItem
                    ? Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        height: reactHeight,
                        key: ValueKey("stickItem"),
                        color: Colors.amber,
                        child: new Row(
                          children: <Widget>[
                            new Icon(Icons.ac_unit,
                                color: Colors.white, size: 13),
                            new SizedBox(
                              width: 10,
                            ),
                            new Text(
                              "StickText",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : new Container(
                        key: ValueKey("hideItem"),
                      ),
              ),
            ),
            new Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                ///撑满状态栏颜色
                new Container(
                  height: statusBarHeight,
                  color: color,
                ),
                new Container(
                  color: color,
                  height: kToolbarHeight,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withAlpha(125),
                            borderRadius:
                                BorderRadius.all(Radius.circular(18))),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      new Expanded(
                        child: new Container(
                          height: kToolbarHeight - 15,
                          margin: EdgeInsets.only(right: 20, left: 20),
                          decoration: BoxDecoration(
                              color: Colors.white.withAlpha(125),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
