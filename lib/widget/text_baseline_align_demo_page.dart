import 'package:flutter/material.dart';

/// 中文 数字 英文混合时 且文字大小不一致时，文本的基线对齐
class TextBaselineAlignDemoPage extends StatelessWidget {
  const TextBaselineAlignDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("文本的基线对齐")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "默认: ",
                style: TextStyle(
                    fontSize: 38,
                    color: Colors.red,
                    backgroundColor: Colors.yellow
                    // backgroundColor: Colors.teal,
                    ),
              ),
              Text(
                "\$",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                  backgroundColor: Colors.teal,
                ),
              ),
              Text(
                "1,000",
                style: TextStyle(
                  fontSize: 64,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  backgroundColor: Colors.lightBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "基线: ",
                style: TextStyle(
                  fontSize: 38,
                  color: Colors.red,
                  backgroundColor: Colors.teal,
                ),
              ),
              Text(
                "\$",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                  backgroundColor: Colors.teal,
                ),
              ),
              Text(
                "1,000",
                style: TextStyle(
                  fontSize: 64,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  backgroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
