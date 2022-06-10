import 'package:flutter/material.dart';

class AnimSwitchLayoutDemoPage extends StatefulWidget {
  const AnimSwitchLayoutDemoPage({Key? key}) : super(key: key);

  @override
  State<AnimSwitchLayoutDemoPage> createState() =>
      _AnimSwitchLayoutDemoPageState();
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
                  PositionItem(f,
                      child: InkWell(
                        onTap: () {
                          print("red");
                        },
                        child: Container(color: Colors.redAccent),
                      )),
                  PositionItem(s,
                      child: InkWell(
                        onTap: () {
                          print("green");
                        },
                        child: Container(color: Colors.greenAccent),
                      )),
                  PositionItem(t,
                      child: InkWell(
                        onTap: () {
                          print("yello");
                        },
                        child: Container(color: Colors.yellowAccent),
                      )),
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

class PositionItem extends StatelessWidget {
  final PositionedItemData data;
  final Widget child;

  const PositionItem(this.data, {required this.child});

  @override
  Widget build(BuildContext context) {
    return new AnimatedPositioned(
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      child: new AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        width: data.width,
        height: data.height,
        child: child,
      ),
      left: data.left,
      top: data.top,
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
