import 'dart:math' as math;
import 'package:flutter/material.dart';

class AlignDemoPage extends StatefulWidget {
  const AlignDemoPage({super.key});

  @override
  AlignDemoPageState createState() => AlignDemoPageState();
}

class AlignDemoPageState extends State<AlignDemoPage>
    with SingleTickerProviderStateMixin {
  getAlign(x) {
    return Align(
      alignment: Alignment(math.cos(x * math.pi), math.sin(x * math.pi)),
      child: Container(
        height: 20,
        width: 20,
        decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int size = 20;
    return Scaffold(
      appBar: AppBar(
        title: const Text("AlignDemoPage"),
      ),
      body: Container(
        alignment: const Alignment(0, 0),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).width,
          width: MediaQuery.sizeOf(context).width,
          child: Stack(
            children: List.generate(size, (index) {
              return getAlign(index.toDouble() / size / 2);
            }),
          ),
        ),
      ),
    );
  }
}
