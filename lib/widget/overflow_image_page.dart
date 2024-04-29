import 'package:flutter/material.dart';

/// 圆角效果处理实现
class OverflowImagePage extends StatelessWidget {
  const OverflowImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OverflowImagePage"),
      ),
      body: ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          ///第二个Item
          if (index == 1) {
            return Container(
              color: Colors.blue,
              height: MediaQuery.sizeOf(context).height,
            );
          }

          ///广告图 Item
          return SizedBox(
            height: 100,
            child: OverflowBox(
                alignment: Alignment.center,
                maxHeight: MediaQuery.sizeOf(context).height,
                child: Image(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).width * 220 / 247,
                  image: const AssetImage("static/gsy_cat.png"),
                  fit: BoxFit.fill,
                )),
          );
        },
        itemCount: 2,
      ),
    );
  }
}
