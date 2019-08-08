import 'package:flutter/material.dart';

class ListAnimDemoPage extends StatefulWidget {
  @override
  _ListAnimDemoPageState createState() => _ListAnimDemoPageState();
}

class _ListAnimDemoPageState extends State<ListAnimDemoPage> {
  int alpha = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildHeader() {
    double height = 200;
    return Container(
      alignment: Alignment.topCenter,
      height: height,
      child: new Image.asset(
        "static/gsy_cat.png",
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
        height: height,
      ),
    );
  }

  _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    print("${notification.metrics.pixels}");
    var curAlpha = 0;
    if (notification.metrics.pixels <= 0) {
      curAlpha = 0;
    } else {
      curAlpha = ((notification.metrics.pixels / 200) * 255).toInt();
      if (curAlpha > 255) {
        curAlpha = 255;
      }
    }
    setState(() {
      alpha = curAlpha;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Scaffold(
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
          alpha: alpha,
        ),
      ],
    );
  }
}

class HeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int alpha;

  HeaderAppBar({this.alpha = 0});

  @override
  Widget build(BuildContext context) {
    double paddingTop =
        MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;

    var color = Theme.of(context).primaryColor.withAlpha(alpha);

    return new Material(
      color: Colors.transparent,
      child: new Container(
        alignment: Alignment.centerLeft,
        height: kToolbarHeight + paddingTop,
        color: color,
        child: new Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(top: paddingTop),
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
                    borderRadius: BorderRadius.all(Radius.circular(18))),
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
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
