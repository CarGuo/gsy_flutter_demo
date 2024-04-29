import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///状态栏颜色
class StatusBarDemoPage extends StatefulWidget {
  const StatusBarDemoPage({super.key});

  @override
  _StatusBarDemoPageState createState() => _StatusBarDemoPageState();
}

class _StatusBarDemoPageState extends State<StatusBarDemoPage> {
  bool customSystemUIOverlayStyle = false;

  @override
  Widget build(BuildContext context) {
    var body = getBody();
    ///如果手动设置过状态栏，就不可以用 AnnotatedRegion ，会影响
    if (customSystemUIOverlayStyle) {
      return body;
    }
    ///如果没有手动设置过状态栏，就可以用 AnnotatedRegion 直接嵌套显示
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: body,
    );
  }

  getBody() {
    return Scaffold(
      appBar: const ImageAppBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                ///手动修改
                setState(() {
                  customSystemUIOverlayStyle = true;
                });
                SystemChrome.setSystemUIOverlayStyle(
                    SystemUiOverlayStyle.light);
              },
              style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(
                  Colors.yellowAccent,
                ),
              ),
              child: const Text("Light"),
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customSystemUIOverlayStyle = true;
                });
                SystemChrome.setSystemUIOverlayStyle(
                    SystemUiOverlayStyle.dark);
              },
              style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(
                  Colors.greenAccent,
                ),
              ),
              child: const Text("Dart"),
            ),
          ],
        ),
      ),
    );
  }
}

///自定义 PreferredSizeWidget 做 AppBar
class ImageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ImageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "static/gsy_cat.png",
          fit: BoxFit.cover,
          width: MediaQuery.sizeOf(context).width,
          height: kToolbarHeight * 3,
        ),
        SafeArea(
          child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 3);
}
