import 'package:flutter/material.dart';

///键盘相关Demo
///键盘是否弹起等
class KeyBoardDemoPage extends StatefulWidget {
  const KeyBoardDemoPage({super.key});

  @override
  _KeyBoardDemoPageState createState() => _KeyBoardDemoPageState();
}

class _KeyBoardDemoPageState extends State<KeyBoardDemoPage> {
  bool isKeyboardShowing = false;

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    ///必须嵌套在外层
    return KeyboardDetector(
      keyboardShowCallback: (isKeyboardShowing) {
        ///当前键盘是否可见
        setState(() {
          this.isKeyboardShowing = isKeyboardShowing;
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    isKeyboardShowing ? "键盘弹起" : "键盘未弹起",
                    style: TextStyle(
                        color: isKeyboardShowing
                            ? Colors.redAccent
                            : Colors.greenAccent),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      if (!isKeyboardShowing) {
                        /// 触摸收起键盘
                        FocusScope.of(context).requestFocus(_focusNode);
                      }
                    },
                    child: const Text("弹出键盘"),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    focusNode: _focusNode,
                    maxLines: 7,
                    minLines: 1,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              )
            ],
          ),
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
