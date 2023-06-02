import 'package:flutter/material.dart';

///Stack + Positioned例子
class PositionedDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("PositionedDemoPage"),
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        margin: EdgeInsets.all(15),
        child: new Stack(
          children: <Widget>[
            new MaterialButton(
              onPressed: () {},
              color: Colors.blue,
            ),
            new Positioned(
                child: new MaterialButton(
                  onPressed: () {},
                  color: Colors.greenAccent,
                ),
                left: MediaQuery.sizeOf(context).width / 2),
            new Positioned(
              child: new MaterialButton(
                onPressed: () {},
                color: Colors.yellow,
              ),
              left: MediaQuery.sizeOf(context).width / 5,
              top: MediaQuery.sizeOf(context).height / 4 * 3,
            ),
            new Positioned(
              child: new MaterialButton(
                onPressed: () {},
                color: Colors.redAccent,
              ),
              left: MediaQuery.sizeOf(context).width / 2 - Theme.of(context).buttonTheme.minWidth / 2,
              top: MediaQuery.sizeOf(context).height / 2 -
                  MediaQuery.paddingOf(context).top -
                  kToolbarHeight,
            ),
          ],
        ),
      ),
    );
  }
}
