import 'package:flutter/material.dart';

class AnimaDemoPage4 extends StatefulWidget {
  @override
  _AnimaDemoPageState createState() => _AnimaDemoPageState();
}

class _AnimaDemoPageState extends State<AnimaDemoPage4> {
  IconData iconData = Icons.clear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AnimaDemoPage4'),
        actions: <Widget>[
          AnimatedSwitcher(
            transitionBuilder: (child, anim) {
              return ScaleTransition(child: child, scale: anim);
            },
            duration: Duration(milliseconds: 300),
            child: IconButton(
                key: ValueKey(iconData),
                icon: Icon(iconData),
                onPressed: () {
                  setState(() {
                    if (iconData == Icons.clear)
                      iconData = Icons.add;
                    else
                      iconData = Icons.clear;
                  });
                }),
          )
        ],
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (iconData == Icons.clear)
              iconData = Icons.add;
            else
              iconData = Icons.clear;
          });
        },
        child: AnimatedSwitcher(
          transitionBuilder: (child, anim) {
            return ScaleTransition(child: child, scale: anim);
          },
          duration: Duration(milliseconds: 300),
          child: IconButton(
              key: ValueKey(iconData),
              icon: Icon(iconData),
              onPressed: () {
                setState(() {
                  if (iconData == Icons.clear)
                    iconData = Icons.add;
                  else
                    iconData = Icons.clear;
                });
              }),
        ),
      ),
    );
  }
}
