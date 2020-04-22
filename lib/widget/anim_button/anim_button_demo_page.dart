import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/anim_button/play_anim_button.dart';

import 'loading_anim_button.dart';

class AnimButtonDemoPage extends StatefulWidget {
  @override
  _AnimButtonDemoPageState createState() => _AnimButtonDemoPageState();
}

class _AnimButtonDemoPageState extends State<AnimButtonDemoPage> {
  LoadingState loadingState = LoadingState.STATE_PRE;

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var playButton;
    try {
      if (Platform.isAndroid == true || Platform.isIOS == true) {
        playButton = SizedBox(
          height: 50,
          width: 50,
          child: PlayAnimButton(),
        );
      } else {
        playButton = new Container(
          child: new Text(
            "该控件效果暂不支持 Web，已隐藏",
            style: new TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }
    } catch (e) {
      playButton = new Container(
        child: new Text(
          "该效果暂不支持 Web",
          style: new TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: new Text("AnimButtonDemoPage"),
      ),
      body: Container(
        color: Colors.blueAccent,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              child: new Text(
                "点击下方按键切换动画效果",
                style: new TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            new SizedBox(
              height: 50,
            ),
            playButton,
            new SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 50,
              width: 50,
              child: InkWell(
                onTap: () {
                  var nextState;
                  switch (loadingState) {
                    case LoadingState.STATE_PRE:
                      nextState = LoadingState.STATE_COMPLETE;
                      break;
                    case LoadingState.STATE_COMPLETE:
                      nextState = LoadingState.STATE_END;
                      break;
                    case LoadingState.STATE_END:
                      nextState = LoadingState.STATE_DOWNLOADING;
                      break;
                    case LoadingState.STATE_DOWNLOADING:
                      nextState = LoadingState.STATE_PRE;
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
