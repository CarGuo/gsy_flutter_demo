import 'package:flutter/material.dart';

class RichTextDemoPage2 extends StatefulWidget {
  @override
  _RichTextDemoState2 createState() => _RichTextDemoState2();
}

class _RichTextDemoState2 extends State<RichTextDemoPage2> {
  double size = 50;

  @override
  Widget build(BuildContext mainContext) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("RichTextDemoPage"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                size += 10;
              });
            },
            icon: Icon(Icons.add_circle_outline),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                size -= 10;
              });
            },
            icon: Icon(Icons.remove_circle_outline),
          )
        ],
      ),
      body: SelectionArea(
        child: new Container(
          margin: EdgeInsets.all(10),
          child: Builder(builder: (context) {
            return Center(
              child: Text.rich(TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: 'Flutter is'),
                  WidgetSpan(
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
                    child: new Image.asset(
                      "static/gsy_cat.png",
                      fit: BoxFit.cover,
                    ),
                  )),
                  TextSpan(text: 'the best!'),
                  WidgetSpan(
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('You pressed snackbar\'s action.'),
          ));
        },
      ),
    ));
  }
}
