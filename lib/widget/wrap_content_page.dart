import 'package:flutter/material.dart';

///展示如何在 Flutter 里实现 WrapContent 的状态
class WrapContentPage extends StatelessWidget {
  const WrapContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WrapContentPage",
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints:

              ///关键就是 minHeight 和  double.infinity
              ///这样就可以由内部 children 来支撑决定外部大小
              const BoxConstraints(minHeight: 100, maxHeight: double.infinity),
          child: Column(
            ///min而不是max
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                ///关键就是 minHeight 和  double.infinity
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: double.infinity,
                ),

                /// Stack 默认是 StackFit.loose, 需要内部一个固定的最大大小来支撑
                child: Stack(
                  children: [
                    Container(
                      height: 400,
                      color: Colors.yellow,
                    ),
                    Container(
                      height: 50,
                      color: Colors.red,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        height: 56,
                        alignment: Alignment.centerLeft,
                        color: Colors.blueGrey,
                        child: Container(
                          width: 33,
                          height: 33,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),

                ///关键就是 minHeight 和  double.infinity
                constraints:
                    const BoxConstraints(minHeight: 100, maxHeight: double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 600,
                      color: Colors.green,
                    ),
                    Container(
                      height: 50,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
