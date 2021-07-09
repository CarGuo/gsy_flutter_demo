import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///验证码输入框
class VerificationCodeInputDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("VerificationCodeInputDemoPage"),
      ),
      body: new GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          child: new Center(
            child: VerCodeInput(
              ctx: context,
              length: 6,
              keyboardType: TextInputType.number,
              builder: staticRectangle(context),
              onChanged: (value) {
                print(value);
              },

              ///输入完成时
              onFilled: (value) {
                //print('Your input is $value.');
              },
            ),
          ),
        ),
      ),
    );
  }

  staticRectangle(BuildContext context) {
    var codeSize = 6;
    double padding = 16;
    double width = MediaQuery.of(context).size.width;
    double codeFullSize = ((width - 2 * padding) / codeSize);
    double codeNormalSize = codeFullSize - 20;
    return CodeInputBuilders.rectangle(
        totalSize: Size(codeFullSize, codeFullSize),
        emptySize: Size(codeNormalSize, codeNormalSize),
        filledSize: Size(codeNormalSize, codeNormalSize),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
        color: Colors.transparent,
        textStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16.0,
            fontWeight: FontWeight.bold));
  }
}

///from https://github.com/tiny-express/flutter_verification_code_input/blob/master/lib/src/verification_code_input.dart

typedef CodeInputBuilder = Widget Function(bool hasFocus, String char);

class VerCodeInput extends StatefulWidget {
  const VerCodeInput._({
    Key? key,
    required this.length,
    required this.keyboardType,
    required this.inputFormatters,
    required this.builder,
    required this.ctx,
    this.onChanged,
    this.onFilled,
  }) : super(key: key);

  factory VerCodeInput({
    Key? key,
    required int length,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    BuildContext? ctx,
    required CodeInputBuilder builder,
    void Function(String value)? onChanged,
    void Function(String value)? onFilled,
  }) {
    assert(length > 0, 'The length needs to be larger than zero.');
    assert(length.isFinite, 'The length needs to be finite.');

    inputFormatters ??= _createInputFormatters(length, keyboardType);

    return VerCodeInput._(
      key: key,
      length: length,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      builder: builder,
      ctx: ctx,
      onChanged: onChanged,
      onFilled: onFilled,
    );
  }

  /// The length of character entities to always display.
  ///
  /// ## Sample code
  ///
  /// A code input with 4 characters:
  ///
  /// ```dart
  /// CodeInput(length: 4)
  /// ```
  final int length;

  /// The type of thconstard which shows up.
  ///
  /// ## Sample codeconst
  ///
  /// ```dart
  /// CodeInput(keyboardType: TextInputType.number)
  /// ```
  final TextInputType keyboardType;

  /// A list of input formatters which can validate the text as it is being
  /// typed.
  ///
  /// If you specify this parameter, the default input formatters aren't used,
  /// so make sure you really check for everything (like length of the input).
  ///
  /// ## Sample code
  ///
  /// An code input that displays a normal keyboard but only allows for
  /// hexadecimal input:
  ///
  /// ```dart
  /// CodeInput(
  ///   inputFormatters: [
  ///     WhitelistingTextInputFormatter(RegExp('^[0-9a-fA-F]*\$'))
  ///   ]
  /// )
  /// ```
  final List<TextInputFormatter> inputFormatters;

  /// A builder for the character entities.
  ///
  /// See [CodeInputBuilders] for examples.
  final CodeInputBuilder builder;

  /// A callback for changes to the input.
  final void Function(String value)? onChanged;

  /// A callback for when the input is filled.
  final void Function(String value)? onFilled;

  /// context parent because of MediaQuery.of(widget.ctx)
  final BuildContext? ctx;

  /// A helping function that creates input formatters for a given length and
  /// keyboardType.
  static List<TextInputFormatter> _createInputFormatters(
      int length, TextInputType keyboardType) {
    final formatters = <TextInputFormatter>[
      LengthLimitingTextInputFormatter(length)
    ];

    // Add keyboard specific formatters.
    // For example, a code input with a number keyboard type probably doesn't
    // want to allow decimal separators or signs.
    if (keyboardType == TextInputType.number) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    return formatters;
  }

  @override
  _VerCodeInputState createState() => _VerCodeInputState();
}

class _VerCodeInputState extends State<VerCodeInput> {
  final node = FocusNode();
  final controller = TextEditingController();

  String get text => controller.text;

  @override
  Widget build(BuildContext context) {
    // We'll display the visual widget and a not shown EditableText for doing
    // the actual work on top of each other.
    return Stack(children: <Widget>[
      // This is the actual EditableText wrapped in a Container with zero
      // dimensions.
      Container(
          width: 0.0,
          height: 0.0,
          child: EditableText(
            controller: controller,
            focusNode: node,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            backgroundCursorColor: Colors.black,
            style: TextStyle(),
            // Doesn't really matter.
            cursorColor: Colors.black,
            // Doesn't really matter.
            onChanged: (value) => setState(() {
              widget.onChanged?.call(value);
              if (value.length == widget.length) {
                widget.onFilled?.call(value);
              }
            }),
          )),
      // These are the actual character widgets. A transparent container lies
      // right below the gesture detector, so all taps get collected, even
      // the ones between the character entities.
      GestureDetector(
          onTap: () {
            if (MediaQuery.of(widget.ctx!).viewInsets.bottom == 0) {
              final focusScope = FocusScope.of(context);
              focusScope.requestFocus(FocusNode());
              Future.delayed(
                  Duration.zero, () => focusScope.requestFocus(node));
            }
          },
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.length, (i) {
                final hasFocus = controller.selection.start == i;
                final char = i < text.length ? text[i] : '';
                final characterEntity = widget.builder(hasFocus, char);


                return characterEntity;
              }),
            ),
          )),
    ]);
  }
}

