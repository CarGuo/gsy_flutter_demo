import 'package:flutter/material.dart';

class ColorProgressDemoPage extends StatefulWidget {
  const ColorProgressDemoPage({super.key});

  @override
  _ColorProgressDemoPageState createState() => _ColorProgressDemoPageState();
}

class _ColorProgressDemoPageState extends State<ColorProgressDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ColorProgressDemoPage"),
      ),
      backgroundColor: Colors.grey,
      body: Center(
        child: Container(
          color: Colors.grey,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorProgress(
                colorList: colorList1,
                backgroundColor: bgColor1,
                bgBorder: bgBorder1,
                value: 0.5,
              ),
              const SizedBox(
                height: 10,
              ),
              ColorProgress(
                colorList: colorList2,
                backgroundColor: bgColor2,
                bgBorder: bgBorder2,
                value: 0.3,
              ),
              const SizedBox(
                height: 10,
              ),
              ColorProgress(
                colorList: colorList3,
                backgroundColor: bgColor3,
                bgBorder: bgBorder3,
                value: 1,
              ),
              const SizedBox(
                height: 10,
              ),
              ProgressPainterAnim(
                colorList: colorList1,
                backgroundColor: bgColor1,
                bgBorder: bgBorder1,
                value: 0.8,
              ),
              const SizedBox(
                height: 10,
              ),
              ProgressPainterAnim(
                colorList: colorList2,
                backgroundColor: bgColor2,
                bgBorder: bgBorder2,
                value: 0.4,
              ),
              const SizedBox(
                height: 10,
              ),
              ProgressPainterAnim(
                colorList: colorList3,
                backgroundColor: bgColor3,
                bgBorder: bgBorder3,
                value: 0.7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorProgress extends StatefulWidget {
  final Gradient backgroundColor;
  final List<Gradient> colorList;
  final Border bgBorder;
  final double value;

  const ColorProgress(
      {super.key, required this.colorList,
      required this.backgroundColor,
      required this.value,
      required this.bgBorder});

  @override
  _ColorProgressState createState() => _ColorProgressState();
}

class _ColorProgressState extends State<ColorProgress> {
  double _value = 0;

  List<Widget> renderColorList() {
    List<Widget> widgetList = [];
    for (var element in widget.colorList) {
      widgetList.add(
        Container(
          decoration: BoxDecoration(
            gradient: element,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          child: Container(),
        ),
      );
    }
    return widgetList;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {
      setState(() {
        _value = widget.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = const BorderRadius.all(Radius.circular(8));
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          border: widget.bgBorder,
          borderRadius: borderRadius,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: widget.backgroundColor,
                borderRadius: borderRadius,
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Stack(
                children: [
                  ClipRect(
                    child: OverflowBox(
                      minHeight: 10,
                      maxHeight: 10,
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        // Use the properties stored in the State class.
                        width: constraints.maxWidth * _value,
                        duration: const Duration(seconds: 2),
                        curve: Curves.fastOutSlowIn,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: renderColorList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

List<Gradient> colorList1 = [
  const LinearGradient(
    begin: Alignment(0.52576, 0.80444),
    end: Alignment(0.52576, 0.20356),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 255, 228, 166),
      Color.fromARGB(255, 255, 216, 152),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [
      0,
      0.31865,
      0.5038,
      0.71541,
      1,
    ],
    colors: [
      Color.fromARGB(255, 133, 102, 30),
      Color.fromARGB(0, 133, 101, 30),
      Color.fromARGB(0, 133, 101, 30),
      Color.fromARGB(67, 133, 101, 30),
      Color.fromARGB(255, 133, 101, 30),
    ],
  ),
  const LinearGradient(
    begin: Alignment(1, 0.5),
    end: Alignment(0.5857, 0.5),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(0, 255, 185, 53),
    ],
  )
];

List<Gradient> colorList2 = [
  const LinearGradient(
    begin: Alignment(0.52576, 0.80444),
    end: Alignment(0.52576, 0.20356),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 255, 228, 166),
      Color.fromARGB(255, 255, 216, 152),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [
      0,
      0.31865,
      0.5038,
      0.71541,
      1,
    ],
    colors: [
      Color.fromARGB(255, 185, 24, 4),
      Color.fromARGB(0, 255, 0, 0),
      Color.fromARGB(4, 255, 1, 1),
      Color.fromARGB(0, 243, 7, 1),
      Color.fromARGB(255, 200, 28, 3),
    ],
  ),
  const LinearGradient(
    begin: Alignment(1, 0.5),
    end: Alignment(0.5857, 0.5),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(0, 255, 185, 53),
    ],
  )
];

List<Gradient> colorList3 = [
  const LinearGradient(
    begin: Alignment(1, 0.5),
    end: Alignment(0, 0.5),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 161, 161, 161),
      Color.fromARGB(255, 255, 255, 255),
    ],
  ),
  const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [
      0,
      0.31865,
      0.5038,
      0.71541,
      1,
    ],
    colors: [
      Color.fromARGB(255, 97, 97, 97),
      Color.fromARGB(0, 67, 67, 67),
      Color.fromARGB(4, 255, 1, 1),
      Color.fromARGB(0, 243, 7, 1),
      Color.fromARGB(0, 200, 28, 3),
    ],
  ),
  const LinearGradient(
    begin: Alignment(1, 0.5),
    end: Alignment(0.5857, 0.5),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(0, 255, 255, 255),
    ],
  )
];

var bgColor1 = const LinearGradient(
  begin: Alignment(0.99899, 0.5),
  end: Alignment(0, 0.5),
  stops: [
    0,
    1,
  ],
  colors: [
    Color.fromARGB(255, 183, 145, 57),
    Color.fromARGB(255, 137, 106, 35),
  ],
);

var bgColor2 = const LinearGradient(
  begin: Alignment(1, 0.5),
  end: Alignment(0, 0.5),
  stops: [
    0,
    1,
  ],
  colors: [
    Color.fromARGB(255, 92, 8, 1),
    Color.fromARGB(255, 152, 20, 2),
  ],
);

var bgColor3 = const LinearGradient(
  begin: Alignment(1, 0.5),
  end: Alignment(0, 0.5),
  stops: [
    0,
    1,
  ],
  colors: [
    Color.fromARGB(255, 0, 0, 0),
    Color.fromARGB(255, 28, 28, 28),
  ],
);

var bgBorder1 = Border.all(
  width: 1,
  color: const Color.fromARGB(58, 92, 64, 18),
);

var bgBorder2 = Border.all(
  width: 1,
  color: const Color.fromARGB(69, 255, 124, 124),
);

var bgBorder3 = Border.all(
  width: 1,
  color: const Color.fromARGB(69, 113, 113, 113),
);

class ProgressPainterAnim extends StatefulWidget {
  final Gradient backgroundColor;
  final List<Gradient> colorList;
  final Border bgBorder;
  final double value;

  const ProgressPainterAnim(
      {super.key, required this.colorList,
      required this.backgroundColor,
      required this.value,
      required this.bgBorder});

  @override
  _ProgressPainterAnimState createState() => _ProgressPainterAnimState();
}

class _ProgressPainterAnimState extends State<ProgressPainterAnim>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: controller, curve: Curves.bounceInOut)
          ..addListener(() {
            setState(() {});
          });
    animation = Tween(begin: 0.0, end: widget.value).animate(curvedAnimation);
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: LayoutBuilder(
        builder: (context, size) {
          return SizedBox(
            width: size.maxWidth,
            child: CustomPaint(
              painter: ProgressPainter(
                colorList: widget.colorList,
                backgroundColor: widget.backgroundColor,
                bgBorder: widget.bgBorder,
                value: animation.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProgressPainter extends CustomPainter {
  final Gradient backgroundColor;
  final List<Gradient> colorList;
  final Border bgBorder;
  final double value;

  ProgressPainter(
      {required this.colorList,
      required this.backgroundColor,
      required this.value,
      required this.bgBorder});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    var radiusOut = size.height / 2;
    var radiusInner = size.height / 2;

    paint.shader = backgroundColor.createShader(Offset.zero & size);
    canvas.drawRRect(
        RRect.fromLTRBR(
            0, 0, size.width, size.height, Radius.circular(radiusOut)),
        paint);

    canvas.clipRRect(
      RRect.fromLTRBR(
          0, 0, size.width, size.height, Radius.circular(radiusOut)),
    );
    for (var element in colorList) {
      paint
        .shader = element
            .createShader(Offset.zero & Size(size.width * value, size.height));
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(0, -5, size.width * value, size.height + 5,
            topLeft: Radius.circular(radiusOut),
            bottomLeft: Radius.circular(radiusOut),
            topRight: Radius.circular(radiusInner),
            bottomRight: Radius.circular(radiusInner)),
        paint,
      );
    }

    bgBorder.paint(canvas, Offset.zero & size,
        borderRadius: BorderRadius.all(Radius.circular(radiusOut)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
