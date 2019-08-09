import 'package:flutter/material.dart';

class HeaderAppBar extends StatelessWidget {
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
}
