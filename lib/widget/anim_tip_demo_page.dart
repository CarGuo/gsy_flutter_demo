import 'package:flutter/material.dart';

class AnimTipDemoPage extends StatefulWidget {
  const AnimTipDemoPage({super.key});

  @override
  _AnimTipDemoPageState createState() => _AnimTipDemoPageState();
}

class _AnimTipDemoPageState extends State<AnimTipDemoPage> {
  bool showTipItem = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AnimTipDemoPage"),
      ),
      body: Column(children: [
        AnimatedSwitcher(
          switchInCurve: const Cubic(0.4, 0.0, 0.2, 1.0),
          switchOutCurve: const Cubic(1.0, 0.1, 1.0, 0.1),
          transitionBuilder: (child, anim) {
            return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, -1.0),
                  end: const Offset(0.0, 0.0),
                ).animate(anim),
                child: child);
          },
          duration: const Duration(milliseconds: 500),
          child: showTipItem
              ? Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.sizeOf(context).width,
                  height: 70,
                  key: const ValueKey("TipItem"),
                  color: Colors.amber,
                  child: const Row(
                    children: <Widget>[
                      Icon(Icons.ac_unit,
                          color: Colors.white, size: 13),
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
              : Container(
                  key: const ValueKey("hideItem"),
                ),
        ),
        Expanded(
          child: Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  showTipItem = true;
                });
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    showTipItem = false;
                  });
                });
              },
              child: const Text("Click Me"),
            ),
          ),
        )
      ]),
    );
  }
}
