import 'package:flutter/material.dart';

const String testString = "Hello GSY，欢迎你的交流";

class AnimaDemoPage5 extends StatefulWidget {
  const AnimaDemoPage5({super.key});

  @override
  _AnimaDemoPageState createState() => _AnimaDemoPageState();
}

class _AnimaDemoPageState extends State<AnimaDemoPage5>
    with TickerProviderStateMixin {
  final List<String> _charList = [];
  final List<AnimationController> _controllerList =[];
  final List<CurvedAnimation> _moveAnimation = [];

  bool played = false;
  bool playing = false;

  @override
  void initState() {
    for (var value in testString.codeUnits) {
      _charList.add(String.fromCharCode(value));
      var controller = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 600));
      _controllerList.add(controller);
      _moveAnimation.add(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutExpo,
      ));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimaDemoPage5')),
      body: Center(
        child: Wrap(
          children: List.generate(_charList.length, (i) {
            return AnimatedText(
                animation: _moveAnimation[i],
                child: Text(
                  _charList[i],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ));
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (playing) {
            return;
          }
          if (played) {
            back();
          } else {
            play();
          }
        },
        child: const Icon(Icons.play_arrow),
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
  final Widget? child;

  AnimatedText({super.key, required Animation<double> animation, this.child})
      : super(listenable: animation);

  _getOpacity() {
    var value = _opacityAnim.evaluate(listenable as Animation<double>);
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
            Tween(begin: const Offset(0, 5), end: const Offset(0, 0)).animate(listenable as Animation<double>),
        child: child,
      ),
    );
  }
}
