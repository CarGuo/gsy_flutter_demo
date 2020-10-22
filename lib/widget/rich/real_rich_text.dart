import 'dart:ui' as ui show Image;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// According to the related Flutter Issues(#2022) ,
/// Inline-Image-In-Text is a long-time(2 years) missing feature since RichText(or the underlying Paragraph) does only support pure text.
/// But we can solve this problem in a simple/tricky way:
///
/// 1. Regarde the images as a particular blank TextSpan,
///   convert image's width and height to textspan's letterSpacing and fontSize.
///   the origin paragraph will do the layout operation and leave the desired image space for us.
/// 2. Override the paint function，
///   calculate the right offset via the getOffsetForCaret() api to draw the image over the space.
///
/// The only thing you have to do is converting your origin text to a TextSpan/ImageSpan List first.
///
/// {@tool sample}
///
/// ```dart
/// RealRichText([
///            TextSpan(
///              text: "showing a bigger image",
///              style: TextStyle(color: Colors.black, fontSize: 14),
///            ),
///            ImageSpan(
///              AssetImage("packages/real_rich_text/images/emoji_10.png"),
///              width: 40,
///              height: 40,
///            ),
///            TextSpan(
///              text: "and seems working perfect……",
///              style: TextStyle(color: Colors.black, fontSize: 14),
///            ),
///          ])
/// ```
/// {@end-tool}
///
class RealRichText extends Text {
  final List<TextSpan> textSpanList;

  RealRichText(
    this.textSpanList, {
    Key key,
    TextStyle style,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int maxLines,
    Locale locale,
  }) : super("",
            style: style,
            textAlign: textAlign,
            textDirection: textDirection,
            softWrap: softWrap,
            overflow: overflow,
            textScaleFactor: textScaleFactor,
            maxLines: maxLines,
            locale: locale);

  List<TextSpan> extractAllNestedChildren(TextSpan textSpan) {
    if (textSpan.children == null || textSpan.children.length == 0) {
      return [textSpan];
    }
    List<TextSpan> childrenSpan = [];
    textSpan.children.forEach((child) {
      childrenSpan.addAll(extractAllNestedChildren(child));
    });
    return childrenSpan;
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = style;
    if (style == null || style.inherit)
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    if (MediaQuery.boldTextOverride(context))
      effectiveTextStyle = effectiveTextStyle
          .merge(TextStyle(fontWeight: FontWeight.bold));

    TextSpan textSpan = TextSpan(
        style: effectiveTextStyle,
        text: "",
        children: extractAllNestedChildren(TextSpan(
          style: effectiveTextStyle,
          text: "",
          children: textSpanList,
        )));

    // pass the context to ImageSpan to create a ImageConfiguration
    textSpan.children.forEach((f) {
      if (f is ImageSpan) {
        f.updateImageConfiguration(context);
      }
    });

    Widget result = _RichTextWrapper(
        textAlign: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
        textDirection: textDirection,
        // RichText uses Directionality.of to obtain a default if this is null.
        locale: locale,
        // RichText uses Localizations.localeOf to obtain a default if this is null
        softWrap: softWrap ?? defaultTextStyle.softWrap,
        overflow: overflow ?? defaultTextStyle.overflow,
        textScaleFactor:
            textScaleFactor ?? MediaQuery.textScaleFactorOf(context),
        maxLines: maxLines ?? defaultTextStyle.maxLines,
        text: textSpan);
    if (semanticsLabel != null) {
      result = Semantics(
          textDirection: textDirection,
          label: semanticsLabel,
          child: ExcludeSemantics(
            child: result,
          ));
    }
    return result;
  }
}

/// Since flutter engine does not support inline-image for now, we have to support this feature via a tricky solution:
/// convert image to a particular TextSpan whose text always be \u200B(a zero-width-space).
/// set letterSpacing by the required image width
/// set fontSize by the required image height
class ImageSpan extends TextSpan {
  final double imageWidth;
  final double imageHeight;
  final EdgeInsets margin;
  final ImageProvider imageProvider;
  final ImageResolver imageResolver;

  ImageSpan(
    this.imageProvider, {
    this.imageWidth = 14.0,
    this.imageHeight = 14.0,
    this.margin,
    GestureRecognizer recognizer,
  })  : imageResolver = ImageResolver(imageProvider),
        super(
            style: TextStyle(
                color: Colors.transparent,
                letterSpacing:
                    imageWidth + (margin == null ? 0 : margin.horizontal),
                height: 1,
                fontSize: (imageHeight / 1.15) +
                    (margin == null ? 0 : margin.vertical)),
            text: "\u200B",
            children: [],
            recognizer: recognizer);

  void updateImageConfiguration(BuildContext context) {
    imageResolver.updateImageConfiguration(context, imageWidth, imageHeight);
  }

  double get width => imageWidth + (margin == null ? 0 : margin.horizontal);

  double get height => imageHeight + (margin == null ? 0 : margin.vertical);
}

typedef ImageResolverListener = void Function(
    ImageInfo imageInfo, bool synchronousCall);

class ImageResolver {
  final ImageProvider imageProvider;

  ImageStream _imageStream;
  ImageConfiguration _imageConfiguration;
  ui.Image image;
  ImageResolverListener _listener;

  ImageResolver(this.imageProvider);

  /// set the ImageConfiguration from outside
  void updateImageConfiguration(
      BuildContext context, double width, double height) {
    _imageConfiguration = createLocalImageConfiguration(
      context,
      size: Size(width, height),
    );
  }

