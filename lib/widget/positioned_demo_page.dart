import 'package:flutter/material.dart';

///Stack + Positioned例子
class PositionedDemoPage extends StatelessWidget {
  const PositionedDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PositionedDemoPage"),
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        margin: const EdgeInsets.all(15),
        child: Stack(
          children: <Widget>[
            MaterialButton(
              onPressed: () {},
              color: Colors.blue,
            ),
            Positioned(
                left: MediaQuery.sizeOf(context).width / 2,
                child: MaterialButton(
                  onPressed: () {},
                  color: Colors.greenAccent,
                )),
            Positioned(
              left: MediaQuery.sizeOf(context).width / 5,
              top: MediaQuery.sizeOf(context).height / 4 * 3,
              child: MaterialButton(
                onPressed: () {},
                color: Colors.yellow,
              ),
            ),
            Positioned(
              left: MediaQuery.sizeOf(context).width / 2 - Theme.of(context).buttonTheme.minWidth / 2,
              top: MediaQuery.sizeOf(context).height / 2 -
                  MediaQuery.paddingOf(context).top -
                  kToolbarHeight,
              child: MaterialButton(
                onPressed: () {},
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
