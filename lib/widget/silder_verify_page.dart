import 'package:flutter/material.dart';

class SlideVerifyPage extends StatelessWidget {
  const SlideVerifyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SlideVerifyPage"),
      ),
      body: Container(
        child: Center(
          child: SlideVerify(
            sliderImage: "static/gsy_cat.png",
            successText: "验证成功",
            initText: "滑动验证",
          ),
        ),
      ),
    );
  }
}

class SlideVerify extends StatefulWidget {
  final double height;
  final double width;
  final Color borderColor;
  final Color bgColor;
  final Color moveColor;
  final String? successText;
  final String? sliderImage;
  final String? initText;
  final String? initImage;
  final TextStyle successTextStyle;
  final TextStyle initTextStyle;
  final VoidCallback? successListener;

  const SlideVerify(
      {Key? key,
      this.height = 60,
      this.width = 250,
      this.successText,
      this.initText,
      this.sliderImage,
      this.initImage,
      this.successTextStyle =
          const TextStyle(fontSize: 14, color: Colors.white),
      this.initTextStyle = const TextStyle(fontSize: 14, color: Colors.black12),
      this.bgColor = Colors.grey,
      this.moveColor = Colors.blue,
      this.borderColor = Colors.blueAccent,
      this.successListener})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SlideVerifyState();
  }
}

class SlideVerifyState extends State<SlideVerify>
    with TickerProviderStateMixin {
  AnimationController? _animController;
  Animation? _curve;
  double initX = 0.0;
  double height = 0;
  double width = 0;
  double moveDistance = 0;

  double sliderWidth = 0;

  bool verifySuccess = false;

  bool enable = true;

  void _init() {
    sliderWidth = widget.height - 4;
    _animController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _curve = CurvedAnimation(parent: _animController!, curve: Curves.easeOut);
    _curve?.addListener(() {
      setState(() {
        moveDistance = moveDistance - moveDistance * _curve!.value;
        if (moveDistance <= 0) {
          moveDistance = 0;
        }
      });
    });
    _animController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        enable = true;
        _animController?.reset();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.width = widget.width;
    this.height = widget.height;
    _init();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        if (!enable) {
          return;
        }
        initX = details.globalPosition.dx;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!enable) {
          return;
        }
        moveDistance = details.globalPosition.dx - initX;
        if (moveDistance < 0) {
          moveDistance = 0;
        }

        if (moveDistance > width - sliderWidth) {
          moveDistance = width - sliderWidth;
          enable = false;
          verifySuccess = true;
          if (widget.successListener != null) {
            widget.successListener?.call();
          }
        }
        setState(() {});
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (enable) {
          enable = false;
          _animController?.forward();
        }
      },
      child: Container(
        height: height,
        width: width,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: widget.bgColor,
            border: Border.all(color: widget.borderColor),
            borderRadius: BorderRadius.all(new Radius.circular(height))),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                height: height - 2,
                width: moveDistance < 1 ? 0 : moveDistance + sliderWidth / 2,
                decoration: BoxDecoration(
                  color: widget.moveColor,
                ),
              ),
            ),
            Center(
              child: Text(
                verifySuccess
                    ? widget.successText ?? ""
                    : widget.initText ?? "",
                style: verifySuccess
                    ? widget.successTextStyle
                    : widget.initTextStyle,
              ),
            ),
            Positioned(
              top: 1,
              left:
                  moveDistance > sliderWidth ? moveDistance - 2 : moveDistance,
              child: Container(
                width: sliderWidth,
                height: sliderWidth,
                alignment: Alignment.center,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    new Radius.circular(sliderWidth),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (widget.sliderImage != null)
                      Image.asset(
                        widget.sliderImage!,
                        height: sliderWidth,
                        width: sliderWidth,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
