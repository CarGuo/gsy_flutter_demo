import 'package:flutter/material.dart';

class HeaderAppBar extends StatelessWidget {
  final int alphaBg;
  final bool showStickItem;

  const HeaderAppBar({super.key, this.alphaBg = 0, this.showStickItem = false});

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.first)
        .padding
        .top;

    double reactHeight = 30;

    ///总高度 = appbar 高度 +  statusBar 高度 + 底部停靠区域高度
    double containerHeight = kToolbarHeight + statusBarHeight + reactHeight;

    var color = Theme.of(context).primaryColor.withAlpha(alphaBg);

    return Material(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.centerLeft,
        height: containerHeight,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ///撑满状态栏颜色
            Container(
              height: statusBarHeight,
              color: color,
            ),
            Container(
              color: color,
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: 10, left: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withAlpha(125),
                        borderRadius: const BorderRadius.all(Radius.circular(18))),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: kToolbarHeight - 15,
                      margin: const EdgeInsets.only(right: 20, left: 20),
                      decoration: BoxDecoration(
                          color: Colors.white.withAlpha(125),
                          borderRadius: const BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ],
              ),
            ),
            showStickItem
                ? Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.only(left: 10),
                    height: reactHeight,
                    color: Colors.amber,
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.ac_unit, color: Colors.white, size: 13),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "StickText",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
