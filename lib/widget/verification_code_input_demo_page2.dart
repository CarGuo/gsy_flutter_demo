import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///验证码输入框
class VerificationCodeInputDemoPage2 extends StatefulWidget {
  @override
  _VerificationCodeInputDemoPage2State createState() =>
      _VerificationCodeInputDemoPage2State();
}

class _VerificationCodeInputDemoPage2State
    extends State<VerificationCodeInputDemoPage2> {
  var focusNode = new FocusNode();
  var textEditingController = TextEditingController();

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
          alignment: Alignment.center,
          child: PINInputWidget(
              title: "支付",
              tipTitle: "支付",
              needTip: true,
              node: focusNode,
              textEditingController: textEditingController,
              onChanged: (value) {}),
        ),
      ),
    );
  }
}

///PIN 码输入控件
class PINInputWidget extends StatelessWidget {
  final String title;
  final String? tipTitle;
  final bool needTip;

  final void Function(String value)? onChanged;

  final void Function(String value)? onFilled;

  final GlobalKey tipGlobalKey = new GlobalKey();
  final TextEditingController? textEditingController;
  final FocusNode? node;
  final EdgeInsetsGeometry? margin;

  PINInputWidget(
      {this.title = "",
      this.tipTitle,
      this.onChanged,
      this.onFilled,
      this.textEditingController,
      this.node,
      this.margin,
      this.needTip = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
          margin: margin ?? EdgeInsets.only(left: 50, right: 50),
          child: new Row(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              new Expanded(child: new Container()),
              if (needTip)
                Text(tipTitle!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    )),
            ],
          ),
        ),
        new Container(
          margin: EdgeInsets.only(top: 5),
          child: VerCodeInput(
            controller: textEditingController,
            length: 6,
            keyboardType: TextInputType.number,
            builder: pinRectangle(context, edgeInsets: margin),
            node: node,
            onChanged: onChanged,

            ///输入完成时
            onFilled: onFilled ??
                (value) {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
          ),
        )
      ],
    );
  }
}

///PIN码输入框样式
CodeInputBuilder pinRectangle(BuildContext context,
    {EdgeInsetsGeometry? edgeInsets, bool needApex = true}) {
  var codeSize = 6;
  var padding = 50.0;
  if (edgeInsets?.horizontal != null) {
    padding = edgeInsets!.horizontal / 2;
  }

  double width = MediaQuery.of(context).size.width;
  double codeFullSize = ((width - 2 * padding) / codeSize);
  double codeNormalSize = codeFullSize;
  final textStyle =
      TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);
  return _pinContainerized(
      totalSize: Size(codeFullSize, codeFullSize),
      emptySize: Size(codeNormalSize, codeNormalSize),
      filledSize: Size(codeNormalSize, codeNormalSize),
      color: Colors.transparent,
      filledTextStyle: textStyle,
      emptyTextStyle: textStyle.copyWith(fontSize: 0.0));
}

