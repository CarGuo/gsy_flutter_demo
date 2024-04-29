import 'package:flutter/material.dart';

import 'secondary_tab_bar_render_sliver.dart';

class SecondaryTabBarSliverWidget extends SingleChildRenderObjectWidget {
  const SecondaryTabBarSliverWidget({super.child, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SecondaryTabBarRenderSliver();
  }
}
