import 'package:flutter/material.dart';

class AnimTipDemoPage extends StatefulWidget {
  @override
  _AnimTipDemoPageState createState() => _AnimTipDemoPageState();
}

class _AnimTipDemoPageState extends State<AnimTipDemoPage> {
  bool showTipItem = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("AnimTipDemoPage"),
      ),
      body: Container(
        child: new Column(children: [
          Container(
            child: AnimatedSwitcher(
              switchInCurve: Cubic(0.4, 0.0, 0.2, 1.0),
              switchOutCurve: Cubic(1.0, 0.1, 1.0, 0.1),
              transitionBuilder: (child, anim) {
                return SlideTransition(
                    child: child,
                    position: Tween<Offset>(
                      begin: Offset(0.0, -1.0),
                      end: Offset(0.0, 0.0),
                    ).animate(anim));
              },
              duration: Duration(milliseconds: 500),
              child: showTipItem
                  ? Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      height: 70,
                      key: ValueKey("TipItem"),
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
          new Expanded(
            child: new Container(
              child: new Center(
                child: new TextButton(
                  onPressed: () {
                    setState(() {
                      showTipItem = true;
                    });
                    Future.delayed(Duration(seconds: 1), () {
                      setState(() {
                        showTipItem = false;
                      });
                    });
                  },
                  child: new Text("Click Me"),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
