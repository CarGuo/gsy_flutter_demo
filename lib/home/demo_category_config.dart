import 'package:flutter/material.dart';
import 'package:gsy_flutter_demo/l10n/app_localizations.dart';

enum DemoCategory {
  basic(Icons.widgets_rounded, Color(0xFF1D7BCB)),
  scroll(Icons.swap_vert_rounded, Color(0xFF0B8E70)),
  animation(Icons.play_circle_outline_rounded, Color(0xFFE66A00)),
  canvas(Icons.brush_rounded, Color(0xFF7A57D1)),
  visual(Icons.auto_awesome_mosaic_rounded, Color(0xFF4A74E8));

  const DemoCategory(this.icon, this.color);

  final IconData icon;
  final Color color;

  String label(AppLocalizations l10n) {
    switch (this) {
      case DemoCategory.basic:
        return l10n.categoryBasic;
      case DemoCategory.scroll:
        return l10n.categoryScroll;
      case DemoCategory.animation:
        return l10n.categoryAnimation;
      case DemoCategory.canvas:
        return l10n.categoryCanvas;
      case DemoCategory.visual:
        return l10n.categoryVisual;
    }
  }
}

class DemoCategoryConfig {
  static const Map<String, DemoCategory> manualOverrides =
      <String, DemoCategory>{
    // Add exact title mapping when keyword matching is not enough.
    // e.g. 'Some Demo Title': DemoCategory.canvas,
  };

  static const List<_CategoryRule> rules = <_CategoryRule>[
    _CategoryRule(DemoCategory.scroll, <String>[
      'list',
      'sliver',
      'scroll',
      'viewpager',
      'pageview',
      '列表',
      '滑动',
      '停靠',
      '联动',
      'bottomsheet',
      'chat',
      'draggable',
      'link',
    ]),
    _CategoryRule(DemoCategory.visual, <String>[
      '3d',
      'box',
      'card',
      'cube',
      'juejin',
      'logo',
      'sphere',
      'spatial',
      'gallery',
      'disco',
      'mosaic',
      '二维码',
      '画廊',
      '星云',
      '黑洞',
      '太极',
      '鱼',
      'koi',
      'galaxy',
    ]),
    _CategoryRule(DemoCategory.canvas, <String>[
      'canvas',
      'shader',
      'path',
      'matrix',
      'blur',
      'glass',
      'liquid',
      'radial',
      'neon',
      'wave',
      '绘制',
      '阴影',
      '路径',
      '高斯',
      '手势',
      'jaw',
    ]),
    _CategoryRule(DemoCategory.animation, <String>[
      'anim',
      'animation',
      'particle',
      'boom',
      'bomb',
      'switch',
      'seekbar',
      'scan',
      'clock',
      'tip',
      '撕裂',
      '爆炸',
      '动画',
      '粒子',
      '炫酷',
      '骚气',
      '霓虹',
      'cool',
    ]),
  ];
}

class DemoCategoryMatcher {
  static DemoCategory byTitle(String title) {
    final override = DemoCategoryConfig.manualOverrides[title];
    if (override != null) {
      return override;
    }

    final value = title.toLowerCase();
    for (final rule in DemoCategoryConfig.rules) {
      if (_containsAny(value, rule.keywords)) {
        return rule.category;
      }
    }

    return DemoCategory.basic;
  }

  static bool _containsAny(String source, List<String> keywords) {
    for (final keyword in keywords) {
      if (source.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}

class _CategoryRule {
  const _CategoryRule(this.category, this.keywords);

  final DemoCategory category;
  final List<String> keywords;
}
