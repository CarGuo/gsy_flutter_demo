import 'package:flutter/material.dart';

class CardItemPage extends StatelessWidget {
  const CardItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text("CardItemPage"),
      ),
      body: Column(children: <Widget>[
        renderImageNormal("static/gsy_cat.png"),
        renderImageRatio(context, "static/gsy_cat.png"),
        renderImageNormal("static/test.jpeg"),
        renderImageRatio(context, "static/test.jpeg"),
      ]),
    );
  }

  renderImageNormal(image) {
    return Card(
      margin: const EdgeInsets.all(5),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4.0),
                bottomLeft: Radius.circular(4.0),
              ),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                width: 70,
                height: 70,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Expanded(
                child: Text(
              'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'
              'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'
              'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15),
            )),
          ],
        ),
      ),
    );
  }

  renderImageRatio(context, image) {
    ///大概是屏幕 6 分之一的宽度
    double itemHeight = MediaQuery.sizeOf(context).width / 6;

    /// iphone xs max 的比例是 2688 * 1242; 拿到的 size 是 896.0 * 414.0
    double textSize = 15.0 * MediaQuery.sizeOf(context).width / 414.0;

    /// 注意，这是在 data.textScaleFactor = 1 的情况下
    //var data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    return Card(
      margin: const EdgeInsets.all(5),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4.0),
                bottomLeft: Radius.circular(4.0),
              ),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                height: itemHeight,
                width: itemHeight,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text(
              'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'
              'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'
              'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: textSize),
            )),
          ],
        ),
      ),
    );
  }
}
