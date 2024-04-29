import 'package:flutter/material.dart';

class InputBottomDemoPage extends StatefulWidget {
  const InputBottomDemoPage({super.key});

  @override
  _InputBottomDemoPageState createState() => _InputBottomDemoPageState();
}

class _InputBottomDemoPageState extends State<InputBottomDemoPage> {
  bool isKeyboardShowing = false;

  TextEditingController textEditingController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ///必须嵌套在外层
    return KeyboardDetector(
      keyboardShowCallback: (show) {
        setState(() {
          isKeyboardShowing = show;
        });
      },
      content: Scaffold(
        appBar: AppBar(
          title: const Text("KeyBoardDemoPage"),
        ),
        body: GestureDetector(
          ///透明可以触摸
          behavior: HitTestBehavior.translucent,
          onTap: () {
            /// 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  const Align(
                    alignment: Alignment.center,
                    child:
                        Text("测试，测试，测试，测试，测试，测试，测试，测试，测试，测试，测试，测试，测试，测试，测试"),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent)),
                            child: TextField(
                              decoration: const InputDecoration(
                                  hintText: "请输入",
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(width: 0)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(width: 0)),
                                  disabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(width: 0)),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(width: 0))),
                              controller: textEditingController,
                            ),
                          ),
                          Visibility(
                            visible: isKeyboardShowing,
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.grey,
                              height: 40,
                              width: MediaQuery.sizeOf(context).width,
                              child: const Text("bottom bar"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

typedef KeyboardShowCallback = void Function(bool isKeyboardShowing);

///监听键盘弹出收起
class KeyboardDetector extends StatefulWidget {
  final KeyboardShowCallback? keyboardShowCallback;

  final Widget content;

  const KeyboardDetector({super.key, this.keyboardShowCallback, required this.content});

  @override
  _KeyboardDetectorState createState() => _KeyboardDetectorState();
}

class _KeyboardDetectorState extends State<KeyboardDetector>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        widget.keyboardShowCallback
            ?.call(MediaQuery.viewInsetsOf(context).bottom > 0);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.content;
  }
}
