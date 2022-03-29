import 'package:flutter/material.dart';

import 'secondary_tab_bar_render_sliver.dart';

class SecondaryTabBarSliverWidget extends SingleChildRenderObjectWidget {
  const SecondaryTabBarSliverWidget({Widget? child, Key? key})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SecondaryTabBarRenderSliver();
  }
}