/// An abstract class that provides some commonly-used builders for the
/// character entities.
///
/// * [containerized]: A builder putting chars in an animated container.
/// * [circle]: A builder putting chars in circles.
/// * [rectangle]: A builder putting chars in rectangles.
/// * [lightCircle]: A builder putting chars in light circles.
/// * [darkCircle]: A builder putting chars in dark circles.
/// * [lightRectangle]: A builder putting chars in light rectangles.
/// * [darkRectangle]: A builder putting chars in dark rectangles.
abstract class CodeInputBuilders {
  /// Builds the input inside an animated container.
  static CodeInputBuilder containerized({
    Duration animationDuration = const Duration(milliseconds: 50),
    required Size totalSize,
    required Size emptySize,
    required Size filledSize,
    required BoxDecoration emptyDecoration,
    required BoxDecoration filledDecoration,
    required TextStyle emptyTextStyle,
    required TextStyle filledTextStyle,
  }) {
    return (bool hasFocus, String char) => Container(
        width: totalSize.width,
        height: totalSize.height,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          decoration: char.isEmpty ? emptyDecoration : filledDecoration,
          width: char.isEmpty ? emptySize.width : filledSize.width,
          height: char.isEmpty ? emptySize.height : filledSize.height,
          alignment: Alignment.center,
          child: Text(char,
              style: char.isEmpty ? emptyTextStyle : filledTextStyle),
        ));
  }

  /// Builds the input inside a circle.
  static CodeInputBuilder circle(
      {double totalRadius = 30.0,
      double emptyRadius = 10.0,
      double filledRadius = 25.0,
      required Border border,
      required Color color,
      required TextStyle textStyle}) {
    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      border: border,
      color: color,
    );

    return containerized(
        totalSize: Size.fromRadius(totalRadius),
        emptySize: Size.fromRadius(emptyRadius),
        filledSize: Size.fromRadius(filledRadius),
        emptyDecoration: decoration,
        filledDecoration: decoration,
        emptyTextStyle: textStyle.copyWith(fontSize: 0.0),
        filledTextStyle: textStyle);
  }

  /// Builds the input inside a rectangle.
  static CodeInputBuilder rectangle({
    Size totalSize = const Size(50.0, 60.0),
    Size emptySize = const Size(20.0, 20.0),
    Size filledSize = const Size(40.0, 60.0),
    BorderRadius borderRadius = BorderRadius.zero,
    required Border border,
    required Color color,
    required TextStyle textStyle,
  }) {
    final decoration = BoxDecoration(
      border: border,
      borderRadius: borderRadius,
      color: color,
    );

    return containerized(
        totalSize: totalSize,
        emptySize: emptySize,
        filledSize: filledSize,
        emptyDecoration: decoration,
        filledDecoration: decoration,
        emptyTextStyle: textStyle.copyWith(fontSize: 0.0),
        filledTextStyle: textStyle);
  }

  /// Builds the input inside a light circle.
  static CodeInputBuilder lightCircle({
    double totalRadius = 30.0,
    double emptyRadius = 10.0,
    double filledRadius = 25.0,
  }) {
    return circle(
        totalRadius: totalRadius,
        emptyRadius: emptyRadius,
        filledRadius: filledRadius,
        border: Border.all(color: Colors.white, width: 2.0),
        color: Colors.white10,
        textStyle: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  /// Builds the input inside a light circle.
  static CodeInputBuilder darkCircle({
    double totalRadius = 30.0,
    double emptyRadius = 10.0,
    double filledRadius = 25.0,
  }) {
    return circle(
        totalRadius: totalRadius,
        emptyRadius: emptyRadius,
        filledRadius: filledRadius,
        border: Border.all(color: Colors.black, width: 2.0),
        color: Colors.black12,
        textStyle: TextStyle(
            color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  /// Builds the input inside a light rectangle.
  static CodeInputBuilder lightRectangle({
    Size totalSize = const Size(50.0, 60.0),
    Size emptySize = const Size(20.0, 20.0),
    Size filledSize = const Size(40.0, 60.0),
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    return rectangle(
        totalSize: totalSize,
        emptySize: emptySize,
        filledSize: filledSize,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.white, width: 2.0),
        color: Colors.white10,
        textStyle: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  static CodeInputBuilder staticRectangle({
    Size totalSize = const Size(60.0, 60.0),
    Size emptySize = const Size(40.0, 40.0),
    Size filledSize = const Size(40.0, 40.0),
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    return rectangle(
        totalSize: totalSize,
        emptySize: emptySize,
        filledSize: filledSize,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.white, width: 1.0),
        color: Colors.transparent,
        textStyle: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  /// Builds the input inside a dark rectangle.
  static CodeInputBuilder darkRectangle({
    Size totalSize = const Size(50.0, 60.0),
    Size emptySize = const Size(20.0, 20.0),
    Size filledSize = const Size(40.0, 60.0),
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    return rectangle(
        totalSize: totalSize,
        emptySize: emptySize,
        filledSize: filledSize,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.black, width: 2.0),
        color: Colors.black12,
        textStyle: TextStyle(
            color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold));
  }
}
