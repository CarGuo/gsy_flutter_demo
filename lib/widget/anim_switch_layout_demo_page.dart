import 'package:flutter/material.dart';



class AnimSwitchLayoutDemoPage extends StatefulWidget {
  const AnimSwitchLayoutDemoPage({Key? key}) : super(key: key);

  @override
  State<AnimSwitchLayoutDemoPage> createState() => _AnimSwitchLayoutDemoPageState();
}

class _AnimSwitchLayoutDemoPageState extends State<AnimSwitchLayoutDemoPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  PositionedItemData getIndexPosition(int index, Size size) {
    switch (index) {
      case 0:
        return PositionedItemData(
          width: size.width / 2 - 5,
          height: size.height,
          left: 0,
          top: 0,
        );

      case 1:
        return PositionedItemData(
          width: size.width / 2 - 5,
          height: size.height / 2 - 5,
          left: size.width / 2 + 5,
          top: 0,
        );

      case 2:
        return PositionedItemData(
          width: size.width / 2 - 5,
          height: size.height,
          left: size.width / 2 + 5,
          top: size.height / 2 + 5,
        );
    }
    return PositionedItemData(
      width: size.width / 2 - 5,
      height: size.height,
      left: 0,
      top: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("ControllerDemoPage"),
      ),
      extendBody: true,
      body: Center(
        child: Container(
          height: 300,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (_, con) {
              var f = getIndexPosition(currentIndex % 3, con.biggest);
              var s = getIndexPosition((currentIndex + 1) % 3, con.biggest);
              var t = getIndexPosition((currentIndex + 2) % 3, con.biggest);
              return Stack(
                fit: StackFit.expand,
                children: [
                  new AnimatedPositioned(
                    // Define how long the animation should take.
                    duration: Duration(seconds: 1),
                    // Provide an optional curve to make the animation feel smoother.
                    curve: Curves.fastOutSlowIn,
                    child: new AnimatedContainer(
                      color: Colors.greenAccent,
                      // Define how long the animation should take.
                      duration: Duration(seconds: 1),
                      // Provide an optional curve to make the animation feel smoother.
                      curve: Curves.fastOutSlowIn,
                      width: f.width,
                      height: f.height,
                    ),
                    left: f.left,
                    top: f.top,
                  ),
                  new AnimatedPositioned(
                    // Define how long the animation should take.
                    duration: Duration(seconds: 1),
                    // Provide an optional curve to make the animation feel smoother.
                    curve: Curves.fastOutSlowIn,
                    child: new AnimatedContainer(
                      color: Colors.redAccent,
                      // Define how long the animation should take.
                      duration: Duration(seconds: 1),
                      // Provide an optional curve to make the animation feel smoother.
                      curve: Curves.fastOutSlowIn,
                      width: s.width,
                      height: s.height,
                    ),
                    left: s.left,
                    top: s.top,
                  ),
                  new AnimatedPositioned(
                    // Define how long the animation should take.
                    duration: Duration(seconds: 1),
                    // Provide an optional curve to make the animation feel smoother.
                    curve: Curves.fastOutSlowIn,
                    child: new AnimatedContainer(
                      color: Colors.yellowAccent,
                      // Define how long the animation should take.
                      duration: Duration(seconds: 1),
                      // Provide an optional curve to make the animation feel smoother.
                      curve: Curves.fastOutSlowIn,
                      width: t.width,
                      height: t.height,
                    ),
                    left: t.left,
                    top: t.top,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            currentIndex = currentIndex + 1;
          });
        },
      ),
    );
  }
}

class PositionedItemData {
  final double left;
  final double top;
  final double width;
  final double height;

  PositionedItemData({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}
