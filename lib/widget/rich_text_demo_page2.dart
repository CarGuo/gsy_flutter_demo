import 'package:flutter/material.dart';

class RichTextDemoPage2 extends StatefulWidget {
  const RichTextDemoPage2({super.key});

  @override
  _RichTextDemoState2 createState() => _RichTextDemoState2();
}

class _RichTextDemoState2 extends State<RichTextDemoPage2> {
  double size = 50;

  @override
  Widget build(BuildContext mainContext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RichTextDemoPage"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                size += 10;
              });
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                size -= 10;
              });
            },
            icon: const Icon(Icons.remove_circle_outline),
          )
        ],
      ),
      body: SelectionArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Builder(builder: (context) {
            return Center(
              child: Text.rich(TextSpan(
                children: <InlineSpan>[
                  const TextSpan(text: 'Flutter is'),
                  const WidgetSpan(
                      child: SizedBox(
                    width: 120,
                    height: 50,
                    child: Card(
                        color: Colors.blue,
                        child: Center(child: Text('Hello World!'))),
                  )),
                  WidgetSpan(
                      child: SizedBox(
                    width: size > 0 ? size : 0,
                    height: size > 0 ? size : 0,
                    child: Image.asset(
                      "static/gsy_cat.png",
                      fit: BoxFit.cover,
                    ),
                  )),
                  const TextSpan(text: 'the best!'),
                  const WidgetSpan(
                    child: SelectionContainer.disabled(
                      child: Text(' not copy'),
                    ),
                  ),
                ],
              )),
            );
          }),
        ),
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
