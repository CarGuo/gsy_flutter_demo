import 'package:flutter/material.dart';

const String testString = "Hello GSY，欢迎你的交流";

class AnimaDemoPage5 extends StatefulWidget {
  @override
  _AnimaDemoPageState createState() => _AnimaDemoPageState();
}

class _AnimaDemoPageState extends State<AnimaDemoPage5>
    with TickerProviderStateMixin {
  List<String> _charList = List();
  List<AnimationController> _controllerList = List();
  List<CurvedAnimation> _moveAnimation = List();

  bool played = false;
  bool playing = false;

  @override
  void initState() {
    testString.codeUnits.forEach((value) {
      _charList.add(String.fromCharCode(value));
      var controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: 600));
      _controllerList.add(controller);
      _moveAnimation.add(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutExpo,
      ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AnimaDemoPage5')),
      body: Container(
        child: new Center(
          child: Wrap(
            children: List.generate(_charList.length, (i) {
              return AnimatedText(
                  animation: _moveAnimation[i],
                  child: Text(
                    _charList[i],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ));
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (playing) {
            return;
          }
          if (played)
            back();
          else
            play();
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  void play() {
    played = true;
    playing = true;
    for (int i = 0; i < _charList.length; i++) {
      Future.delayed(Duration(
        milliseconds: i * 80,
      )).then((_) {
        _controllerList[i].forward().whenComplete(() {
          if (i == _charList.length - 1) {
            playing = false;
          }
        });
      });
    }
  }

  void back() {
    played = false;
    playing = true;
    for (int i = 0; i < _charList.length; i++) {
      Future.delayed(Duration(
        milliseconds: i * 80,
      )).then((_) {
        _controllerList[i].reverse().whenComplete(() {
          if (i == _charList.length - 1) {
            playing = false;
          }
        });
      });
    }
  }
}

class AnimatedText extends AnimatedWidget {
  final Tween<double> _opacityAnim = Tween(begin: 0, end: 1);
  final Widget child;

  AnimatedText({Animation<double> animation, this.child})
      : super(listenable: animation);

  _getOpacity() {
    var value = _opacityAnim.evaluate(listenable);
    if (value < 0) {
      return 0;
    } else if (value > 1) {
      return 1;
    } else {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _getOpacity(),
      child: SlideTransition(
        position:
            Tween(begin: Offset(0, 5), end: Offset(0, 0)).animate(listenable),
        child: child,
      ),
    );
  }
}
