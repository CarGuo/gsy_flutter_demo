import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/anim_button/play_anim_button.dart';

import 'loading_anim_button.dart';

class AnimButtonDemoPage extends StatefulWidget {
  const AnimButtonDemoPage({super.key});

  @override
  AnimButtonDemoPageState createState() => AnimButtonDemoPageState();
}

class AnimButtonDemoPageState extends State<AnimButtonDemoPage> {
  LoadingState? loadingState = LoadingState.STATE_PRE;

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget playButton;
    try {
      if (!kIsWeb) {
        playButton = const SizedBox(
          height: 50,
          width: 50,
          child: PlayAnimButton(),
        );
      } else {
        playButton = const Text(
          "该控件效果暂不支持 Web，已隐藏",
          style: TextStyle(color: Colors.white, fontSize: 16),
        );
      }
    } catch (e) {
      playButton = const Text(
        "该效果暂不支持 Web",
        style: TextStyle(color: Colors.white, fontSize: 16),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("AnimButtonDemoPage"),
      ),
      body: Container(
        color: Colors.blueAccent,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "点击下方按键切换动画效果",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(
              height: 50,
            ),
            playButton,
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 50,
              width: 50,
              child: InkWell(
                onTap: () {
                  LoadingState nextState;
                  switch (loadingState) {
                    case LoadingState.STATE_PRE:
                      nextState = LoadingState.STATE_COMPLETE;
                      break;
                    case LoadingState.STATE_END:
                      nextState = LoadingState.STATE_DOWNLOADING;
                      break;
                    case LoadingState.STATE_DOWNLOADING:
                      nextState = LoadingState.STATE_PRE;
                      break;
                    case LoadingState.STATE_COMPLETE:
                    default:
                      nextState = LoadingState.STATE_END;
                      break;
                  }
                  setState(() {
                    loadingState = nextState;
                  });
                },
                child: LoadingAnimButton(
                  loadingState: loadingState,
                  loadingSpeed: 1,
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
