import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/custom_viewport/first_tab_bar_sliver_widget.dart';

class FirstTabBar extends StatelessWidget {
  const FirstTabBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirstTabBarSliverWidget(
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    return Container(
      height: 66,
      color: Colors.deepPurpleAccent,
      child: Center(
        child: Text('一级tab'),
      ),
    );
  }
}
