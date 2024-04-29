import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/rich/real_rich_text.dart';

class RichTextDemoPage extends StatefulWidget {
  const RichTextDemoPage({super.key});

  @override
  _RichTextDemoState createState() => _RichTextDemoState();
}

class _RichTextDemoState extends State<RichTextDemoPage> {
  @override
  Widget build(BuildContext mainContext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RichTextDemoPage"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Builder(builder: (context) {
          return Center(
            child: RealRichText([
              TextSpan(
                text: "A Text Link",
                style: const TextStyle(color: Colors.red, fontSize: 14),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    show(context, "Link Clicked.");
                  },
              ),
              ImageSpan(
                const AssetImage("static/gsy_cat.png"),
                imageWidth: 24,
                imageHeight: 24,
              ),
              ImageSpan(const AssetImage("static/gsy_cat.png"),
                  imageWidth: 24,
                  imageHeight: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 10)),
              const TextSpan(
                text: "哈哈哈",
                style: TextStyle(color: Colors.yellow, fontSize: 14),
              ),
              TextSpan(
                text: "@Somebody",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    show(context, "Link Clicked.");
                  },
              ),
              TextSpan(
                text: " #RealRichText# ",
                style: const TextStyle(color: Colors.blue, fontSize: 14),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    show(context, "Link Clicked.");
                  },
              ),
              const TextSpan(
                text: "showing a bigger image",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              ImageSpan(const AssetImage("static/gsy_cat.png"),
                  imageWidth: 24,
                  imageHeight: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 5)),
              const TextSpan(
                text: "and seems working perfect……",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ]),
          );
        }),
      ),
    );
  }

  show(context, text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: 'ACTION',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You pressed snackbar\'s action.'),
          ));
        },
      ),
    ));
  }
}
