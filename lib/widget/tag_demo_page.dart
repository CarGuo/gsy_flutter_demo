import 'package:flutter/material.dart';

class TagDemoPage extends StatelessWidget {
  const TagDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TagDemoPage"),
      ),
      body: Wrap(children: <Widget>[
        const TagItem("Start"),
        for (var item in tags) TagItem(item),
        const TagItem("End"),
      ]),
    );
  }
}

class TagItem extends StatelessWidget {
  final String text;

  const TagItem(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.blueAccent.withAlpha(60),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Text(text),
    );
  }
}

const List<String> tags = [
  "FFFFFFF",
  "TTTTTT",
  "LL",
  "JJJJJJJJ",
  "PPPPP",
  "OOOOOOOOOOOO",
  "9999999",
  "*&",
  "5%%%%%",
  "¥¥¥¥¥¥",
  "UUUUUUUUUU",
  "))@@@@@@"
];