CodeInputBuilder _pinContainerized(
    // ignore: unused_element
    {Duration animationDuration = const Duration(milliseconds: 50),
    required Size totalSize,
    required Size emptySize,
    required Size filledSize,
    required TextStyle emptyTextStyle,
    required TextStyle filledTextStyle,
    required Color color}) {
  final width = 0.5;
  final borderRadiusSize = Radius.circular(4);

  final borderColor = Color.fromARGB(255, 151, 151, 151);

  final decoration = BoxDecoration(
    border: Border(
      top: BorderSide(width: width, color: borderColor),
      left: BorderSide(width: width, color: borderColor),
      right: BorderSide.none,
      bottom: BorderSide(width: width, color: borderColor),
    ),
    color: color,
  );

  ///因为有 borderRadius 的不能 BorderSide 不同
  final decorationSecond = BoxDecoration(
    border: Border(
      top: BorderSide(width: width, color: borderColor),
      left: BorderSide.none,
      right: BorderSide.none,
      bottom: BorderSide(width: width, color: borderColor),
    ),
    color: color,
  );

  ///开始带弧度的 border
  final decorationStart = BoxDecoration(
    border: Border(
      top: BorderSide(width: width, color: borderColor),
      left: BorderSide(width: width, color: borderColor),
      right: BorderSide(width: width, color: borderColor),
      bottom: BorderSide(width: width, color: borderColor),
    ),
    borderRadius: BorderRadius.only(
        topLeft: borderRadiusSize, bottomLeft: borderRadiusSize),
    color: color,
  );

  ///结束带弧度的 border
  final decorationEnd = BoxDecoration(
    border: Border(
      top: BorderSide(width: width, color: borderColor),
      left: BorderSide(width: width, color: borderColor),
      right: BorderSide(width: width, color: borderColor),
      bottom: BorderSide(width: width, color: borderColor),
    ),
    borderRadius: BorderRadius.only(
        topRight: borderRadiusSize, bottomRight: borderRadiusSize),
    color: color,
  );

  getDecoration(int index) {
    if (index == 0) {
      return decorationStart;
    } else if (index == 1) {
      return decorationSecond;
    } else if (index == 5) {
      return decorationEnd;
    }
    return decoration;
  }

  return (bool hasFocus, String char, index) => Container(
      width: totalSize.width,
      height: totalSize.height,
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: getDecoration(index),
        width: char.isEmpty ? emptySize.width : filledSize.width,
        height: char.isEmpty ? emptySize.height : filledSize.height,
        alignment: Alignment.center,
        child:
            Text("•", style: char.isEmpty ? emptyTextStyle : filledTextStyle),
      ));
}

///PIN码输入框样式，底部线条
CodeInputBuilder pinLine(BuildContext context) {
  var codeSize = 4;
  double width = MediaQuery.of(context).size.width / 2;
  double codeFullSize = ((width) / codeSize);
  double codeNormalSize = codeFullSize - 10;
  return CodeInputBuilders.rectangle(
      totalSize: Size(codeFullSize, codeFullSize),
      emptySize: Size(codeNormalSize, codeNormalSize),
      filledSize: Size(codeNormalSize, codeNormalSize),
      borderRadius: null,
      alignment: Alignment.centerLeft,
      border: Border(
          bottom:
              BorderSide(color: Theme.of(context).primaryColor, width: 0.5)),
      color: Colors.transparent,
      textStyle: TextStyle(
          color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold));
}

renderTipIcon(BuildContext context, String title, GlobalKey key,
    {expanded = true, double? width, bool needIcon = true}) {
  var titleWidget = new Container(
      alignment: Alignment.centerLeft,
      child: new RichText(
        text: new TextSpan(
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            text: title,
            children: [
              new TextSpan(
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  text: "  "),
            ]),
      ));
  if (!needIcon) {
    return titleWidget;
  }
  return new Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      titleWidget,
      new Container(
        alignment: Alignment.topLeft,
        child: InkWell(
          onTap: () {
//              double top =
//                  MediaQueryData.fromWindow(WidgetsBinding.instance.window)
//                      .padding
//                      .top;
//              RenderBox renderBoxRed = key.currentContext.findRenderObject();
//              Offset offset = renderBoxRed.localToGlobal(Offset.zero);
//              showPasswordTip(context, offset.dx + 7, offset.dy - top + 14);
          },
          child: new Icon(
            Icons.error,
            key: key,
            color: Colors.black,
            size: 14,
          ),
        ),
      ),
    ],
  );
}

class UpWhitelistingTextInputFormatter extends TextInputFormatter {
  /// Creates a formatter that allows only the insertion of whitelisted characters patterns.
  ///
  /// The [whitelistedPattern] must not be null.
  UpWhitelistingTextInputFormatter(this.whitelistedPattern);

