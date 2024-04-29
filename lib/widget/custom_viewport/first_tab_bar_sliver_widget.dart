import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/widget/custom_viewport/first_tab_bar_render_sliver.dart';

class FirstTabBarSliverWidget extends SingleChildRenderObjectWidget {
  const FirstTabBarSliverWidget({super.child, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return FirstTabBarRenderSliver();
  }
}