  ImageStreamListener imageStreamListener;

  void resolve(ImageResolverListener listener) {
    assert(_imageConfiguration != null);

    final ImageStream oldImageStream = _imageStream;
    _imageStream = imageProvider.resolve(_imageConfiguration);
    assert(_imageStream != null);

    this._listener = listener;
    if (_imageStream.key != oldImageStream?.key) {
      if (imageStreamListener != null) {
        oldImageStream?.removeListener(imageStreamListener);
      }
      imageStreamListener ??= new ImageStreamListener(_handleImageChanged);
      _imageStream.addListener(imageStreamListener);
    }
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    image = imageInfo.image;
    _listener?.call(imageInfo, synchronousCall);
  }

  void addListening() {
    if (this._listener != null) {
      imageStreamListener ??= new ImageStreamListener(_handleImageChanged);
      _imageStream?.addListener(imageStreamListener);
    }
  }

  void stopListening() {
    if (imageStreamListener != null) {
      _imageStream?.removeListener(imageStreamListener);
    }
  }
}

/// Just a subclass of RichText for overriding createRenderObject
/// to return a [_RealRichRenderParagraph] object
///
/// No more special purpose.
class _RichTextWrapper extends RichText {
  _RichTextWrapper({
    Key key,
    @required TextSpan text,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    double textScaleFactor = 1.0,
    int maxLines,
    Locale locale,
  })  : assert(text != null),
        assert(textAlign != null),
        assert(softWrap != null),
        assert(overflow != null),
        assert(textScaleFactor != null),
        assert(maxLines == null || maxLines > 0),
        super(
            key: key,
            text: text,
            textAlign: textAlign,
            textDirection: textDirection,
            softWrap: softWrap,
            overflow: overflow,
            textScaleFactor: textScaleFactor,
            maxLines: maxLines,
            locale: locale);

  @override
  RenderParagraph createRenderObject(BuildContext context) {
    assert(textDirection != null || debugCheckHasDirectionality(context));
    return _RealRichRenderParagraph(
      text,
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      locale: locale ?? Localizations.localeOf(context, nullOk: true),
    );
  }
}

/// paint the image on the top of those ImageSpan's blank space
class _RealRichRenderParagraph extends RenderParagraph {
  _RealRichRenderParagraph(TextSpan text,
      {TextAlign textAlign,
      TextDirection textDirection,
      bool softWrap,
      TextOverflow overflow,
      double textScaleFactor,
      int maxLines,
      Locale locale})
      : super(
          text,
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          locale: locale,
        );

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    // Here it is!
    paintImageSpan(context, offset);
  }

  @override
  void attach(covariant Object owner) {
    super.attach(owner);
    text.children.forEach((textSpan) {
      if (textSpan is ImageSpan) {
        textSpan.imageResolver.addListening();
      }
    });
  }

  @override
  void detach() {
    super.detach();
    text.children.forEach((textSpan) {
      if (textSpan is ImageSpan) {
        textSpan.imageResolver.stopListening();
      }
    });
  }

  @override
  void performLayout() {
    super.performLayout();

    debugPrint("size = $size");
  }

  /// this method draws inline-image over blank text space.
  void paintImageSpan(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Rect bounds = offset & size;

    debugPrint("_RealRichRenderParagraph offset=$offset bounds=$bounds");

    canvas.save();

    int textOffset = 0;
    for (TextSpan textSpan in text.children) {
      if (textSpan is ImageSpan) {
        // this is the top-center point of the ImageSpan
        Offset offsetForCaret = getOffsetForCaret(
          TextPosition(offset: textOffset),
          bounds,
        );

        // found this is a overflowed image. ignore it
        if (textOffset != 0 &&
            offsetForCaret.dx == 0 &&
            offsetForCaret.dy == 0) {
          return;
        }

        // this is the top-left point of the ImageSpan.
        // Usually, offsetForCaret indicates the top-center offset
        // except the first text which is always (0, 0)
        Offset topLeftOffset = Offset(
            offset.dx +
                offsetForCaret.dx -
                (textOffset == 0 ? 0 : textSpan.width / 2),
            offset.dy + offsetForCaret.dy);
        debugPrint(
            "_RealRichRenderParagraph ImageSpan, textOffset = $textOffset, offsetForCaret=$offsetForCaret, topLeftOffset=$topLeftOffset");

        // if image is not ready: wait for async ImageInfo
        if (textSpan.imageResolver.image == null) {
          textSpan.imageResolver.resolve((imageInfo, synchronousCall) {
            if (synchronousCall) {
              paintImage(
                  canvas: canvas,
                  rect: topLeftOffset & Size(textSpan.width, textSpan.height),
                  image: textSpan.imageResolver.image,
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center);
            } else {
              if (owner == null || !owner.debugDoingPaint) {
                markNeedsPaint();
              }
            }
          });
          textOffset += textSpan.toPlainText().length;
          continue;
        }
        // else: just paint it. bottomCenter Alignment seems better...
        paintImage(
            canvas: canvas,
            rect: topLeftOffset & Size(textSpan.width, textSpan.height),
            image: textSpan.imageResolver.image,
            fit: BoxFit.scaleDown,
            alignment: Alignment.center);
      }
      textOffset += textSpan.toPlainText().length;
    }

    canvas.restore();
  }
}