  /// A [Pattern] to extract all instances of allowed characters.
  ///
  /// [RegExp] with multiple groups is not supported.
  final Pattern whitelistedPattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    return _selectionAwareTextManipulation(
      oldValue,
      newValue,
      (String substring) {
        var result = whitelistedPattern
            .allMatches(substring.toUpperCase())
            .map<String?>((Match match) => match.group(0))
            .join();
        if (result.length > 0) {
          return result;
        }
        return "";
      },
    );
  }

  /// A [FilteringTextInputFormatter] that takes in digits `[0-9]` only.
  static final FilteringTextInputFormatter digitsOnly =
      FilteringTextInputFormatter.allow(RegExp(r'\d+'));

  TextEditingValue _selectionAwareTextManipulation(
    TextEditingValue old,
    TextEditingValue value,
    String substringManipulation(String substring),
  ) {
    if (value.text.length != 0 &&
        substringManipulation(value.text).length == 0) {
      return old;
    }
    final int selectionStartIndex = value.selection.baseOffset;
    final int selectionEndIndex = value.selection.extentOffset;
    String manipulatedText;
    TextSelection? manipulatedSelection;
    if (selectionStartIndex < 0 || selectionEndIndex < 0) {
      manipulatedText = substringManipulation(value.text);
    } else {
      final String beforeSelection =
          substringManipulation(value.text.substring(0, selectionStartIndex));
      final String inSelection = substringManipulation(
          value.text.substring(selectionStartIndex, selectionEndIndex));
      final String afterSelection =
          substringManipulation(value.text.substring(selectionEndIndex));
      manipulatedText = beforeSelection + inSelection + afterSelection;
      if (value.selection.baseOffset > value.selection.extentOffset) {
        manipulatedSelection = value.selection.copyWith(
          baseOffset: beforeSelection.length + inSelection.length,
          extentOffset: beforeSelection.length,
        );
      } else {
        manipulatedSelection = value.selection.copyWith(
          baseOffset: beforeSelection.length,
          extentOffset: beforeSelection.length + inSelection.length,
        );
      }
    }
    return TextEditingValue(
      text: manipulatedText,
      selection:
          manipulatedSelection ?? const TextSelection.collapsed(offset: -1),
      composing:
          manipulatedText == value.text ? value.composing : TextRange.empty,
    );
  }
}

typedef CodeInputBuilder = Widget Function(
    bool hasFocus, String char, int index);

class VerCodeInput extends StatefulWidget {
  const VerCodeInput._({
    Key? key,
    required this.length,
    required this.keyboardType,
    required this.inputFormatters,
    required this.builder,
    this.onChanged,
    this.controller,
    this.onFilled,
    this.node,
  }) : super(key: key);

  factory VerCodeInput({
    Key? key,
    required int length,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required CodeInputBuilder builder,
    void Function(String value)? onChanged,
    void Function(String value)? onFilled,
    TextEditingController? controller,
    FocusNode? node,
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
      onChanged: onChanged,
      onFilled: onFilled,
      node: node,
      controller: controller ?? TextEditingController(),
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

  final TextEditingController? controller;
  final FocusNode? node;

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
  final nodeInner = FocusNode();

  String get text => widget.controller!.text;

  @override
  void initState() {
    super.initState();
    widget.controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

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
            controller: widget.controller!,
            focusNode: widget.node ?? nodeInner,
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
            final focusScope = FocusScope.of(context);
            focusScope.requestFocus(FocusNode());
            Future.delayed(Duration.zero,
                () => focusScope.requestFocus(widget.node ?? nodeInner));
          },
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.length, (i) {
                final hasFocus = widget.controller!.selection.baseOffset == i;
                final char = i < text.length ? text[i] : '';
                final characterEntity = widget.builder(hasFocus, char, i);
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
    Alignment alignment: Alignment.center,
  }) {
    return (bool hasFocus, String char, int index) => Container(
        width: totalSize.width,
        height: totalSize.height,
        alignment: alignment,
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
    BorderRadius? borderRadius = BorderRadius.zero,
    required Border border,
    required Color color,
    required TextStyle textStyle,
    Alignment alignment: Alignment.center,
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
        alignment: alignment,
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
