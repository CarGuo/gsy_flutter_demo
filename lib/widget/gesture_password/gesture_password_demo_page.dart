import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/gesture_password/gesture_password_view.dart';

class GesturePasswordDemoPage extends StatefulWidget {
  const GesturePasswordDemoPage({super.key});

  @override
  _GesturePasswordDemoState createState() => _GesturePasswordDemoState();
}

class _GesturePasswordDemoState extends State<GesturePasswordDemoPage> {
  String _pwd = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("手势密码"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: GesturePasswordView(
                pathWidth: 6,
                frameRadius: 30,
                onDone: (value) {
                  setState(() {
                    _pwd = value.join();
                  });
                },
              ),
            ),
            Text("当前密码: $_pwd"),
          ],
        ),
      ),
    );
  }
}
